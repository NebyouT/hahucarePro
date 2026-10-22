import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_clinic_admin/api/auth_apis.dart';
import 'package:kivicare_clinic_admin/screens/auth/model/login_response.dart';
import 'package:kivicare_clinic_admin/utils/local_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import '../appointment/appointments_controller.dart';
import '../home/home_controller.dart';
import '../payout/payout_history_controller.dart';
import 'components/modern_bottom_nav.dart';
import 'dashboard_controller.dart';
import 'components/menu.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final DashboardController dashboardController = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      message: locale.value.pressBackAgainToExitApp,
      child: Scaffold(
        body: Stack(
          children: [
            Obx(() => dashboardController.screen[dashboardController.currentIndex.value]),
            Obx(
              () => Align(
                alignment: Alignment.bottomCenter,
                child: ModernBottomNav(
                  items: bottomNavItems,
                  selectedIndex: dashboardController.currentIndex.value,
                  onItemSelected: (index) {
                    if (!isLoggedIn.value && (index == 1 || index == 2)) {
                      doIfLoggedIn(() {
                        handleChangeTabIndex(index);
                      });
                    } else {
                      handleChangeTabIndex(index);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        extendBody: true,
      ),
    );
  }

  void handleChangeTabIndex(int index) {
    hideKeyBoardWithoutContext();

    try {
      final int screensLength = dashboardController.screen.length;
      final int navLength = bottomNavItems.length;

      if (index < 0 || index >= navLength || index >= screensLength) {
        log('handleChangeTabIndex: invalid index -> $index | navLength: $navLength | screensLength: $screensLength');
        return;
      }
    } catch (e) {
      log('handleChangeTabIndex: validation error -> $e');
      return;
    }

    dashboardController.selectedBottonNav(bottomNavItems[index]);
    dashboardController.currentIndex(index);
    try {
      if (index == 0 || (index == 3 && isLoggedIn.value)) {
        final HomeController hCont = Get.find();
        hCont.getDashboardDetail(showLoader: false);
      } else if (isLoggedIn.value && index == 1) {
        final AppointmentsController aCont = Get.find();
        aCont.searchCont.clear();
        aCont.page(1);
        aCont.getAppointmentList();
      } else if ((loginUserData.value.userRole.contains(EmployeeKeyConst.pharma) && index == 4) || (loginUserData.value.userRole.contains(EmployeeKeyConst.vendor) && index == 2)) {
        AuthServiceApis.viewProfile().then((data) {
          loginUserData(
            UserData(
              id: loginUserData.value.id,
              firstName: data.userData.firstName,
              lastName: data.userData.lastName,
              userName: "${data.userData.firstName} ${data.userData.lastName}",
              mobile: data.userData.mobile,
              email: data.userData.email,
              userRole: loginUserData.value.userRole,
              gender: data.userData.gender,
              address: data.userData.address,
              apiToken: loginUserData.value.apiToken,
              profileImage: data.userData.profileImage,
              loginType: loginUserData.value.loginType,
              selectedClinic: selectedAppClinic.value,
              city: data.userData.city,
              country: data.userData.country,
              pinCode: data.userData.pinCode,
              state: data.userData.state,
              dateOfBirth: data.userData.dateOfBirth,
            ),
          );
          setValueToLocal(SharedPreferenceConst.USER_DATA, loginUserData.toJson());
          selectedAppCommission(data.userData.commission);
        }).catchError((e) {
          toast(e.toString());
        });

        if (loginUserData.value.userRole.contains(EmployeeKeyConst.vendor)) {
          final PayoutHistoryCont pCont = Get.find();
          pCont.page(1);
          pCont.getPayoutList();
        }
      }
    } catch (e) {
      log('onItemSelected Err: $e');
    }
  }
}
