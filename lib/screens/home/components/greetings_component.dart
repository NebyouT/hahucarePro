import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_clinic_admin/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../auth/other/notification_screen.dart';

class GreetingsComponent extends StatelessWidget {
  const GreetingsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: CachedImageWidget(
                url: loginUserData.value.profileImage,
                height: 44,
                width: 44,
                fit: BoxFit.cover,
                firstName: loginUserData.value.firstName,
                lastName: loginUserData.value.lastName,
              ),
            ),
          ),
          12.width,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  '${locale.value.hey}, ${loginUserData.value.userName.isNotEmpty ? loginUserData.value.userName.capitalizeEachWord().validate() : locale.value.guest.validate()}',
                  style: boldTextStyle(color: Colors.white, size: 17),
                ),
              ),
              2.height,
              Text(
                '${locale.value.welcomeBack} 👋',
                style: secondaryTextStyle(color: Colors.white.withValues(alpha: 0.8), size: 12),
              ),
            ],
          ).expand(),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: GestureDetector(
              onTap: () {
                Get.to(() => NotificationScreen());
              },
              behavior: HitTestBehavior.translucent,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Image.asset(
                      Assets.navigationIcNotifyOutlined,
                      color: Colors.white,
                      height: 20,
                      width: 20,
                    ),
                  ),
                  Obx(
                    () => Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: appColorSecondary, shape: BoxShape.circle),
                        child: Text(
                          unreadNotificationCount.value > 99 ? '99+' : unreadNotificationCount.value.toString(),
                          style: secondaryTextStyle(color: Colors.white, size: 8),
                        ).visible(unreadNotificationCount.value > 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 24),
    );
  }
}
