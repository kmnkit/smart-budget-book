// supabase/functions/store-webhook/index.ts
// Handles Apple App Store Server Notifications V2 and Google RTDN
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const WEBHOOK_SECRET = Deno.env.get("WEBHOOK_SECRET")!;

serve(async (req: Request) => {
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  try {
    const body = await req.json();

    // Detect platform from request format
    if (body.signedPayload) {
      // Apple App Store Server Notifications V2
      return await handleAppleNotification(supabase, body);
    } else if (body.message) {
      // Google Real-time Developer Notifications (via Pub/Sub)
      // Verify webhook secret
      const secret = req.headers.get("X-Webhook-Secret") || new URL(req.url).searchParams.get("secret");
      if (!secret || secret !== WEBHOOK_SECRET) {
        return new Response(JSON.stringify({ error: "Unauthorized" }), {
          status: 401,
        });
      }
      return await handleGoogleNotification(supabase, body);
    }

    return new Response(JSON.stringify({ error: "Unknown format" }), {
      status: 400,
    });
  } catch (error) {
    console.error("Webhook error:", error);
    return new Response(JSON.stringify({ error: "Internal error" }), {
      status: 500,
    });
  }
});

// Helper function to verify Apple JWS signature
async function verifyAppleJWS(jws: string): Promise<boolean> {
  try {
    const parts = jws.split(".");
    if (parts.length !== 3) {
      return false;
    }

    // Fetch Apple's JWKS
    const jwksResponse = await fetch("https://appleid.apple.com/auth/keys");
    if (!jwksResponse.ok) {
      console.error("Failed to fetch Apple JWKS");
      return false;
    }
    const jwks = await jwksResponse.json();

    // Decode header to get key ID
    const header = JSON.parse(atob(parts[0]));
    const kid = header.kid;

    // Find matching key
    const key = jwks.keys.find((k: { kid: string }) => k.kid === kid);
    if (!key) {
      console.error("No matching key found for kid:", kid);
      return false;
    }

    // Import the public key
    const publicKey = await crypto.subtle.importKey(
      "jwk",
      key,
      { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
      false,
      ["verify"]
    );

    // Verify signature
    const signatureBytes = base64UrlDecode(parts[2]);
    const dataBytes = new TextEncoder().encode(`${parts[0]}.${parts[1]}`);

    return await crypto.subtle.verify(
      "RSASSA-PKCS1-v1_5",
      publicKey,
      signatureBytes,
      dataBytes
    );
  } catch (error) {
    console.error("JWS verification error:", error);
    return false;
  }
}

// Helper function to decode base64url
function base64UrlDecode(str: string): Uint8Array {
  const base64 = str.replace(/-/g, "+").replace(/_/g, "/");
  const padding = "=".repeat((4 - (base64.length % 4)) % 4);
  const binary = atob(base64 + padding);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
}

async function handleAppleNotification(
  supabase: ReturnType<typeof createClient>,
  body: { signedPayload: string }
) {
  try {
    // Verify outer JWS signature
    const isValidOuter = await verifyAppleJWS(body.signedPayload);
    if (!isValidOuter) {
      return new Response(JSON.stringify({ error: "Invalid signature" }), {
        status: 401,
      });
    }

    // Decode JWS payload (signedPayload is a JWS)
    const parts = body.signedPayload.split(".");
    if (parts.length !== 3) {
      return new Response(JSON.stringify({ error: "Invalid JWS" }), {
        status: 400,
      });
    }

    const payload = JSON.parse(atob(parts[1]));
    const notificationType = payload.notificationType;
    const subtype = payload.subtype;

    // Decode transaction info
    const transactionInfo = payload.data?.signedTransactionInfo;
    if (!transactionInfo) {
      return new Response(JSON.stringify({ ok: true }), { status: 200 });
    }

    // Verify inner transaction JWS signature
    const isValidInner = await verifyAppleJWS(transactionInfo);
    if (!isValidInner) {
      return new Response(JSON.stringify({ error: "Invalid transaction signature" }), {
        status: 401,
      });
    }

    const txParts = transactionInfo.split(".");
    const txPayload = JSON.parse(atob(txParts[1]));
    const appAccountToken = txPayload.appAccountToken; // user_id
    const productId = txPayload.productId;
    const expiresDate = txPayload.expiresDate;

    if (!appAccountToken) {
      console.error("No appAccountToken in transaction");
      return new Response(JSON.stringify({ ok: true }), { status: 200 });
    }

    let newStatus: string;
    let newTier: string;

    switch (notificationType) {
      case "SUBSCRIBED":
      case "DID_RENEW":
        newStatus = "active";
        newTier = "premium";
        break;
      case "DID_CHANGE_RENEWAL_STATUS":
        if (subtype === "AUTO_RENEW_DISABLED") {
          newStatus = "canceled";
          newTier = "premium"; // Still premium until period ends
        } else {
          newStatus = "active";
          newTier = "premium";
        }
        break;
      case "EXPIRED":
        newStatus = "expired";
        newTier = "free";
        break;
      case "GRACE_PERIOD_EXPIRED":
        newStatus = "expired";
        newTier = "free";
        break;
      case "DID_FAIL_TO_RENEW":
        if (subtype === "GRACE_PERIOD") {
          newStatus = "past_due";
          newTier = "premium"; // Retain access during grace
        } else {
          newStatus = "past_due";
          newTier = "premium";
        }
        break;
      case "REFUND":
        newStatus = "expired";
        newTier = "free";
        break;
      case "REVOKE":
        newStatus = "expired";
        newTier = "free";
        break;
      default:
        console.log(`Unhandled Apple notification: ${notificationType}`);
        return new Response(JSON.stringify({ ok: true }), { status: 200 });
    }

    const now = new Date().toISOString();
    const expiresAt = expiresDate
      ? new Date(expiresDate).toISOString()
      : null;

    // Update subscription
    await supabase
      .from("subscriptions")
      .update({
        tier: newTier,
        status: newStatus,
        store_product_id: productId,
        current_period_end_at: expiresAt,
        canceled_at:
          newStatus === "canceled" || newStatus === "expired" ? now : null,
        updated_at: now,
      })
      .eq("user_id", appAccountToken);

    // Update profile cache
    await supabase
      .from("profiles")
      .update({ subscription_tier: newTier })
      .eq("id", appAccountToken);

    return new Response(JSON.stringify({ ok: true }), { status: 200 });
  } catch (error) {
    console.error("Apple notification error:", error);
    return new Response(JSON.stringify({ error: "Processing failed" }), {
      status: 500,
    });
  }
}

async function handleGoogleNotification(
  supabase: ReturnType<typeof createClient>,
  body: { message: { data: string } }
) {
  try {
    // Decode Pub/Sub message
    const messageData = JSON.parse(atob(body.message.data));
    const {
      subscriptionNotification,
      packageName,
    } = messageData;

    if (!subscriptionNotification) {
      return new Response(JSON.stringify({ ok: true }), { status: 200 });
    }

    const { notificationType, purchaseToken, subscriptionId } =
      subscriptionNotification;

    // Look up user by store_transaction_id (purchaseToken)
    const { data: subscription } = await supabase
      .from("subscriptions")
      .select("user_id")
      .eq("store_transaction_id", purchaseToken)
      .single();

    if (!subscription) {
      console.error("No subscription found for token:", purchaseToken.substring(0, 10) + "...");
      return new Response(JSON.stringify({ ok: true }), { status: 200 });
    }

    const userId = subscription.user_id;
    let newStatus: string;
    let newTier: string;

    // Google RTDN notification types
    // https://developer.android.com/google/play/billing/rtdn-reference
    switch (notificationType) {
      case 1: // SUBSCRIPTION_RECOVERED
        newStatus = "active";
        newTier = "premium";
        break;
      case 2: // SUBSCRIPTION_RENEWED
        newStatus = "active";
        newTier = "premium";
        break;
      case 3: // SUBSCRIPTION_CANCELED
        newStatus = "canceled";
        newTier = "premium"; // Still active until period ends
        break;
      case 4: // SUBSCRIPTION_PURCHASED
        newStatus = "active";
        newTier = "premium";
        break;
      case 5: // SUBSCRIPTION_ON_HOLD
        newStatus = "past_due";
        newTier = "premium";
        break;
      case 6: // SUBSCRIPTION_IN_GRACE_PERIOD
        newStatus = "past_due";
        newTier = "premium";
        break;
      case 7: // SUBSCRIPTION_RESTARTED
        newStatus = "active";
        newTier = "premium";
        break;
      case 12: // SUBSCRIPTION_REVOKED
        newStatus = "expired";
        newTier = "free";
        break;
      case 13: // SUBSCRIPTION_EXPIRED
        newStatus = "expired";
        newTier = "free";
        break;
      default:
        console.log(`Unhandled Google notification type: ${notificationType}`);
        return new Response(JSON.stringify({ ok: true }), { status: 200 });
    }

    const now = new Date().toISOString();

    // Update subscription
    await supabase
      .from("subscriptions")
      .update({
        tier: newTier,
        status: newStatus,
        canceled_at:
          newStatus === "canceled" || newStatus === "expired" ? now : null,
        updated_at: now,
      })
      .eq("user_id", userId);

    // Update profile cache
    await supabase
      .from("profiles")
      .update({ subscription_tier: newTier })
      .eq("id", userId);

    return new Response(JSON.stringify({ ok: true }), { status: 200 });
  } catch (error) {
    console.error("Google notification error:", error);
    return new Response(JSON.stringify({ error: "Processing failed" }), {
      status: 500,
    });
  }
}
