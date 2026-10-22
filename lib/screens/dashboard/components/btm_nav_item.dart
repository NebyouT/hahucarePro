import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_clinic_admin/utils/colors.dart';
import 'menu.dart';

class BtmNavItem extends StatelessWidget {
  final BottomBarItem navBar;
  final bool isActive;
  final VoidCallback onTap;

  const BtmNavItem({
    super.key,
    required this.navBar,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? appColorPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isActive ? 22 : 18,
              height: isActive ? 22 : 18,
              child: Image.asset(
                isActive ? navBar.activeIcon : navBar.icon,
                color: isActive ? Colors.white : appColorPrimary,
                fit: BoxFit.contain,
              ),
            ),
            if (isActive)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  navBar.title.value,
                  style: boldTextStyle(size: 8, color: Colors.white),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
