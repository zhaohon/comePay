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
  /// **'Total Assets 👁️'**
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
  /// **'Enter the email address you want to use to register with CCP'**
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
