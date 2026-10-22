import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../lab/lab_orders_screen.dart';
import '../../lab/lab_service_screen.dart';
import '../home_controller.dart';
import 'analytics_card.dart';

class LabAnalyticComponent extends StatelessWidget {
  final HomeController homeScreenCont;

  const LabAnalyticComponent({super.key, required this.homeScreenCont});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            AnalyticsCard(
              title: locale.value.order,
              countText: "${homeScreenCont.dashboardData.value.data.labOrderCount}",
              icon: Assets.iconsIcShoppingCart,
              onTap: () {
                Get.to(() => const LabOrdersScreen());
              },
            ).expand(),
            16.width,
            AnalyticsCard(
              title: "Results",
              countText: "${homeScreenCont.dashboardData.value.data.labResultCount}",
              icon: Assets.iconsIcNotepad,
              onTap: () {},
            ).expand(),
          ],
        ),
        16.height,
        Row(
          children: [
            AnalyticsCard(
              title: locale.value.services,
              countText: "${homeScreenCont.dashboardData.value.data.labServiceCount}",
              icon: Assets.iconsIcServices,
              onTap: () {
                Get.to(() => const LabServiceScreen());
              },
            ).expand(),
            16.width,
            AnalyticsCard(
              title: "Tests",
              countText: "${homeScreenCont.dashboardData.value.data.labTestCount}",
              icon: Assets.iconsIcTotalService,
              onTap: () {},
            ).expand(),
          ],
        ),
      ],
    );
  }
}
