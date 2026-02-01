enum AccountType {
  asset,
  liability,
  expense,
  income,
  equity;

  bool get isDebitNormal => this == asset || this == expense;
  bool get isCreditNormal => this == liability || this == income || this == equity;
}

enum AccountCategory {
  // Asset
  cash,
  bankAccount,
  eMoney,
  creditCardPrepaid,
  investment,
  receivable,
  otherAsset,
  // Liability
  creditCard,
  loan,
  otherLiability,
  // Expense
  food,
  transport,
  housing,
  utilities,
  entertainment,
  shopping,
  health,
  education,
  communication,
  insurance,
  tax,
  otherExpense,
  // Income
  salary,
  freelance,
  investmentIncome,
  otherIncome,
  // Equity
  openingBalance,
  retainedEarnings;

  AccountType get accountType {
    return switch (this) {
      cash || bankAccount || eMoney || creditCardPrepaid || investment || receivable || otherAsset => AccountType.asset,
      creditCard || loan || otherLiability => AccountType.liability,
      food || transport || housing || utilities || entertainment || shopping || health || education || communication || insurance || tax || otherExpense => AccountType.expense,
      salary || freelance || investmentIncome || otherIncome => AccountType.income,
      openingBalance || retainedEarnings => AccountType.equity,
    };
  }

  String get dbValue {
    return switch (this) {
      bankAccount => 'bank_account',
      eMoney => 'e_money',
      creditCardPrepaid => 'credit_card_prepaid',
      otherAsset => 'other_asset',
      creditCard => 'credit_card',
      otherLiability => 'other_liability',
      otherExpense => 'other_expense',
      investmentIncome => 'investment_income',
      otherIncome => 'other_income',
      openingBalance => 'opening_balance',
      retainedEarnings => 'retained_earnings',
      _ => name,
    };
  }

  static AccountCategory fromDbValue(String value) {
    return switch (value) {
      'bank_account' => bankAccount,
      'e_money' => eMoney,
      'credit_card_prepaid' => creditCardPrepaid,
      'other_asset' => otherAsset,
      'credit_card' => creditCard,
      'other_liability' => otherLiability,
      'other_expense' => otherExpense,
      'investment_income' => investmentIncome,
      'other_income' => otherIncome,
      'opening_balance' => openingBalance,
      'retained_earnings' => retainedEarnings,
      _ => AccountCategory.values.firstWhere((e) => e.name == value),
    };
  }
}

enum TransactionType {
  expense,
  income,
  transfer;
}

enum SourceType {
  manual,
  textAi,
  voiceAi,
  ocr,
  import_;

  String get dbValue {
    return switch (this) {
      textAi => 'text_ai',
      voiceAi => 'voice_ai',
      import_ => 'import',
      _ => name,
    };
  }

  static SourceType fromDbValue(String value) {
    return switch (value) {
      'text_ai' => textAi,
      'voice_ai' => voiceAi,
      'import' => import_,
      _ => SourceType.values.firstWhere((e) => e.name == value),
    };
  }
}

enum SubscriptionTier {
  free,
  premium;

  String get dbValue => name;

  static SubscriptionTier fromDbValue(String value) {
    return SubscriptionTier.values.firstWhere((e) => e.name == value);
  }
}

enum SubscriptionStatus {
  none,
  trialing,
  active,
  pastDue,
  expired,
  canceled;

  String get dbValue {
    return switch (this) {
      pastDue => 'past_due',
      _ => name,
    };
  }

  static SubscriptionStatus fromDbValue(String value) {
    return switch (value) {
      'past_due' => pastDue,
      _ => SubscriptionStatus.values.firstWhere((e) => e.name == value),
    };
  }
}

enum SubscriptionPeriod {
  monthly,
  annual;

  String get dbValue => name;

  static SubscriptionPeriod fromDbValue(String value) {
    return SubscriptionPeriod.values.firstWhere((e) => e.name == value);
  }
}

enum FeatureType {
  createAccount,
  createTransaction,
  aiInput,
  ocrScan,
  exportPdf,
  exportJson,
  multiCurrency,
  fullHistory,
}

enum UsageType {
  aiInput,
  ocrScan;

  String get dbValue {
    return switch (this) {
      aiInput => 'ai_input',
      ocrScan => 'ocr_scan',
    };
  }

  static UsageType fromDbValue(String value) {
    return switch (value) {
      'ai_input' => aiInput,
      'ocr_scan' => ocrScan,
      _ => UsageType.values.firstWhere((e) => e.name == value),
    };
  }
}
