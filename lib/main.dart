import 'package:comecomepay/views/homes/AboutUsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:comecomepay/utils/constants.dart';
import 'package:comecomepay/utils/service_locator.dart';
import 'package:comecomepay/utils/app_theme.dart';
import 'package:comecomepay/viewmodels/login_viewmodel.dart';
import 'package:comecomepay/viewmodels/signup_viewmodel.dart';
import 'package:comecomepay/viewmodels/registration_otp_viewmodel.dart';
import 'package:comecomepay/viewmodels/set_transaction_password_viewmodel.dart';
import 'package:comecomepay/viewmodels/messageservicecenter_viewmodel.dart';
import 'package:comecomepay/viewmodels/notification_viewmodel.dart';
import 'package:comecomepay/viewmodels/profile_screen_viewmodel.dart';
import 'package:comecomepay/viewmodels/home_screen_viewmodel.dart';
import 'package:comecomepay/viewmodels/locale_provider.dart';
import 'package:comecomepay/viewmodels/transaction_record_viewmodel.dart';
import 'package:comecomepay/viewmodels/card_viewmodel.dart';
import 'package:comecomepay/viewmodels/wallet_viewmodel.dart';
import 'package:comecomepay/viewmodels/send_pdp_detail_viewmodel.dart';
import 'package:comecomepay/viewmodels/crypto_viewmodel.dart';
import 'package:comecomepay/viewmodels/swap_viewmodel.dart';
import 'package:comecomepay/models/responses/login_response_model.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/l10n/app_localizations.dart';

// Import all screen classes
import 'package:comecomepay/views/onboarding/SplashScreen.dart';
import 'package:comecomepay/views/onboarding/onboarding_screen.dart';
import 'package:comecomepay/views/signup/login/LoginScreen.dart';
import 'package:comecomepay/views/signup/login/LoginOtpScreen.dart';
import 'package:comecomepay/views/signup/login/LoginWelcomeBackScreen.dart';
import 'package:comecomepay/views/signup/register/CreateAccountScreen.dart';
import 'package:comecomepay/views/signup/register/CreateAccountEmailScreen.dart';
import 'package:comecomepay/views/signup/register/CreateAccountConfrimEmailScreen.dart';
import 'package:comecomepay/views/signup/register/CreateAccountOtpConfirmScreen.dart';
import 'package:comecomepay/views/signup/register/CreateAccountPasswordScreen.dart';
import 'package:comecomepay/views/signup/register/CreateAccountVerificationScreen.dart';
import 'package:comecomepay/views/resetpassword/ResetPasswordScreen.dart';
import 'package:comecomepay/views/resetpassword/ResetPasswordOtpScreen.dart';
import 'package:comecomepay/views/resetpassword/ResetPasswordConfirmEmailScreen.dart';
import 'package:comecomepay/views/resetpassword/ResetPasswordCreatePasswordScreen.dart';
import 'package:comecomepay/views/resetpassword/CreatePasswordVerificationScreen.dart';
import 'package:comecomepay/views/homes/HomeAdapterScreen.dart';
import 'package:comecomepay/views/homes/NotificationScreen.dart';
import 'package:comecomepay/views/homes/ReceiveScreen.dart';
import 'package:comecomepay/views/homes/ReceiveDetailScreen.dart';
import 'package:comecomepay/views/homes/SendScreen.dart';
import 'package:comecomepay/views/homes/SendPdp.dart';
import 'package:comecomepay/views/homes/SendPdpDetail.dart';
import 'package:comecomepay/views/homes/SendPdpDetailOtp.dart';
import 'package:comecomepay/views/homes/SendPdpDetailDone.dart';
import 'package:comecomepay/views/homes/WithdrawHistoryPage.dart';
import 'package:comecomepay/views/homes/TransactionHistoryHistory.dart';
import 'package:comecomepay/views/homes/SwapScreen.dart';
import 'package:comecomepay/views/homes/SwapDetailPage.dart';
import 'package:comecomepay/views/homes/SwapHistoryPage.dart';
import 'package:comecomepay/views/homes/WaletAccountCardDetailScreen.dart';
import 'package:comecomepay/views/homes/CardSelectDocumentScreen.dart';
import 'package:comecomepay/views/homes/CardKycScreen.dart';
import 'package:comecomepay/views/homes/CardOtpScreen.dart';
import 'package:comecomepay/views/homes/CardCompliteScreen.dart';
import 'package:comecomepay/views/homes/CardVerifyIdentityScreen.dart';
import 'package:comecomepay/views/homes/CardSelvieVerificationScreen.dart';
import 'package:comecomepay/views/homes/CardVerificationStatusScreen.dart';
import 'package:comecomepay/views/homes/CardCompliteStatusScreen.dart';
import 'package:comecomepay/views/homes/CardVerificationProfilScreen.dart';
import 'package:comecomepay/views/homes/CardApplyScreen.dart';
import 'package:comecomepay/views/homes/CardCompliteApplyScreen.dart';
import 'package:comecomepay/views/homes/CardVerificationScreen.dart';
import 'package:comecomepay/views/homes/ProfilKycScreen.dart';
import 'package:comecomepay/views/homes/SecurityScreen.dart'
    show Securityscreen;

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('zh'),
    const Locale('ar'),
  ];
}

void main() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Open boxes
  await Hive.openBox('settings');

  // Register Hive adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(LoginResponseModelAdapter());

  // Initialize Hive storage service
  await HiveStorageService.init();

  // Initialize service locator
  setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Global navigator key for navigation from ViewModels
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>(
          create: (context) => LocaleProvider()..init(),
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => getIt<LoginViewModel>(),
        ),
        ChangeNotifierProvider<SignupViewModel>(
          create: (context) => getIt<SignupViewModel>(),
        ),
        ChangeNotifierProvider<RegistrationOtpViewModel>(
          create: (context) => getIt<RegistrationOtpViewModel>(),
        ),
        ChangeNotifierProvider<SetTransactionPasswordViewModel>(
          create: (context) => getIt<SetTransactionPasswordViewModel>(),
        ),
        ChangeNotifierProvider<MessageServiceCenterViewModel>(
          create: (context) => getIt<MessageServiceCenterViewModel>(),
        ),
        ChangeNotifierProvider<NotificationViewModel>(
          create: (context) => getIt<NotificationViewModel>(),
        ),
        ChangeNotifierProvider<ProfileScreenViewModel>(
          create: (context) => getIt<ProfileScreenViewModel>(),
        ),
        ChangeNotifierProvider<HomeScreenViewModel>(
          create: (context) => getIt<HomeScreenViewModel>(),
        ),
        ChangeNotifierProvider<TransactionRecordViewModel>(
          create: (context) => TransactionRecordViewModel(),
        ),
        ChangeNotifierProvider<CardViewModel>(
          create: (context) => CardViewModel(),
        ),
        ChangeNotifierProvider<WalletViewModel>(
          create: (context) => WalletViewModel(),
        ),
        ChangeNotifierProvider<SendPdpDetailViewModel>(
          create: (context) => SendPdpDetailViewModel(),
        ),
        ChangeNotifierProvider<CryptoViewModel>(
          create: (context) => getIt<CryptoViewModel>(),
        ),
        ChangeNotifierProvider<SwapViewModel>(
          create: (context) => getIt<SwapViewModel>(),
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Consumer<LocaleProvider>(
          builder: (context, localeProvider, child) {
            return MaterialApp(
              title: 'Come Come Pay',
              theme: AppTheme.lightTheme,
              locale: localeProvider.locale,
              supportedLocales: L10n.all,
              localeResolutionCallback: (locale, supportedLocales) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale?.languageCode) {
                    return supportedLocale;
                  }
                }
                return supportedLocales.first;
              },
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              navigatorKey: navigatorKey,
              initialRoute: '/',
              routes: {
                '/': (context) => const SplashScreen(),
                '/onboarding_screen': (context) => const OnboardingScreen(),
                /* Start route login screen package */
                '/login_screen': (context) => const LoginScreen(),
                '/login_otp_screen': (context) => const LoginOtpScreen(),
                '/login_welcomback_screen': (context) =>
                    const LoginWelcomeBackScreen(),
                /* End route login screen package */

                /* Start route Register screen package */
                '/create_account': (context) => const CreateAccountScreen(),
                '/create_account_email': (context) =>
                    const CreateAccountEmailScreen(),
                '/create_account_confirm_email': (context) =>
                    const CreateAccountConfrimEmailScreen(),
                '/create_account_otp_confirm': (context) =>
                    const CreateAccountOtpConfirmScreen(),
                '/create_account_password': (context) =>
                    const CreateAccountPasswordScreen(),
                '/create_account_verification': (context) =>
                    const CreateAccountVerificationScreen(),
                '/otp_verification': (context) => const LoginOtpScreen(),
                /* End route Register screen package */

                /* Start route Reset Password screen package */
                '/ResetPasswordScreen': (context) =>
                    const ResetPasswordScreen(),
                '/ResetPasswordOtpScreen': (context) =>
                    const ResetPasswordOtpScreen(),
                '/ResetPasswordConfirmEmailScreen': (context) =>
                    const ResetPasswordConfirmEmailScreen(),
                '/ResetPasswordCreatePasswordScreen': (context) =>
                    const ResetPasswordCreatePasswordScreen(),
                '/ResetPasswordCreatePasswordVerificationScreen': (context) =>
                    const CreatePasswordVerificationScreen(),
                /* End route Reset Password screen package */

                /* Start home page */
                '/home': (context) => const MyHomePage(),
                '/NotificationScreen': (context) => const NotificationScreen(),
                '/TokenReceiveScreen': (context) => const TokenReceiveScreen(),
                '/ReceiveDetailScreen': (context) =>
                    const ReceiveDetailScreen(),
                '/SendScreen': (context) => const Sendscreen(),
                '/SendPdp': (context) => const SendPdp(),
                '/SendPdpDetail': (context) => const SendPdpDetail(),
                '/SendPdpDetailOtp': (context) => const SendPdpDetailOtp(),
                '/SendPdpDetailDone': (context) => const SendPdpDetailDone(),
                '/WithdrawHistory': (context) => const WithdrawHistoryPage(),
                '/TransactionHistoryHistory': (context) =>
                    const TransactionHistoryHistory(availableCurrencies: []),
                '/SwapScreen': (context) => const SwapScreen(),
                '/SwapDetailScreen': (context) => const SwapDetailPage(),
                '/SwapHistory': (context) => const SwapHistoryPage(),
                '/WaletAccountCardDetailScreen': (context) =>
                    const WaletAccountCardDetailScreen(),
                '/Cardselectdocumentscreen': (context) =>
                    const Cardselectdocumentscreen(),
                '/CardKycScreen': (context) => const CardKycScreen(),
                '/CardVerificationScreen': (context) =>
                    const Cardverificationscreen(),
                '/CardOtpScreen': (context) => CardOtpScreen(),
                '/CardCompliteScreen': (context) => const CardCompliteScreen(),
                '/CardVerifyIdentityScreen': (context) =>
                    const CardVerifyIdentityScreen(),
                '/Cardselvieverificationscreen': (context) =>
                    const Cardselvieverificationscreen(),
                '/CardVerificationStatusScreen': (context) =>
                    const CardVerificationStatusScreen(),
                '/CardCompliteStatusScreenState': (context) =>
                    const CardCompliteStatusScreen(),
                '/CardVerificationProfilScreen': (context) =>
                    const CardVerificationProfilScreen(),
                '/CardApplyCardScreen': (context) =>
                    const CardApplyCardScreen(),
                '/CardCompliteApplyScreen': (context) =>
                    const CardCompliteApplyScreen(),
                '/Profilkycscreen': (context) => const Profilkycscreen(),
                '/security': (context) => const Securityscreen(),
                '/aboutus': (context) => const AboutUsScreen(),
                /* End home page */
              },
            );
          },
        ),
      ),
    );
  }
}
