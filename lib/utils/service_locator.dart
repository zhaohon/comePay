import 'package:get_it/get_it.dart';
import 'package:Demo/services/global_service.dart';
import 'package:Demo/viewmodels/login_viewmodel.dart';
import 'package:Demo/viewmodels/signup_viewmodel.dart';
import 'package:Demo/viewmodels/registration_otp_viewmodel.dart';
import 'package:Demo/viewmodels/forgot_password_viewmodel.dart';
import 'package:Demo/viewmodels/coupon_viewmodel.dart';
import 'package:Demo/viewmodels/modify_email_viewmodel.dart';
import 'package:Demo/viewmodels/set_transaction_password_viewmodel.dart';
import 'package:Demo/viewmodels/messageservicecenter_viewmodel.dart';
import 'package:Demo/viewmodels/notification_viewmodel.dart';
import 'package:Demo/viewmodels/profile_screen_viewmodel.dart';
import 'package:Demo/viewmodels/home_screen_viewmodel.dart';
import 'package:Demo/viewmodels/transaction_record_viewmodel.dart';
import 'package:Demo/viewmodels/create_account_verification_viewmodel.dart';
import 'package:Demo/viewmodels/token_receive_viewmodel.dart';
import 'package:Demo/viewmodels/crypto_viewmodel.dart';
import 'package:Demo/services/swap_service.dart';
import 'package:Demo/viewmodels/swap_viewmodel.dart';

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
