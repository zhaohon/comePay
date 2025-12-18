import 'package:get_it/get_it.dart';
import 'package:comecomepay/services/global_service.dart';
import 'package:comecomepay/viewmodels/login_viewmodel.dart';
import 'package:comecomepay/viewmodels/signup_viewmodel.dart';
import 'package:comecomepay/viewmodels/registration_otp_viewmodel.dart';
import 'package:comecomepay/viewmodels/forgot_password_viewmodel.dart';
import 'package:comecomepay/viewmodels/coupon_viewmodel.dart';
import 'package:comecomepay/viewmodels/modify_email_viewmodel.dart';
import 'package:comecomepay/viewmodels/set_transaction_password_viewmodel.dart';
import 'package:comecomepay/viewmodels/messageservicecenter_viewmodel.dart';
import 'package:comecomepay/viewmodels/notification_viewmodel.dart';
import 'package:comecomepay/viewmodels/profile_screen_viewmodel.dart';
import 'package:comecomepay/viewmodels/home_screen_viewmodel.dart';
import 'package:comecomepay/viewmodels/transaction_record_viewmodel.dart';
import 'package:comecomepay/viewmodels/create_account_verification_viewmodel.dart';
import 'package:comecomepay/viewmodels/token_receive_viewmodel.dart';
import 'package:comecomepay/viewmodels/crypto_viewmodel.dart';
import 'package:comecomepay/services/swap_service.dart';
import 'package:comecomepay/viewmodels/swap_viewmodel.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  // Register services
  getIt.registerLazySingleton<GlobalService>(() => GlobalService());

  // Register viewmodels
  getIt.registerFactory<LoginViewModel>(() => LoginViewModel());
  getIt.registerFactory<SignupViewModel>(() => SignupViewModel());
  getIt.registerFactory<RegistrationOtpViewModel>(
      () => RegistrationOtpViewModel());
  getIt.registerFactory<ForgotPasswordViewModel>(
      () => ForgotPasswordViewModel());
  getIt.registerFactory<CouponViewModel>(() => CouponViewModel());
  getIt.registerFactory<ModifyEmailViewModel>(() => ModifyEmailViewModel());
  getIt.registerFactory<SetTransactionPasswordViewModel>(
      () => SetTransactionPasswordViewModel());
  getIt.registerFactory<MessageServiceCenterViewModel>(
      () => MessageServiceCenterViewModel());
  getIt.registerFactory<NotificationViewModel>(() => NotificationViewModel());
  getIt.registerFactory<ProfileScreenViewModel>(() => ProfileScreenViewModel());
  getIt.registerFactory<HomeScreenViewModel>(() => HomeScreenViewModel());
  getIt.registerFactory<TransactionRecordViewModel>(
      () => TransactionRecordViewModel());
  getIt.registerFactory<CreateAccountVerificationViewModel>(
      () => CreateAccountVerificationViewModel());
  getIt.registerFactory<TokenReceiveViewModel>(() => TokenReceiveViewModel());
  getIt.registerFactory<CryptoViewModel>(() => CryptoViewModel());
  getIt.registerLazySingleton<SwapService>(() => SwapService());
  getIt.registerFactory<SwapViewModel>(() => SwapViewModel());
}
