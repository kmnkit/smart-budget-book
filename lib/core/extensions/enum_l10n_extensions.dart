import 'package:zan/core/constants/enums.dart';
import 'package:zan/generated/l10n/app_localizations.dart';

extension AccountTypeL10n on AccountType {
  String label(AppLocalizations l10n) {
    return switch (this) {
      AccountType.asset => l10n.asset,
      AccountType.liability => l10n.liability,
      AccountType.expense => l10n.expense,
      AccountType.income => l10n.income,
      AccountType.equity => l10n.equity,
    };
  }
}

extension AccountCategoryL10n on AccountCategory {
  String label(AppLocalizations l10n) {
    return switch (this) {
      AccountCategory.cash => l10n.categoryCash,
      AccountCategory.bankAccount => l10n.categoryBankAccount,
      AccountCategory.eMoney => l10n.categoryEMoney,
      AccountCategory.creditCardPrepaid => l10n.categoryCreditCardPrepaid,
      AccountCategory.investment => l10n.categoryInvestment,
      AccountCategory.receivable => l10n.categoryReceivable,
      AccountCategory.otherAsset => l10n.categoryOtherAsset,
      AccountCategory.creditCard => l10n.categoryCreditCard,
      AccountCategory.loan => l10n.categoryLoan,
      AccountCategory.otherLiability => l10n.categoryOtherLiability,
      AccountCategory.food => l10n.categoryFood,
      AccountCategory.transport => l10n.categoryTransport,
      AccountCategory.housing => l10n.categoryHousing,
      AccountCategory.utilities => l10n.categoryUtilities,
      AccountCategory.entertainment => l10n.categoryEntertainment,
      AccountCategory.shopping => l10n.categoryShopping,
      AccountCategory.health => l10n.categoryHealth,
      AccountCategory.education => l10n.categoryEducation,
      AccountCategory.communication => l10n.categoryCommunication,
      AccountCategory.insurance => l10n.categoryInsurance,
      AccountCategory.tax => l10n.categoryTax,
      AccountCategory.otherExpense => l10n.categoryOtherExpense,
      AccountCategory.salary => l10n.categorySalary,
      AccountCategory.freelance => l10n.categoryFreelance,
      AccountCategory.investmentIncome => l10n.categoryInvestmentIncome,
      AccountCategory.otherIncome => l10n.categoryOtherIncome,
      AccountCategory.openingBalance => l10n.categoryOpeningBalance,
      AccountCategory.retainedEarnings => l10n.categoryRetainedEarnings,
    };
  }
}
