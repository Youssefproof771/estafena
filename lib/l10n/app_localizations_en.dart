// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Estafena';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get friends => 'Friends';

  @override
  String get profile => 'Profile';

  @override
  String get owesYou => 'owes you';

  @override
  String get youOwe => 'you owe';

  @override
  String get estafeto => 'Estafeto? 🤙';

  @override
  String get estafetoPDesc => 'Mark this debt as cleared?';

  @override
  String get estafena => 'Estafena! ✅';

  @override
  String get notYet => 'Not Yet';

  @override
  String get pay => 'Pay';

  @override
  String get paymentOptions => 'Payment Options';

  @override
  String get noPaymentOptions => 'No payment options added';

  @override
  String get addFriend => 'Add Friend';

  @override
  String get friendUsername => 'Friend\'s username';

  @override
  String get add => 'Add';

  @override
  String get cancel => 'Cancel';

  @override
  String get noFriends => 'No friends yet.\nAdd someone to get started!';

  @override
  String get noDashboardItems => 'All clear! No debts tracked yet.';

  @override
  String get myProfile => 'My Profile';

  @override
  String get username => 'Username';

  @override
  String get editUsername => 'Edit Username';

  @override
  String get paymentMethods => 'My Payment Methods';

  @override
  String get addPaymentMethod => 'Add Payment Method';

  @override
  String get editPaymentMethod => 'Edit Payment Method';

  @override
  String get methodType => 'Method Type';

  @override
  String get accountDetails => 'Account Details (number / handle)';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get instapay => 'InstaPay';

  @override
  String get vodafoneCash => 'Vodafone Cash';

  @override
  String get egp => 'EGP';

  @override
  String get netBalance => 'Net Balance';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get transactionAmount => 'Amount (EGP)';

  @override
  String get transactionNote => 'Note (optional)';

  @override
  String get iPaid => 'I Paid';

  @override
  String get theyPaid => 'They Paid';

  @override
  String get transactions => 'Transactions';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get deleteConfirm => 'Remove Friend';

  @override
  String deleteConfirmDesc(String name) {
    return 'Remove $name and all their transactions?';
  }

  @override
  String get remove => 'Remove';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get settings => 'Settings';

  @override
  String get totalOwedToYou => 'Total Owed to You';

  @override
  String get totalYouOwe => 'Total You Owe';

  @override
  String get settled => 'Settled up!';

  @override
  String get copyNumber => 'Copy';

  @override
  String get copied => 'Copied!';
}
