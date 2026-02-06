import 'package:flutter/material.dart';
import 'package:Demo/views/homes/AboutUsScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:Demo/utils/service_locator.dart';
import 'package:Demo/utils/app_theme.dart';
import 'package:Demo/viewmodels/login_viewmodel.dart';
import 'package:Demo/viewmodels/signup_viewmodel.dart';
import 'package:Demo/viewmodels/registration_otp_viewmodel.dart';
import 'package:Demo/viewmodels/set_transaction_password_viewmodel.dart';
import 'package:Demo/viewmodels/messageservicecenter_viewmodel.dart';
import 'package:Demo/viewmodels/notification_viewmodel.dart';
import 'package:Demo/viewmodels/profile_screen_viewmodel.dart';
import 'package:Demo/viewmodels/home_screen_viewmodel.dart';
import 'package:Demo/viewmodels/locale_provider.dart';
import 'package:Demo/viewmodels/transaction_record_viewmodel.dart';
import 'package:Demo/viewmodels/unified_transaction_viewmodel.dart';
import 'package:Demo/viewmodels/card_viewmodel.dart';
import 'package:Demo/viewmodels/wallet_viewmodel.dart';
import 'package:Demo/viewmodels/send_pdp_detail_viewmodel.dart';
import 'package:Demo/viewmodels/crypto_viewmodel.dart';
import 'package:Demo/viewmodels/swap_viewmodel.dart';
import 'package:Demo/models/responses/login_response_model.dart';
import 'package:Demo/services/hive_storage_service.dart';
import 'package:Demo/l10n/app_localizations.dart';

// Import all screen classes
import 'package:Demo/views/onboarding/SplashScreen.dart';
import 'package:Demo/views/onboarding/onboarding_screen.dart';
import 'package:Demo/views/signup/login/LoginScreen.dart';
import 'package:Demo/views/signup/login/LoginOtpScreen.dart';
import 'package:Demo/views/signup/login/LoginWelcomeBackScreen.dart';
import 'package:Demo/views/signup/register/CreateAccountScreen.dart';
import 'package:Demo/views/signup/register/CreateAccountEmailScreen.dart';
import 'package:Demo/views/signup/register/CreateAccountConfrimEmailScreen.dart';
import 'package:Demo/views/signup/register/CreateAccountOtpConfirmScreen.dart';
import 'package:Demo/views/signup/register/CreateAccountPasswordScreen.dart';
import 'package:Demo/views/signup/register/CreateAccountVerificationScreen.dart';
import 'package:Demo/views/resetpassword/ResetPasswordScreen.dart';
import 'package:Demo/views/resetpassword/ResetPasswordOtpScreen.dart';
import 'package:Demo/views/resetpassword/ResetPasswordConfirmEmailScreen.dart';
import 'package:Demo/views/resetpassword/ResetPasswordCreatePasswordScreen.dart';
import 'package:Demo/views/resetpassword/CreatePasswordVerificationScreen.dart';
import 'package:Demo/views/homes/HomeAdapterScreen.dart';
import 'package:Demo/views/homes/NotificationScreen.dart';
import 'package:Demo/views/homes/ReceiveScreen.dart';
import 'package:Demo/views/homes/ReceiveDetailScreen.dart';
import 'package:Demo/views/homes/SendScreen.dart';
import 'package:Demo/views/homes/SendPdp.dart';
import 'package:Demo/views/homes/SendPdpDetail.dart';
import 'package:Demo/views/homes/SendPdpDetailOtp.dart';
import 'package:Demo/views/homes/SendPdpDetailDone.dart';
import 'package:Demo/views/homes/WithdrawHistoryPage.dart';
import 'package:Demo/views/homes/TransactionHistoryHistory.dart';
import 'package:Demo/views/homes/SwapScreen.dart';
import 'package:Demo/views/homes/SwapDetailPage.dart';
import 'package:Demo/views/homes/SwapHistoryPage.dart';
import 'package:Demo/views/homes/WaletAccountCardDetailScreen.dart';
import 'package:Demo/views/homes/CardSelectDocumentScreen.dart';
import 'package:Demo/views/homes/CardKycScreen.dart';
import 'package:Demo/views/homes/CardOtpScreen.dart';
import 'package:Demo/views/homes/CardCompliteScreen.dart';
import 'package:Demo/views/homes/CardVerifyIdentityScreen.dart';
import 'package:Demo/views/homes/CardSelvieVerificationScreen.dart';
import 'package:Demo/views/homes/CardVerificationStatusScreen.dart';
import 'package:Demo/views/homes/CardCompliteStatusScreen.dart';
import 'package:Demo/views/homes/CardVerificationProfilScreen.dart';
import 'package:Demo/views/homes/CardApplyScreen.dart';
import 'package:Demo/views/homes/CardCompliteApplyScreen.dart';
import 'package:Demo/views/homes/CardVerificationScreen.dart';
import 'package:Demo/views/homes/ProfilKycScreen.dart';
import 'package:Demo/views/homes/SecurityScreen.dart' show Securityscreen;
import 'package:Demo/views/debug/VersionUpdateTestScreen.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Global navigator key for navigation from ViewModels
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
        ChangeNotifierProvider<UnifiedTransactionViewModel>(
          create: (context) => UnifiedTransactionViewModel(),
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
              debugShowCheckedModeBanner: false,
              title: 'Demo',
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
              navigatorKey: MyApp.navigatorKey,
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
                '/version_update_test': (context) =>
                    const VersionUpdateTestScreen(),
                /* End home page */
              },
            );
          },
        ),
      ),
    );
  }
}
