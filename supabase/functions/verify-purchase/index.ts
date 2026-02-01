// supabase/functions/verify-purchase/index.ts
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// Apple App Store Server API
const APPLE_BUNDLE_ID = Deno.env.get("APPLE_BUNDLE_ID") ?? "com.zan.app";
const APPLE_ISSUER_ID = Deno.env.get("APPLE_ISSUER_ID") ?? "";
const APPLE_KEY_ID = Deno.env.get("APPLE_KEY_ID") ?? "";

// Google Play
const GOOGLE_PACKAGE_NAME =
  Deno.env.get("GOOGLE_PACKAGE_NAME") ?? "com.zan.app";

interface VerifyRequest {
  receipt_data: string;
  product_id: string;
  platform: "ios" | "android";
}

serve(async (req: Request) => {
  try {
    // Auth check
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
      });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Get user from JWT
    const token = authHeader.replace("Bearer ", "");
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser(token);
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Invalid token" }), {
        status: 401,
      });
    }

    const body: VerifyRequest = await req.json();
    const { receipt_data, product_id, platform } = body;

    let verified = false;
    let expiresAt: string | null = null;

    if (platform === "ios") {
      const result = await verifyApplePurchase(receipt_data, product_id);
      verified = result.verified;
      expiresAt = result.expiresAt;
    } else if (platform === "android") {
      const result = await verifyGooglePurchase(receipt_data, product_id);
      verified = result.verified;
      expiresAt = result.expiresAt;
    }

    if (!verified) {
      return new Response(
        JSON.stringify({ success: false, error: "Verification failed" }),
        { status: 400 }
      );
    }

    // Determine period from product_id
    const period = product_id.includes("annual") ? "annual" : "monthly";
    const now = new Date().toISOString();

    // Upsert subscription
    const { error: upsertError } = await supabase
      .from("subscriptions")
      .upsert(
        {
          user_id: user.id,
          tier: "premium",
          status: "active",
          period,
          store_product_id: product_id,
          store_transaction_id: receipt_data.substring(0, 100),
          platform,
          current_period_start_at: now,
          current_period_end_at: expiresAt,
          updated_at: now,
        },
        { onConflict: "user_id" }
      );

    if (upsertError) {
      console.error("Upsert error:", upsertError);
      return new Response(
        JSON.stringify({ success: false, error: "Database error" }),
        { status: 500 }
      );
    }

    // Update profile cache
    await supabase
      .from("profiles")
      .update({ subscription_tier: "premium" })
      .eq("id", user.id);

    return new Response(
      JSON.stringify({
        success: true,
        tier: "premium",
        status: "active",
        expires_at: expiresAt,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Verify purchase error:", error);
    return new Response(
      JSON.stringify({ success: false, error: "Internal server error" }),
      { status: 500 }
    );
  }
});

// Cache for Apple's public keys (1 hour TTL)
let appleKeysCache: { keys: Array<{ kid: string; key: CryptoKey }>; expires: number } | null = null;

async function verifyApplePurchase(
  receiptData: string,
  _productId: string
): Promise<{ verified: boolean; expiresAt: string | null }> {
  try {
    // Apple App Store Server API v2 - JWS Transaction verification
    // Verify the JWS signature against Apple's public keys

    const isSandbox =
      Deno.env.get("APPLE_ENVIRONMENT") === "sandbox" ||
      !Deno.env.get("APPLE_ENVIRONMENT");

    const baseUrl = isSandbox
      ? "https://api.storekit-sandbox.itunes.apple.com"
      : "https://api.storekit.itunes.apple.com";

    // Parse JWS format (header.payload.signature)
    const parts = receiptData.split(".");
    if (parts.length !== 3) {
      console.error("Invalid JWS format");
      return { verified: false, expiresAt: null };
    }

    // Decode header to get key ID (kid)
    const headerJson = atob(parts[0]);
    const header = JSON.parse(headerJson);
    const kid = header.kid;

    if (!kid) {
      console.error("Missing kid in JWS header");
      return { verified: false, expiresAt: null };
    }

    // Get Apple's public keys
    const appleKeys = await getApplePublicKeys();
    const matchingKey = appleKeys.find((k) => k.kid === kid);

    if (!matchingKey) {
      console.error(`No matching Apple public key for kid: ${kid}`);
      return { verified: false, expiresAt: null };
    }

    // Verify RS256 signature
    const encoder = new TextEncoder();
    const data = encoder.encode(`${parts[0]}.${parts[1]}`);
    const signature = base64UrlToArrayBuffer(parts[2]);

    const isValid = await crypto.subtle.verify(
      { name: "RSASSA-PKCS1-v1_5" },
      matchingKey.key,
      signature,
      data
    );

    if (!isValid) {
      console.error("JWS signature verification failed");
      return { verified: false, expiresAt: null };
    }

    // Signature verified - now trust the payload
    const payload = JSON.parse(atob(parts[1]));
    const expiresDate = payload.expiresDate;
    const expiresAt = expiresDate
      ? new Date(expiresDate).toISOString()
      : null;

    return { verified: true, expiresAt };
  } catch (error) {
    console.error("Apple verification error:", error);
    return { verified: false, expiresAt: null };
  }
}

async function getApplePublicKeys(): Promise<Array<{ kid: string; key: CryptoKey }>> {
  const now = Date.now();

  // Return cached keys if still valid
  if (appleKeysCache && appleKeysCache.expires > now) {
    return appleKeysCache.keys;
  }

  // Fetch fresh keys from Apple
  const response = await fetch("https://appleid.apple.com/auth/keys");
  if (!response.ok) {
    throw new Error(`Failed to fetch Apple keys: ${response.status}`);
  }

  const jwks = await response.json();
  const keys: Array<{ kid: string; key: CryptoKey }> = [];

  for (const jwk of jwks.keys) {
    if (jwk.kty === "RSA" && jwk.use === "sig" && jwk.alg === "RS256") {
      const key = await crypto.subtle.importKey(
        "jwk",
        {
          kty: jwk.kty,
          n: jwk.n,
          e: jwk.e,
          alg: jwk.alg,
          ext: true,
        },
        { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
        false,
        ["verify"]
      );
      keys.push({ kid: jwk.kid, key });
    }
  }

  // Cache for 1 hour
  appleKeysCache = {
    keys,
    expires: now + 3600 * 1000,
  };

  return keys;
}

function base64UrlToArrayBuffer(base64Url: string): ArrayBuffer {
  // Convert base64url to base64
  const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/");
  const padding = "=".repeat((4 - (base64.length % 4)) % 4);
  const binary = atob(base64 + padding);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

async function verifyGooglePurchase(
  purchaseToken: string,
  productId: string
): Promise<{ verified: boolean; expiresAt: string | null }> {
  try {
    // Google Play Developer API v3
    // Requires service account credentials configured in GOOGLE_SERVICE_ACCOUNT_KEY
    const serviceAccountKey = Deno.env.get("GOOGLE_SERVICE_ACCOUNT_KEY");
    if (!serviceAccountKey) {
      console.error("GOOGLE_SERVICE_ACCOUNT_KEY not configured");
      return { verified: false, expiresAt: null };
    }

    const credentials = JSON.parse(serviceAccountKey);

    // Get access token via service account JWT
    const accessToken = await getGoogleAccessToken(credentials);
    if (!accessToken) {
      return { verified: false, expiresAt: null };
    }

    // Verify subscription purchase
    const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${GOOGLE_PACKAGE_NAME}/purchases/subscriptions/${productId}/tokens/${purchaseToken}`;

    const response = await fetch(url, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });

    if (!response.ok) {
      console.error("Google verification failed:", await response.text());
      return { verified: false, expiresAt: null };
    }

    const data = await response.json();

    // Check if subscription is valid
    // paymentState: 0 = pending, 1 = received, 2 = free trial, 3 = deferred
    const isValid =
      data.paymentState === 1 ||
      data.paymentState === 2 ||
      data.paymentState === 3;

    const expiresAt = data.expiryTimeMillis
      ? new Date(parseInt(data.expiryTimeMillis)).toISOString()
      : null;

    return { verified: isValid, expiresAt };
  } catch (error) {
    console.error("Google verification error:", error);
    return { verified: false, expiresAt: null };
  }
}

async function getGoogleAccessToken(
  credentials: Record<string, string>
): Promise<string | null> {
  try {
    const now = Math.floor(Date.now() / 1000);
    const header = btoa(JSON.stringify({ alg: "RS256", typ: "JWT" }));
    const claim = btoa(
      JSON.stringify({
        iss: credentials.client_email,
        scope: "https://www.googleapis.com/auth/androidpublisher",
        aud: "https://oauth2.googleapis.com/token",
        iat: now,
        exp: now + 3600,
      })
    );

    // Sign JWT with service account private key
    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey(
      "pkcs8",
      pemToArrayBuffer(credentials.private_key),
      { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
      false,
      ["sign"]
    );

    const signature = await crypto.subtle.sign(
      "RSASSA-PKCS1-v1_5",
      key,
      encoder.encode(`${header}.${claim}`)
    );

    const jwt = `${header}.${claim}.${btoa(
      String.fromCharCode(...new Uint8Array(signature))
    )}`;

    const response = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
    });

    const data = await response.json();
    return data.access_token || null;
  } catch (error) {
    console.error("Google auth error:", error);
    return null;
  }
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\n/g, "");
  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}
