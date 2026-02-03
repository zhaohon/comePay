import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('id'),
    Locale('zh')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @applySetting.
  ///
  /// In en, this message translates to:
  /// **'Apply this setting'**
  String get applySetting;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @china.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get china;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @inviteFriend.
  ///
  /// In en, this message translates to:
  /// **'Invite friend'**
  String get inviteFriend;

  /// No description provided for @kyc.
  ///
  /// In en, this message translates to:
  /// **'KYC'**
  String get kyc;

  /// No description provided for @coupon.
  ///
  /// In en, this message translates to:
  /// **'Coupon'**
  String get coupon;

  /// No description provided for @customerServiceCenter.
  ///
  /// In en, this message translates to:
  /// **'Customer Service Center'**
  String get customerServiceCenter;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutUs;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @identityVerified.
  ///
  /// In en, this message translates to:
  /// **'identity verified'**
  String get identityVerified;

  /// No description provided for @userIdCopied.
  ///
  /// In en, this message translates to:
  /// **'User ID copied to clipboard'**
  String get userIdCopied;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @noId.
  ///
  /// In en, this message translates to:
  /// **'No ID'**
  String get noId;

  /// No description provided for @inviteFriendsRebate.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends\nGet 50% rebate'**
  String get inviteFriendsRebate;

  /// No description provided for @moreFriendsHigherCommission.
  ///
  /// In en, this message translates to:
  /// **'The more friend you invite, the higher commission you get'**
  String get moreFriendsHigherCommission;

  /// No description provided for @nodePartnerProgram.
  ///
  /// In en, this message translates to:
  /// **'Node partner Program\nExclusive Promotion Plan\nNow Recruiting'**
  String get nodePartnerProgram;

  /// No description provided for @applyHighRebate.
  ///
  /// In en, this message translates to:
  /// **'Apply for high rebate'**
  String get applyHighRebate;

  /// No description provided for @shareInvitationLink.
  ///
  /// In en, this message translates to:
  /// **'Share your invitation link with friend'**
  String get shareInvitationLink;

  /// No description provided for @friendCompleteRegistration.
  ///
  /// In en, this message translates to:
  /// **'When your friend complete registration'**
  String get friendCompleteRegistration;

  /// No description provided for @earnRebates.
  ///
  /// In en, this message translates to:
  /// **'You earn rebates when your friend activates a card or makes transactions'**
  String get earnRebates;

  /// No description provided for @shareNowCashback.
  ///
  /// In en, this message translates to:
  /// **'Share Now and get cashback'**
  String get shareNowCashback;

  /// No description provided for @invitationCode.
  ///
  /// In en, this message translates to:
  /// **'Invitation Code'**
  String get invitationCode;

  /// No description provided for @invitationLink.
  ///
  /// In en, this message translates to:
  /// **'Invitation Link'**
  String get invitationLink;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @telegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get telegram;

  /// No description provided for @wechat.
  ///
  /// In en, this message translates to:
  /// **'WeChat'**
  String get wechat;

  /// No description provided for @currentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current level'**
  String get currentLevel;

  /// No description provided for @cardRebate.
  ///
  /// In en, this message translates to:
  /// **'Card Rebate'**
  String get cardRebate;

  /// No description provided for @spendingRebate.
  ///
  /// In en, this message translates to:
  /// **'Spending rebate'**
  String get spendingRebate;

  /// No description provided for @secondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get secondary;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @failedToLoadCoupons.
  ///
  /// In en, this message translates to:
  /// **'Failed to load coupons'**
  String get failedToLoadCoupons;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noAvailableCoupons.
  ///
  /// In en, this message translates to:
  /// **'No available coupons'**
  String get noAvailableCoupons;

  /// No description provided for @noUsedCoupons.
  ///
  /// In en, this message translates to:
  /// **'No used coupons'**
  String get noUsedCoupons;

  /// No description provided for @noExpiredCoupons.
  ///
  /// In en, this message translates to:
  /// **'No expired coupons'**
  String get noExpiredCoupons;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @expiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expiredLabel;

  /// No description provided for @couponCode.
  ///
  /// In en, this message translates to:
  /// **'Coupon Code'**
  String get couponCode;

  /// No description provided for @enterACouponCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a coupon code'**
  String get enterACouponCode;

  /// No description provided for @pleaseEnterACouponCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a coupon code'**
  String get pleaseEnterACouponCode;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @couponCodeBinding.
  ///
  /// In en, this message translates to:
  /// **'Coupon Code binding'**
  String get couponCodeBinding;

  /// No description provided for @aboutUsTitle.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUsTitle;

  /// No description provided for @companyIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Company Introduction'**
  String get companyIntroduction;

  /// No description provided for @termOfUse.
  ///
  /// In en, this message translates to:
  /// **'Term of use'**
  String get termOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @transactionPassword.
  ///
  /// In en, this message translates to:
  /// **'Transaction password'**
  String get transactionPassword;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Login password'**
  String get loginPassword;

  /// No description provided for @unbound.
  ///
  /// In en, this message translates to:
  /// **'Unbound'**
  String get unbound;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed'**
  String get logoutFailed;

  /// No description provided for @modifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Modify Email'**
  String get modifyEmail;

  /// No description provided for @modifyEmailWarning.
  ///
  /// In en, this message translates to:
  /// **'To ensure the security of your account, withdraw transactions will be restricted for 24 hour after modifying your email'**
  String get modifyEmailWarning;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New Email'**
  String get newEmail;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @emailVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Email verification code'**
  String get emailVerificationCode;

  /// No description provided for @pleaseEnterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter verification code'**
  String get pleaseEnterVerificationCode;

  /// No description provided for @getCode.
  ///
  /// In en, this message translates to:
  /// **'Get Code'**
  String get getCode;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @otpSentToNewEmail.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your new email'**
  String get otpSentToNewEmail;

  /// No description provided for @failedToSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP'**
  String get failedToSendOtp;

  /// No description provided for @verificationMethod.
  ///
  /// In en, this message translates to:
  /// **'Verification method'**
  String get verificationMethod;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email verification'**
  String get emailVerification;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @enterEmailVerificationCodeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter the email verification code first'**
  String get enterEmailVerificationCodeFirst;

  /// No description provided for @newEmailVerifiedOtpSentToCurrent.
  ///
  /// In en, this message translates to:
  /// **'New email verified, OTP sent to current email'**
  String get newEmailVerifiedOtpSentToCurrent;

  /// No description provided for @failedToVerifyNewEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to verify new email'**
  String get failedToVerifyNewEmail;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get enterVerificationCode;

  /// No description provided for @emailChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email changed successfully'**
  String get emailChangedSuccessfully;

  /// No description provided for @failedToChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to change email'**
  String get failedToChangeEmail;

  /// No description provided for @bindPhone.
  ///
  /// In en, this message translates to:
  /// **'Bind Phone'**
  String get bindPhone;

  /// No description provided for @bindPhoneWarning.
  ///
  /// In en, this message translates to:
  /// **'To ensure the security of your account, withdraw transactions will be restricted for 24 hour after modifying your number'**
  String get bindPhoneWarning;

  /// No description provided for @newPhone.
  ///
  /// In en, this message translates to:
  /// **'New Phone'**
  String get newPhone;

  /// No description provided for @pleaseEnterYourNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your number'**
  String get pleaseEnterYourNumber;

  /// No description provided for @phoneVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Phone verification code'**
  String get phoneVerificationCode;

  /// No description provided for @otpSentToYourPhone.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your phone'**
  String get otpSentToYourPhone;

  /// No description provided for @emailOtpSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email OTP sent successfully'**
  String get emailOtpSentSuccessfully;

  /// No description provided for @phoneNumberChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Phone number changed successfully'**
  String get phoneNumberChangedSuccessfully;

  /// No description provided for @confirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming...'**
  String get confirming;

  /// No description provided for @emailNotFoundPleaseLoginAgain.
  ///
  /// In en, this message translates to:
  /// **'Email not found. Please log in again.'**
  String get emailNotFoundPleaseLoginAgain;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error occurred'**
  String get errorOccurred;

  /// No description provided for @setTransactionPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Transaction Password'**
  String get setTransactionPassword;

  /// No description provided for @setTransactionPasswordWarning.
  ///
  /// In en, this message translates to:
  /// **'To ensure the security of your account, withdraw transactions will be restricted for 24 hours after modifying your transaction password'**
  String get setTransactionPasswordWarning;

  /// No description provided for @pleaseEnterThe6DigitTransactionCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6 digit transaction code'**
  String get pleaseEnterThe6DigitTransactionCode;

  /// No description provided for @confirmTransactionPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm transaction password'**
  String get confirmTransactionPassword;

  /// No description provided for @pleaseEnterTheConfirmationTransactionPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter the confirmation transaction password'**
  String get pleaseEnterTheConfirmationTransactionPassword;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// No description provided for @otpSentToYourEmail.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your email'**
  String get otpSentToYourEmail;

  /// No description provided for @transactionPasswordSetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transaction password set successfully'**
  String get transactionPasswordSetSuccessfully;

  /// No description provided for @modifyLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Modify login password'**
  String get modifyLoginPassword;

  /// No description provided for @modifyLoginPasswordWarning.
  ///
  /// In en, this message translates to:
  /// **'To ensure the security of your account, withdraw transactions will be restricted for 24 hours after modifying your transaction password'**
  String get modifyLoginPasswordWarning;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old password'**
  String get oldPassword;

  /// No description provided for @pleaseEnterTheOldPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter the old password'**
  String get pleaseEnterTheOldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @pleaseEnterANewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterANewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @pleaseEnterToConfirmTheNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter to confirm the new password'**
  String get pleaseEnterToConfirmTheNewPassword;

  /// No description provided for @welcomeToPokePay.
  ///
  /// In en, this message translates to:
  /// **'Welcome to PokePay'**
  String get welcomeToPokePay;

  /// No description provided for @welcomeToComeComePay.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Come Come Pay'**
  String get welcomeToComeComePay;

  /// No description provided for @totalAssets.
  ///
  /// In en, this message translates to:
  /// **'Total Assets'**
  String get totalAssets;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @withdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get withdrawal;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @receive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// No description provided for @swap.
  ///
  /// In en, this message translates to:
  /// **'SWAP'**
  String get swap;

  /// No description provided for @fundFlow.
  ///
  /// In en, this message translates to:
  /// **'Fund flow'**
  String get fundFlow;

  /// No description provided for @latestTransactions.
  ///
  /// In en, this message translates to:
  /// **'Latest Transactions'**
  String get latestTransactions;

  /// No description provided for @seeAllTransactions.
  ///
  /// In en, this message translates to:
  /// **'See All Transactions'**
  String get seeAllTransactions;

  /// No description provided for @noRelevantDataYet.
  ///
  /// In en, this message translates to:
  /// **'No relevant data yet'**
  String get noRelevantDataYet;

  /// No description provided for @comeComePayCard.
  ///
  /// In en, this message translates to:
  /// **'Come Come Pay Card'**
  String get comeComePayCard;

  /// No description provided for @noMonthlyFee.
  ///
  /// In en, this message translates to:
  /// **'No monthly Fee'**
  String get noMonthlyFee;

  /// No description provided for @lowTransactionFee.
  ///
  /// In en, this message translates to:
  /// **'Low transaction Fee'**
  String get lowTransactionFee;

  /// No description provided for @spendCryptoLikeFiat.
  ///
  /// In en, this message translates to:
  /// **'Spend crypto like fiat! Binding card, POS terminals, ATMs. Apply now and ready to use upon activation!'**
  String get spendCryptoLikeFiat;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNow;

  /// No description provided for @messageServiceCenter.
  ///
  /// In en, this message translates to:
  /// **'Message Service Center'**
  String get messageServiceCenter;

  /// No description provided for @loginToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginToYourAccount;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotUserOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot User / Password ?'**
  String get forgotUserOrPassword;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @pleaseEnterTheCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the code'**
  String get pleaseEnterTheCode;

  /// No description provided for @weSentEmailTo.
  ///
  /// In en, this message translates to:
  /// **'We sent email to'**
  String get weSentEmailTo;

  /// No description provided for @didntGetACode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get a code?'**
  String get didntGetACode;

  /// No description provided for @sendAgain.
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get sendAgain;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verify;

  /// No description provided for @forEveryDreamWithComeComePay.
  ///
  /// In en, this message translates to:
  /// **'For every dream with\nCome Come Pay'**
  String get forEveryDreamWithComeComePay;

  /// No description provided for @fasility.
  ///
  /// In en, this message translates to:
  /// **'A facility that provides you financial assistance whenever you need.'**
  String get fasility;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @manageCripto.
  ///
  /// In en, this message translates to:
  /// **'Manage Your Crypto Asset And Payments with Come Pay'**
  String get manageCripto;

  /// No description provided for @manageCriptoDesc.
  ///
  /// In en, this message translates to:
  /// **'A convenient way to manage your money securely from mobile device.'**
  String get manageCriptoDesc;

  /// No description provided for @verificationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification Success'**
  String get verificationSuccess;

  /// No description provided for @verificationSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'You have successfully created a new password, click continue to enter the application.'**
  String get verificationSuccessDesc;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @confirmYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your Email'**
  String get confirmYourEmail;

  /// No description provided for @didnReceive.
  ///
  /// In en, this message translates to:
  /// **'didn’t receive'**
  String get didnReceive;

  /// No description provided for @myEmail.
  ///
  /// In en, this message translates to:
  /// **'My Email'**
  String get myEmail;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get createPassword;

  /// No description provided for @passwordMustBe8Characters.
  ///
  /// In en, this message translates to:
  /// **'The password must be 8 characters, including 1 uppercase letter, 1 number and 1 special character.'**
  String get passwordMustBe8Characters;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @continues.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continues;

  /// No description provided for @entered.
  ///
  /// In en, this message translates to:
  /// **'Entered'**
  String get entered;

  /// No description provided for @passwordReset.
  ///
  /// In en, this message translates to:
  /// **'Password Reset'**
  String get passwordReset;

  /// No description provided for @enterRegisterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your registered email address to reset your password'**
  String get enterRegisterEmailPassword;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @policies.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms & Conditions and Privacy Policy. Your data will be securely encrypted with TLS.'**
  String get policies;

  /// No description provided for @weJustSentYouAnEmailTo.
  ///
  /// In en, this message translates to:
  /// **'We just sent you an email to'**
  String get weJustSentYouAnEmailTo;

  /// No description provided for @whatsYourEmail.
  ///
  /// In en, this message translates to:
  /// **'What’s Your email?'**
  String get whatsYourEmail;

  /// No description provided for @enterTheEmailAddressYouWantToUseToRegisterWithCCP.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address you want to use to register with ComeComePay'**
  String get enterTheEmailAddressYouWantToUseToRegisterWithCCP;

  /// No description provided for @pleaseEnterAValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterAValidEmailAddress;

  /// No description provided for @haveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account?'**
  String get haveAnAccount;

  /// No description provided for @logInHere.
  ///
  /// In en, this message translates to:
  /// **'Log in here'**
  String get logInHere;

  /// No description provided for @newOtpSentToYourEmail.
  ///
  /// In en, this message translates to:
  /// **'New OTP sent to your email'**
  String get newOtpSentToYourEmail;

  /// No description provided for @failedToResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend OTP'**
  String get failedToResendOtp;

  /// No description provided for @pleaseFillAllOtpFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all OTP fields'**
  String get pleaseFillAllOtpFields;

  /// No description provided for @passwordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordCannotBeEmpty;

  /// No description provided for @passwordMustBeAtLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long'**
  String get passwordMustBeAtLeast8Characters;

  /// No description provided for @passwordMustContainUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain an uppercase letter'**
  String get passwordMustContainUppercase;

  /// No description provided for @passwordMustContainNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a number'**
  String get passwordMustContainNumber;

  /// No description provided for @passwordMustContainSpecial.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a special character'**
  String get passwordMustContainSpecial;

  /// No description provided for @pleaseConfirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmYourPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordSetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password set successfully!'**
  String get passwordSetSuccessfully;

  /// No description provided for @failedToSetPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to set password'**
  String get failedToSetPassword;

  /// No description provided for @referralCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Referral Code: '**
  String get referralCodeLabel;

  /// No description provided for @iAgreeWith.
  ///
  /// In en, this message translates to:
  /// **'I agree with '**
  String get iAgreeWith;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @messageCenter.
  ///
  /// In en, this message translates to:
  /// **'Message Center'**
  String get messageCenter;

  /// No description provided for @systemNotification.
  ///
  /// In en, this message translates to:
  /// **'System Notification'**
  String get systemNotification;

  /// No description provided for @messageDetail.
  ///
  /// In en, this message translates to:
  /// **'Message Detail'**
  String get messageDetail;

  /// No description provided for @dearUser.
  ///
  /// In en, this message translates to:
  /// **'Dear User'**
  String get dearUser;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @readAt.
  ///
  /// In en, this message translates to:
  /// **'Read At'**
  String get readAt;

  /// No description provided for @thankYouForUsingComeComePay.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using ComeComePay!'**
  String get thankYouForUsingComeComePay;

  /// No description provided for @searchTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Search token...'**
  String get searchTokenHint;

  /// No description provided for @selectNetwork.
  ///
  /// In en, this message translates to:
  /// **'Select a Network'**
  String get selectNetwork;

  /// No description provided for @balancePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get balancePlaceholder;

  /// No description provided for @usdBalancePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'\$0.00'**
  String get usdBalancePlaceholder;

  /// No description provided for @swapFrom.
  ///
  /// In en, this message translates to:
  /// **'Swap from'**
  String get swapFrom;

  /// No description provided for @tokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get tokenLabel;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @marketStatistics.
  ///
  /// In en, this message translates to:
  /// **'Market Statistics'**
  String get marketStatistics;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @sentStatus.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sentStatus;

  /// No description provided for @receiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receiveStatus;

  /// No description provided for @swapStatus.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swapStatus;

  /// No description provided for @applyVirtualCard.
  ///
  /// In en, this message translates to:
  /// **'Apply Virtual Card'**
  String get applyVirtualCard;

  /// No description provided for @cardInformation.
  ///
  /// In en, this message translates to:
  /// **'Card Information'**
  String get cardInformation;

  /// No description provided for @cardName.
  ///
  /// In en, this message translates to:
  /// **'Card Name'**
  String get cardName;

  /// No description provided for @cardOrganization.
  ///
  /// In en, this message translates to:
  /// **'Card Organization'**
  String get cardOrganization;

  /// No description provided for @cardFee.
  ///
  /// In en, this message translates to:
  /// **'Card Fee'**
  String get cardFee;

  /// No description provided for @fee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get fee;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @pleaseSelect.
  ///
  /// In en, this message translates to:
  /// **'Please select'**
  String get pleaseSelect;

  /// No description provided for @yourGateway.
  ///
  /// In en, this message translates to:
  /// **'Your Gateway'**
  String get yourGateway;

  /// No description provided for @toCrypto.
  ///
  /// In en, this message translates to:
  /// **'to Crypto'**
  String get toCrypto;

  /// No description provided for @simpleSecureSmooth.
  ///
  /// In en, this message translates to:
  /// **'Simple, Secure, Smooth'**
  String get simpleSecureSmooth;

  /// No description provided for @manageYour.
  ///
  /// In en, this message translates to:
  /// **'Manage Your '**
  String get manageYour;

  /// No description provided for @cryptoAsset.
  ///
  /// In en, this message translates to:
  /// **'Crypto Asset'**
  String get cryptoAsset;

  /// No description provided for @andPaymentsWithComePay.
  ///
  /// In en, this message translates to:
  /// **'And Payments with Come Pay'**
  String get andPaymentsWithComePay;

  /// No description provided for @createAPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a Password'**
  String get createAPassword;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @byRegisteringYouAccept.
  ///
  /// In en, this message translates to:
  /// **'By registering you accept our'**
  String get byRegisteringYouAccept;

  /// No description provided for @andPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get andPrivacyPolicy;

  /// No description provided for @yourDataWillBeSecure.
  ///
  /// In en, this message translates to:
  /// **'Your data will be security encrypted with TLS.'**
  String get yourDataWillBeSecure;

  /// No description provided for @originalFee.
  ///
  /// In en, this message translates to:
  /// **'Original Fee'**
  String get originalFee;

  /// No description provided for @actualPayment.
  ///
  /// In en, this message translates to:
  /// **'Actual Payment'**
  String get actualPayment;

  /// No description provided for @paymentRequired.
  ///
  /// In en, this message translates to:
  /// **'Payment Required'**
  String get paymentRequired;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful!'**
  String get paymentSuccessful;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPayment;

  /// No description provided for @amountToPay.
  ///
  /// In en, this message translates to:
  /// **'Amount to Pay'**
  String get amountToPay;

  /// No description provided for @selectCoupon.
  ///
  /// In en, this message translates to:
  /// **'Select Coupon'**
  String get selectCoupon;

  /// No description provided for @noCoupon.
  ///
  /// In en, this message translates to:
  /// **'No coupon'**
  String get noCoupon;

  /// No description provided for @applyCard.
  ///
  /// In en, this message translates to:
  /// **'Apply Card'**
  String get applyCard;

  /// No description provided for @failedToLoadCardFee.
  ///
  /// In en, this message translates to:
  /// **'Failed to load card fee'**
  String get failedToLoadCardFee;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @insufficient.
  ///
  /// In en, this message translates to:
  /// **'Insufficient'**
  String get insufficient;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @appUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'ComeComePay Upgrade'**
  String get appUpgradeTitle;

  /// No description provided for @upgradeAppButton.
  ///
  /// In en, this message translates to:
  /// **'Upgrade ComeComePay'**
  String get upgradeAppButton;

  /// No description provided for @updateDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Please update ComeComePay to the latest version. The version you are using is out of date and may stop working soon.'**
  String get updateDefaultMessage;

  /// No description provided for @pressAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press again to exit'**
  String get pressAgainToExit;

  /// No description provided for @moreButton.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreButton;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any transaction records yet'**
  String get noTransactionsYet;

  /// No description provided for @startFirstTransaction.
  ///
  /// In en, this message translates to:
  /// **'Start your first transaction'**
  String get startFirstTransaction;

  /// No description provided for @noCardsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No cards available, please apply for a card first'**
  String get noCardsAvailable;

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidAmount;

  /// No description provided for @pleaseSelectCard.
  ///
  /// In en, this message translates to:
  /// **'Please select a card'**
  String get pleaseSelectCard;

  /// No description provided for @balanceInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get balanceInsufficient;

  /// No description provided for @swapSuccess.
  ///
  /// In en, this message translates to:
  /// **'Swap successful'**
  String get swapSuccess;

  /// No description provided for @swapFailed.
  ///
  /// In en, this message translates to:
  /// **'Swap failed'**
  String get swapFailed;

  /// No description provided for @loadingFailed.
  ///
  /// In en, this message translates to:
  /// **'Loading failed'**
  String get loadingFailed;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @goBackButton.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBackButton;

  /// No description provided for @selectCard.
  ///
  /// In en, this message translates to:
  /// **'Select Card'**
  String get selectCard;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @swapPreview.
  ///
  /// In en, this message translates to:
  /// **'Swap Preview'**
  String get swapPreview;

  /// No description provided for @swapAmount.
  ///
  /// In en, this message translates to:
  /// **'Swap Amount'**
  String get swapAmount;

  /// No description provided for @netReceived.
  ///
  /// In en, this message translates to:
  /// **'Net Received'**
  String get netReceived;

  /// No description provided for @exchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get exchangeRate;

  /// No description provided for @feeRate.
  ///
  /// In en, this message translates to:
  /// **'Fee Rate'**
  String get feeRate;

  /// No description provided for @feeAmount.
  ///
  /// In en, this message translates to:
  /// **'Fee Amount'**
  String get feeAmount;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @confirmSwap.
  ///
  /// In en, this message translates to:
  /// **'Confirm Swap'**
  String get confirmSwap;

  /// No description provided for @pleaseEnterRecipientAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter recipient address'**
  String get pleaseEnterRecipientAddress;

  /// No description provided for @withdrawalFailed.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal failed'**
  String get withdrawalFailed;

  /// No description provided for @scanQRCodeInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code feature in development'**
  String get scanQRCodeInDevelopment;

  /// No description provided for @addressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get addressCopied;

  /// No description provided for @pleaseEnter6DigitCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter 6-digit code'**
  String get pleaseEnter6DigitCode;

  /// No description provided for @applicationFailed.
  ///
  /// In en, this message translates to:
  /// **'Application failed'**
  String get applicationFailed;

  /// No description provided for @availableCreditEstimate.
  ///
  /// In en, this message translates to:
  /// **'Available Credit Estimate'**
  String get availableCreditEstimate;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @getCardInfoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get card information'**
  String get getCardInfoFailed;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @cardApplicationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card application successful'**
  String get cardApplicationSuccess;

  /// No description provided for @cardApplicationFailed.
  ///
  /// In en, this message translates to:
  /// **'Card application failed'**
  String get cardApplicationFailed;

  /// No description provided for @cardApplicationProgress.
  ///
  /// In en, this message translates to:
  /// **'Card Application Progress'**
  String get cardApplicationProgress;

  /// No description provided for @cardApplicationFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Card application failed, please try again later'**
  String get cardApplicationFailedRetry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @waitingToProcess.
  ///
  /// In en, this message translates to:
  /// **'Waiting to process'**
  String get waitingToProcess;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @cardsCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully created {count} card(s)'**
  String cardsCreatedSuccessfully(Object count);

  /// No description provided for @recipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get recipient;

  /// No description provided for @sum.
  ///
  /// In en, this message translates to:
  /// **'Sum'**
  String get sum;

  /// No description provided for @gasFee.
  ///
  /// In en, this message translates to:
  /// **'Gas fee'**
  String get gasFee;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @textForRecipientOptional.
  ///
  /// In en, this message translates to:
  /// **'Text for the recipient (Optional)'**
  String get textForRecipientOptional;

  /// No description provided for @detailTransaction.
  ///
  /// In en, this message translates to:
  /// **'Detail Transaction'**
  String get detailTransaction;

  /// No description provided for @confirmAndSend.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Send'**
  String get confirmAndSend;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @referralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral Code'**
  String get referralCode;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @otpSend.
  ///
  /// In en, this message translates to:
  /// **'OTP Send'**
  String get otpSend;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @noAvailableCurrencies.
  ///
  /// In en, this message translates to:
  /// **'No available currencies'**
  String get noAvailableCurrencies;

  /// No description provided for @authorizationRecord.
  ///
  /// In en, this message translates to:
  /// **'Authorization Record'**
  String get authorizationRecord;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid Input'**
  String get invalidInput;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailed;

  /// No description provided for @enterPasswordToConfirmTransaction.
  ///
  /// In en, this message translates to:
  /// **'Enter your password \nto confirm the transaction'**
  String get enterPasswordToConfirmTransaction;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @spentCurrency.
  ///
  /// In en, this message translates to:
  /// **'Spent Currency'**
  String get spentCurrency;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// No description provided for @transactionTime.
  ///
  /// In en, this message translates to:
  /// **'Transaction Time'**
  String get transactionTime;

  /// No description provided for @completionTime.
  ///
  /// In en, this message translates to:
  /// **'Completion Time'**
  String get completionTime;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @txHash.
  ///
  /// In en, this message translates to:
  /// **'Tx Hash'**
  String get txHash;

  /// No description provided for @swapTo.
  ///
  /// In en, this message translates to:
  /// **'Swap To'**
  String get swapTo;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @transactionList.
  ///
  /// In en, this message translates to:
  /// **'Transaction List'**
  String get transactionList;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No Transactions'**
  String get noTransactions;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load Failed'**
  String get loadFailed;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @noMoreData.
  ///
  /// In en, this message translates to:
  /// **'No more data'**
  String get noMoreData;

  /// No description provided for @referralCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Referral Code (Optional)'**
  String get referralCodeOptional;

  /// No description provided for @enterReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Enter referral code if you have one'**
  String get enterReferralCode;

  /// No description provided for @myWalletAddress.
  ///
  /// In en, this message translates to:
  /// **'My {currency} wallet address:\n{address}'**
  String myWalletAddress(Object address, Object currency);

  /// No description provided for @walletAddress.
  ///
  /// In en, this message translates to:
  /// **'Wallet Address'**
  String get walletAddress;

  /// No description provided for @receiveNetworkWarning.
  ///
  /// In en, this message translates to:
  /// **'Only support receiving {currency} network assets, other network assets cannot be recovered.'**
  String receiveNetworkWarning(Object currency);

  /// No description provided for @shareAddress.
  ///
  /// In en, this message translates to:
  /// **'Share Address'**
  String get shareAddress;

  /// No description provided for @noReceiveAddress.
  ///
  /// In en, this message translates to:
  /// **'No Receive Address'**
  String get noReceiveAddress;

  /// No description provided for @coinNoAddressGenerated.
  ///
  /// In en, this message translates to:
  /// **'No address generated for this coin'**
  String get coinNoAddressGenerated;

  /// No description provided for @receiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receiveTitle;

  /// No description provided for @receiveCoin.
  ///
  /// In en, this message translates to:
  /// **'Receive {currency}'**
  String receiveCoin(Object currency);

  /// No description provided for @recipientAddress.
  ///
  /// In en, this message translates to:
  /// **'Recipient Address'**
  String get recipientAddress;

  /// No description provided for @enterOrPasteAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter or paste address'**
  String get enterOrPasteAddress;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @balanceAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available: {balance} {symbol}'**
  String balanceAvailable(Object balance, Object symbol);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @withdrawFailedWithError.
  ///
  /// In en, this message translates to:
  /// **'Withdraw failed: {error}'**
  String withdrawFailedWithError(Object error);

  /// No description provided for @withdrawHistory.
  ///
  /// In en, this message translates to:
  /// **'Withdraw History'**
  String get withdrawHistory;

  /// No description provided for @noWithdrawHistory.
  ///
  /// In en, this message translates to:
  /// **'No withdraw history'**
  String get noWithdrawHistory;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @withdrawRecordPrefix.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Record #'**
  String get withdrawRecordPrefix;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @typeDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get typeDeposit;

  /// No description provided for @typeWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get typeWithdraw;

  /// No description provided for @typeSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get typeSwap;

  /// No description provided for @typeCardFee.
  ///
  /// In en, this message translates to:
  /// **'Card Fee'**
  String get typeCardFee;

  /// No description provided for @typeCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get typeCommission;

  /// No description provided for @typeTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get typeTransfer;

  /// No description provided for @typeFee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get typeFee;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusCredited.
  ///
  /// In en, this message translates to:
  /// **'Credited'**
  String get statusCredited;

  /// No description provided for @availableAmountEstimateDesc.
  ///
  /// In en, this message translates to:
  /// **'Estimated available amount after transaction fees and exchange rate fluctuations'**
  String get availableAmountEstimateDesc;

  /// No description provided for @lockCard.
  ///
  /// In en, this message translates to:
  /// **'Lock Card'**
  String get lockCard;

  /// No description provided for @cardAuthorization.
  ///
  /// In en, this message translates to:
  /// **'Card Authorization'**
  String get cardAuthorization;

  /// No description provided for @applyPhysicalCard.
  ///
  /// In en, this message translates to:
  /// **'Apply Physical Card'**
  String get applyPhysicalCard;

  /// No description provided for @reportLoss.
  ///
  /// In en, this message translates to:
  /// **'Report Loss'**
  String get reportLoss;

  /// No description provided for @bill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get bill;

  /// No description provided for @expiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date: '**
  String get expiryDateLabel;

  /// No description provided for @cvvLabel.
  ///
  /// In en, this message translates to:
  /// **'CVV: '**
  String get cvvLabel;

  /// No description provided for @transactionDefault.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transactionDefault;

  /// No description provided for @billDetail.
  ///
  /// In en, this message translates to:
  /// **'Bill Details'**
  String get billDetail;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @copySuccess.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copySuccess;

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @myInvitation.
  ///
  /// In en, this message translates to:
  /// **'My Invitation'**
  String get myInvitation;

  /// No description provided for @totalFriends.
  ///
  /// In en, this message translates to:
  /// **'Total Friends'**
  String get totalFriends;

  /// No description provided for @level1Friends.
  ///
  /// In en, this message translates to:
  /// **'Level 1 Friends'**
  String get level1Friends;

  /// No description provided for @level2Friends.
  ///
  /// In en, this message translates to:
  /// **'Level 2 Friends'**
  String get level2Friends;

  /// No description provided for @myFriends.
  ///
  /// In en, this message translates to:
  /// **'My Friends'**
  String get myFriends;

  /// No description provided for @totalCardRebate.
  ///
  /// In en, this message translates to:
  /// **'Total Card Rebate'**
  String get totalCardRebate;

  /// No description provided for @level1CardRebate.
  ///
  /// In en, this message translates to:
  /// **'Level 1 Card Rebate'**
  String get level1CardRebate;

  /// No description provided for @level2CardRebate.
  ///
  /// In en, this message translates to:
  /// **'Level 2 Card Rebate'**
  String get level2CardRebate;

  /// No description provided for @cardRebateAction.
  ///
  /// In en, this message translates to:
  /// **'Card Rebate'**
  String get cardRebateAction;

  /// No description provided for @totalTransactionRebate.
  ///
  /// In en, this message translates to:
  /// **'Total Transaction Rebate'**
  String get totalTransactionRebate;

  /// No description provided for @level1TransactionRebate.
  ///
  /// In en, this message translates to:
  /// **'Level 1 Transaction Rebate'**
  String get level1TransactionRebate;

  /// No description provided for @level2TransactionRebate.
  ///
  /// In en, this message translates to:
  /// **'Level 2 Transaction Rebate'**
  String get level2TransactionRebate;

  /// No description provided for @transactionRebateAction.
  ///
  /// In en, this message translates to:
  /// **'Transaction Rebate'**
  String get transactionRebateAction;

  /// No description provided for @level1FriendsTab.
  ///
  /// In en, this message translates to:
  /// **'Level 1 Friends'**
  String get level1FriendsTab;

  /// No description provided for @level2FriendsTab.
  ///
  /// In en, this message translates to:
  /// **'Level 2 Friends'**
  String get level2FriendsTab;

  /// No description provided for @registrationTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Registration Time: '**
  String get registrationTimeLabel;

  /// No description provided for @level1CardTab.
  ///
  /// In en, this message translates to:
  /// **'Level 1 Card'**
  String get level1CardTab;

  /// No description provided for @level2CardTab.
  ///
  /// In en, this message translates to:
  /// **'Level 2 Card'**
  String get level2CardTab;

  /// No description provided for @level1TransactionTab.
  ///
  /// In en, this message translates to:
  /// **'Level 1 Transaction'**
  String get level1TransactionTab;

  /// No description provided for @level2TransactionTab.
  ///
  /// In en, this message translates to:
  /// **'Level 2 Transaction'**
  String get level2TransactionTab;

  /// No description provided for @payFee.
  ///
  /// In en, this message translates to:
  /// **'Pay Fee'**
  String get payFee;

  /// No description provided for @transactionSettlementAmount.
  ///
  /// In en, this message translates to:
  /// **'Settlement Amount'**
  String get transactionSettlementAmount;

  /// No description provided for @rebate.
  ///
  /// In en, this message translates to:
  /// **'Rebate'**
  String get rebate;

  /// No description provided for @consumptionRebate.
  ///
  /// In en, this message translates to:
  /// **'Consumption Rebate'**
  String get consumptionRebate;

  /// No description provided for @cardOpening.
  ///
  /// In en, this message translates to:
  /// **'Card Opening'**
  String get cardOpening;

  /// No description provided for @consumption.
  ///
  /// In en, this message translates to:
  /// **'Consumption'**
  String get consumption;

  /// No description provided for @cardOpeningTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Open Time:'**
  String get cardOpeningTimeLabel;

  /// No description provided for @transactionSettlementTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Settlement Time:'**
  String get transactionSettlementTimeLabel;

  /// No description provided for @paymentCompletedKycPrompt.
  ///
  /// In en, this message translates to:
  /// **'You have completed the card fee payment. You can now proceed with KYC verification.'**
  String get paymentCompletedKycPrompt;

  /// No description provided for @goToVerify.
  ///
  /// In en, this message translates to:
  /// **'Go to Verify'**
  String get goToVerify;

  /// No description provided for @couponDiscount.
  ///
  /// In en, this message translates to:
  /// **'Coupon Discount'**
  String get couponDiscount;

  /// No description provided for @failToLoadCardFeeConfig.
  ///
  /// In en, this message translates to:
  /// **'Failed to load card fee config'**
  String get failToLoadCardFeeConfig;

  /// No description provided for @failToLoadPaymentCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Failed to load payment currencies'**
  String get failToLoadPaymentCurrencies;

  /// No description provided for @noPaymentCurrenciesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No payment currencies available'**
  String get noPaymentCurrenciesAvailable;

  /// No description provided for @pleaseSelectPaymentCurrency.
  ///
  /// In en, this message translates to:
  /// **'Please select a payment currency'**
  String get pleaseSelectPaymentCurrency;

  /// No description provided for @failToCreatePayment.
  ///
  /// In en, this message translates to:
  /// **'Failed to create payment'**
  String get failToCreatePayment;

  /// No description provided for @accountNotification.
  ///
  /// In en, this message translates to:
  /// **'Account Notification'**
  String get accountNotification;

  /// No description provided for @systemAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'System Announcement'**
  String get systemAnnouncement;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markAllAsRead;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @announcementDetail.
  ///
  /// In en, this message translates to:
  /// **'Announcement Detail'**
  String get announcementDetail;

  /// No description provided for @notificationDetail.
  ///
  /// In en, this message translates to:
  /// **'Notification Detail'**
  String get notificationDetail;

  /// No description provided for @contentDetail.
  ///
  /// In en, this message translates to:
  /// **'Content Detail'**
  String get contentDetail;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get noNotifications;

  /// No description provided for @noAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No Announcements'**
  String get noAnnouncements;

  /// No description provided for @loadMoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Load More Failed'**
  String get loadMoreFailed;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get refreshing;

  /// No description provided for @invalidDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid Date'**
  String get invalidDate;

  /// No description provided for @publishTime.
  ///
  /// In en, this message translates to:
  /// **'Publish Time'**
  String get publishTime;

  /// No description provided for @authorizationList.
  ///
  /// In en, this message translates to:
  /// **'Authorization List'**
  String get authorizationList;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature under development'**
  String get featureComingSoon;

  /// No description provided for @unlockCard.
  ///
  /// In en, this message translates to:
  /// **'Unlock Card'**
  String get unlockCard;

  /// No description provided for @cardLockedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Card locked successfully'**
  String get cardLockedSuccessfully;

  /// No description provided for @cardUnlockedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Card unlocked successfully'**
  String get cardUnlockedSuccessfully;

  /// No description provided for @failedToLockCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to lock card'**
  String get failedToLockCard;

  /// No description provided for @failedToUnlockCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to unlock card'**
  String get failedToUnlockCard;

  /// No description provided for @confirmLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock Card'**
  String get confirmLockTitle;

  /// No description provided for @confirmLockContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to lock this card? You will not be able to use it for payments until you unlock it.'**
  String get confirmLockContent;

  /// No description provided for @confirmUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Card'**
  String get confirmUnlockTitle;

  /// No description provided for @confirmUnlockContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unlock this card?'**
  String get confirmUnlockContent;

  /// No description provided for @cardSecurityInfo.
  ///
  /// In en, this message translates to:
  /// **'Card Security Info'**
  String get cardSecurityInfo;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @cvvCode.
  ///
  /// In en, this message translates to:
  /// **'CVV Code'**
  String get cvvCode;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'PIN Code'**
  String get pinCode;

  /// No description provided for @insufficientBalanceForCoin.
  ///
  /// In en, this message translates to:
  /// **'{coin} Balance Insufficient'**
  String insufficientBalanceForCoin(Object coin);

  /// No description provided for @failedToGetPreview.
  ///
  /// In en, this message translates to:
  /// **'Failed to get preview'**
  String get failedToGetPreview;

  /// No description provided for @swapFailedWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Swap failed: {message}'**
  String swapFailedWithMessage(Object message);

  /// No description provided for @swapHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap History'**
  String get swapHistoryTitle;

  /// No description provided for @noSwapHistory.
  ///
  /// In en, this message translates to:
  /// **'No swap history'**
  String get noSwapHistory;

  /// No description provided for @consumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get consumed;

  /// No description provided for @transferToCard.
  ///
  /// In en, this message translates to:
  /// **'Transfer to card'**
  String get transferToCard;

  /// No description provided for @transferFromCard.
  ///
  /// In en, this message translates to:
  /// **'Transfer from card'**
  String get transferFromCard;

  /// No description provided for @rechargeToCard.
  ///
  /// In en, this message translates to:
  /// **'(Recharge to card)'**
  String get rechargeToCard;

  /// No description provided for @withdrawFromCard.
  ///
  /// In en, this message translates to:
  /// **'(Withdraw from card)'**
  String get withdrawFromCard;

  /// No description provided for @swapAction.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swapAction;

  /// No description provided for @getAmount.
  ///
  /// In en, this message translates to:
  /// **'Get'**
  String get getAmount;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get enterAmount;

  /// No description provided for @gettingRate.
  ///
  /// In en, this message translates to:
  /// **'Getting rate...'**
  String get gettingRate;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @reviewing.
  ///
  /// In en, this message translates to:
  /// **'Reviewing'**
  String get reviewing;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get underReview;

  /// No description provided for @kycReviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Your KYC verification is currently under review. This usually takes a few minutes.'**
  String get kycReviewDesc;

  /// No description provided for @verifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Verify Failed'**
  String get verifyFailed;

  /// No description provided for @verificationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Failed'**
  String get verificationFailedTitle;

  /// No description provided for @verificationFailedReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String verificationFailedReason(Object reason);

  /// No description provided for @verificationFailedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your verification failed. Please try again.'**
  String get verificationFailedDesc;

  /// No description provided for @retryVerification.
  ///
  /// In en, this message translates to:
  /// **'Retry Verification'**
  String get retryVerification;

  /// No description provided for @verificationPassed.
  ///
  /// In en, this message translates to:
  /// **'Verification Passed'**
  String get verificationPassed;

  /// No description provided for @receiveCardEligibilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You are eligible to receive your card.'**
  String get receiveCardEligibilityDesc;

  /// No description provided for @receiveCardNow.
  ///
  /// In en, this message translates to:
  /// **'Receive Card Now'**
  String get receiveCardNow;

  /// No description provided for @verificationRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Required'**
  String get verificationRequiredTitle;

  /// No description provided for @kycRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'You need to complete KYC verification before issuing a card.'**
  String get kycRequiredDesc;

  /// No description provided for @transactionRef.
  ///
  /// In en, this message translates to:
  /// **'Transaction Ref'**
  String get transactionRef;

  /// No description provided for @paymentVerificationTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Payment verification timed out. Please try again.'**
  String get paymentVerificationTimedOut;

  /// No description provided for @paymentNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Payment not completed: {status}'**
  String paymentNotCompleted(Object status);

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed: {error}'**
  String paymentFailed(Object error);

  /// No description provided for @failedToReceiveCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to receive card: {error}'**
  String failedToReceiveCard(Object error);

  /// No description provided for @minFee.
  ///
  /// In en, this message translates to:
  /// **'Min Fee'**
  String get minFee;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// No description provided for @creationTime.
  ///
  /// In en, this message translates to:
  /// **'Creation Time'**
  String get creationTime;

  /// No description provided for @maxCardLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Each account can claim a maximum of {count} cards'**
  String maxCardLimitReached(Object count);

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @surnameLabel.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surnameLabel;

  /// No description provided for @enterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Name (uppercase English only)'**
  String get enterNameHint;

  /// No description provided for @enterSurnameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Surname (uppercase English only)'**
  String get enterSurnameHint;

  /// No description provided for @mobilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile Phone'**
  String get mobilePhoneLabel;

  /// No description provided for @enterMobileNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get enterMobileNumberHint;

  /// No description provided for @countryRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Country / Region'**
  String get countryRegionLabel;

  /// No description provided for @stateProvinceLabel.
  ///
  /// In en, this message translates to:
  /// **'State / Province'**
  String get stateProvinceLabel;

  /// No description provided for @enterStateProvinceHint.
  ///
  /// In en, this message translates to:
  /// **'Enter State / Province'**
  String get enterStateProvinceHint;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @enterCityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter City'**
  String get enterCityHint;

  /// No description provided for @detailedAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Detailed Address'**
  String get detailedAddressLabel;

  /// No description provided for @enterDetailedAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Detailed Address'**
  String get enterDetailedAddressHint;

  /// No description provided for @postCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Post Code'**
  String get postCodeLabel;

  /// No description provided for @enterPostCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Post Code'**
  String get enterPostCodeHint;

  /// No description provided for @kycSolicitationDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree that you are accessing this App and its service voluntarily, without any active promotion or solicitation by Come Come Pay'**
  String get kycSolicitationDisclaimer;

  /// No description provided for @pleaseEnterField.
  ///
  /// In en, this message translates to:
  /// **'Please enter {field}'**
  String pleaseEnterField(Object field);

  /// No description provided for @onlyUppercaseEnglishAllowed.
  ///
  /// In en, this message translates to:
  /// **'{field} must contain only uppercase English letters (A-Z).\n\nCurrent value: {value}'**
  String onlyUppercaseEnglishAllowed(Object field, Object value);

  /// No description provided for @kycPaymentRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'You need to complete the card fee payment before proceeding with KYC verification.'**
  String get kycPaymentRequiredDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'id', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
