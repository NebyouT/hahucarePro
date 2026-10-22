import 'package:flutter/material.dart';
import 'package:kivicare_clinic_admin/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/cached_image_widget.dart';
import '../../../utils/colors.dart';

class AnalyticsCard extends StatelessWidget {
  final void Function()? onTap;
  final String title;
  final String countText;
  final String icon;
  final Color? cardColor;
  final Color? iconBgColor;

  const AnalyticsCard({
    super.key,
    this.onTap,
    required this.title,
    required this.countText,
    required this.icon,
    this.cardColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode.value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor ?? (isDark ? const Color(0xFF1A2634) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE8ECF0),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      countText,
                      style: boldTextStyle(
                        color: appColorPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor ?? lightPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CachedImageWidget(
                    url: icon,
                    height: 16,
                    width: 16,
                    color: appColorPrimary,
                  ),
                ),
              ],
            ),
            16.height,
            Text(
              title,
              style: secondaryTextStyle(size: 12, color: isDark ? const Color(0xFF9CA3AF) : secondaryTextColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
