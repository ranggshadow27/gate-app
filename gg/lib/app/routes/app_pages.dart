import 'package:get/get.dart';

import 'package:gate/app/modules/add_user/bindings/add_user_binding.dart';
import 'package:gate/app/modules/add_user/views/add_user_view.dart';
import 'package:gate/app/modules/admin_home/bindings/admin_home_binding.dart';
import 'package:gate/app/modules/admin_home/views/admin_home_view.dart';
import 'package:gate/app/modules/admin_manage_users/bindings/admin_manage_users_binding.dart';
import 'package:gate/app/modules/admin_manage_users/views/admin_manage_users_view.dart';
import 'package:gate/app/modules/admin_user_presence_history/bindings/admin_user_presence_history_binding.dart';
import 'package:gate/app/modules/admin_user_presence_history/views/admin_user_presence_history_view.dart';
import 'package:gate/app/modules/admin_user_salary/bindings/admin_user_salary_binding.dart';
import 'package:gate/app/modules/admin_user_salary/views/admin_user_salary_view.dart';
import 'package:gate/app/modules/admin_view_users/bindings/admin_view_users_binding.dart';
import 'package:gate/app/modules/admin_view_users/views/admin_view_users_view.dart';
import 'package:gate/app/modules/dispensation/bindings/dispensation_binding.dart';
import 'package:gate/app/modules/dispensation/views/dispensation_view.dart';
import 'package:gate/app/modules/dispensation_add/bindings/dispensation_add_binding.dart';
import 'package:gate/app/modules/dispensation_add/views/dispensation_add_view.dart';
import 'package:gate/app/modules/dispensation_details/bindings/dispensation_details_binding.dart';
import 'package:gate/app/modules/dispensation_details/views/dispensation_details_view.dart';
import 'package:gate/app/modules/forgot_password/bindings/forgot_password_binding.dart';
import 'package:gate/app/modules/forgot_password/views/forgot_password_view.dart';
import 'package:gate/app/modules/home/bindings/home_binding.dart';
import 'package:gate/app/modules/home/views/home_view.dart';
import 'package:gate/app/modules/login/bindings/login_binding.dart';
import 'package:gate/app/modules/login/views/login_view.dart';
import 'package:gate/app/modules/payroll/bindings/payroll_binding.dart';
import 'package:gate/app/modules/payroll/views/payroll_view.dart';
import 'package:gate/app/modules/presence_details/bindings/presence_details_binding.dart';
import 'package:gate/app/modules/presence_details/views/presence_details_view.dart';
import 'package:gate/app/modules/presence_history/bindings/presence_history_binding.dart';
import 'package:gate/app/modules/presence_history/views/presence_history_view.dart';
import 'package:gate/app/modules/report/bindings/report_binding.dart';
import 'package:gate/app/modules/report/views/report_view.dart';
import 'package:gate/app/modules/report_add/bindings/report_add_binding.dart';
import 'package:gate/app/modules/report_add/views/report_add_view.dart';
import 'package:gate/app/modules/report_detail/bindings/report_detail_binding.dart';
import 'package:gate/app/modules/report_detail/views/report_detail_view.dart';
import 'package:gate/app/modules/report_update/bindings/report_update_binding.dart';
import 'package:gate/app/modules/report_update/views/report_update_view.dart';
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
    GetPage(
      name: _Paths.PAYROLL,
      page: () => PayrollView(),
      binding: PayrollBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_HOME,
      page: () => AdminHomeView(),
      binding: AdminHomeBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_MANAGE_USERS,
      page: () => AdminManageUsersView(),
      binding: AdminManageUsersBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_VIEW_USERS,
      page: () => AdminViewUsersView(),
      binding: AdminViewUsersBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_USER_PRESENCE_HISTORY,
      page: () => AdminUserPresenceHistoryView(),
      binding: AdminUserPresenceHistoryBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_USER_SALARY,
      page: () => AdminUserSalaryView(),
      binding: AdminUserSalaryBinding(),
    ),
    GetPage(
      name: _Paths.REPORT,
      page: () => ReportView(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: _Paths.REPORT_ADD,
      page: () => ReportAddView(),
      binding: ReportAddBinding(),
    ),
    GetPage(
      name: _Paths.REPORT_DETAIL,
      page: () => ReportDetailView(),
      binding: ReportDetailBinding(),
    ),
    GetPage(
      name: _Paths.REPORT_UPDATE,
      page: () => ReportUpdateView(),
      binding: ReportUpdateBinding(),
    ),
    GetPage(
      name: _Paths.DISPENSATION,
      page: () => DispensationView(),
      binding: DispensationBinding(),
    ),
    GetPage(
      name: _Paths.DISPENSATION_ADD,
      page: () => DispensationAddView(),
      binding: DispensationAddBinding(),
    ),
    GetPage(
      name: _Paths.DISPENSATION_DETAILS,
      page: () => DispensationDetailsView(),
      binding: DispensationDetailsBinding(),
    ),
  ];
}
