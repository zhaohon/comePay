import 'package:flutter/material.dart';
import 'package:comecomepay/services/push_service.dart';
import 'dart:io' show Platform;
import 'package:comecomepay/views/homes/AboutUsScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
import 'package:comecomepay/viewmodels/unified_transaction_viewmodel.dart';
import 'package:comecomepay/viewmodels/card_viewmodel.dart';
import 'package:comecomepay/viewmodels/wallet_viewmodel.dart';
import 'package:comecomepay/viewmodels/send_pdp_detail_viewmodel.dart';
import 'package:comecomepay/viewmodels/crypto_viewmodel.dart';
import 'package:comecomepay/viewmodels/swap_viewmodel.dart';
import 'package:comecomepay/models/responses/login_response_model.dart';
import 'package:comecomepay/services/hive_storage_service.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/firebase_options.dart';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
import 'package:comecomepay/views/debug/VersionUpdateTestScreen.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('zh'),
    const Locale('ar'),
  ];
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Using the newly configured company environments)
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Run Firebase Token fetching in a non-blocking background Future
  // This prevents Huawei / China ROMs without Google Mobile Services (GMS) from
  // hanging indefinitely on `await getToken()` which results in an app white-screen!
  Future.microtask(() async {
    try {
      // Request APNs/notification permissions
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // [iOS] 在换了 Firebase 项目之后，iOS 需要重新和苹果 APNs 注册绑定。
      // 这个过程完全异步，最长需要数秒钟。
      // 必须等 APNs token 到位之后，getToken() 才能成功兑换 FCM token。
      // 我们用轮询的方式最多等 8 秒，避免报 apns-token-not-set。

      if (Platform.isIOS) {
        String? apnsToken;
        for (int i = 0; i < 8; i++) {
          try {
            apnsToken = await FirebaseMessaging.instance.getAPNSToken();
            if (apnsToken != null && apnsToken.isNotEmpty) {
              debugPrint('✅ APNs Token 已就绪（第${i + 1}次尝试）');
              break;
            }
          } catch (_) {}
          debugPrint('⏳ 等待 APNs Token... (${i + 1}/8)');
          await Future.delayed(const Duration(seconds: 1));
        }
        if (apnsToken == null) {
          debugPrint('⚠️ APNs Token 等待超时（8秒），通知功能可能受影响');
        }
      }

      // 获取 FCM Token
      String? token;
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          token = await FirebaseMessaging.instance.getToken().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('FCM Token fetch TIMEOUT on attempt $attempt');
              return null;
            },
          );
          if (token != null && token.isNotEmpty) break;
        } catch (e) {
          debugPrint('FCM Token attempt $attempt failed: $e');
          if (attempt < 3) await Future.delayed(const Duration(seconds: 2));
        }
      }

      debugPrint('--- DEVICE PUSH TOKEN ---');
      debugPrint(token ?? 'NO_TOKEN (Init Failed or Timeout)');
      debugPrint('-------------------------');

      // Phase 6: Listen for token refreshes
      FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) {
        debugPrint('--- TOKEN REFRESHED ---');
        debugPrint(newToken);

        // Wait for Hive to be ready if called during boot
        if (HiveStorageService.getAccessToken() != null) {
          PushService().registerDevice();
        }
      });

      // Phase 7: Handle notification clicks when app is in Background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint(
            'Notification clicked! App was in background. Data: ${message.data}');
      });

      // Phase 7: Handle notification clicks when app is completely Terminated
      final RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
            'App launched from terminated state via notification! Data: ${initialMessage.data}');
      }
    } catch (e) {
      debugPrint('Background Firebase startup log: $e');
    }
  });

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
