import 'package:get/get.dart';

import 'package:gate/app/modules/add_user/bindings/add_user_binding.dart';
import 'package:gate/app/modules/add_user/views/add_user_view.dart';
import 'package:gate/app/modules/forgot_password/bindings/forgot_password_binding.dart';
import 'package:gate/app/modules/forgot_password/views/forgot_password_view.dart';
import 'package:gate/app/modules/home/bindings/home_binding.dart';
import 'package:gate/app/modules/home/views/home_view.dart';
import 'package:gate/app/modules/login/bindings/login_binding.dart';
import 'package:gate/app/modules/login/views/login_view.dart';
import 'package:gate/app/modules/presence_details/bindings/presence_details_binding.dart';
import 'package:gate/app/modules/presence_details/views/presence_details_view.dart';
import 'package:gate/app/modules/presence_history_details/bindings/presence_history_details_binding.dart';
import 'package:gate/app/modules/presence_history_details/views/presence_history_details_view.dart';
import 'package:gate/app/modules/reset_default_password/bindings/reset_default_password_binding.dart';
import 'package:gate/app/modules/reset_default_password/views/reset_default_password_view.dart';
import 'package:gate/app/modules/update_user_password/bindings/update_user_password_binding.dart';
import 'package:gate/app/modules/update_user_password/views/update_user_password_view.dart';
import 'package:gate/app/modules/update_user_profile/bindings/update_user_profile_binding.dart';
import 'package:gate/app/modules/update_user_profile/views/update_user_profile_view.dart';
import 'package:gate/app/modules/user_profile/bindings/user_profile_binding.dart';
import 'package:gate/app/modules/user_profile/views/user_profile_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.ADD_USER,
      page: () => AddUserView(),
      binding: AddUserBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.RESET_DEFAULT_PASSWORD,
      page: () => ResetDefaultPasswordView(),
      binding: ResetDefaultPasswordBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.USER_PROFILE,
      page: () => UserProfileView(),
      binding: UserProfileBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.UPDATE_USER_PROFILE,
      page: () => UpdateUserProfileView(),
      binding: UpdateUserProfileBinding(),
    ),
    GetPage(
      name: _Paths.UPDATE_USER_PASSWORD,
      page: () => UpdateUserPasswordView(),
      binding: UpdateUserPasswordBinding(),
    ),
    GetPage(
      name: _Paths.PRESENCE_DETAILS,
      page: () => PresenceDetailsView(),
      binding: PresenceDetailsBinding(),
    ),
    GetPage(
      name: _Paths.PRESENCE_HISTORY_DETAILS,
      page: () => PresenceHistoryDetailsView(),
      binding: PresenceHistoryDetailsBinding(),
    ),
  ];
}
