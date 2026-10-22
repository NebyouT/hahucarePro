import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:get/get.dart';
import 'package:kivicare_clinic_admin/components/cached_image_widget.dart';
import '../../../configs.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/constants.dart';
import '../model/login_roles_model.dart';
import 'sign_in_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../password/forget_password_screen.dart';
import 'signup_screen.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final SignInController signInController = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        height: Get.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment(0.0, 0.15),
            colors: [appColorPrimary, Color(0xFF3399FF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              top: Get.height * 0.12,
              right: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: Get.height * 0.08),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: Image.asset(
                          Assets.assetsAppLogo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              APP_NAME[0],
                              style: boldTextStyle(size: 32, color: appColorPrimary),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Get.height * 0.04),
                    Text(
                      locale.value.welcomeBackToThe,
                      style: secondaryTextStyle(size: 14, color: Colors.white70),
                    ),
                    4.height,
                    Text(
                      APP_NAME,
                      style: boldTextStyle(size: 26, color: Colors.white, letterSpacing: 1),
                    ),
                    SizedBox(height: Get.height * 0.04),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: signInController.signInformKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(locale.value.email, style: boldTextStyle(size: 13, color: primaryTextColor)),
                                  8.height,
                                  AppTextField(
                                    textStyle: primaryTextStyle(size: 14),
                                    controller: signInController.emailCont,
                                    focus: signInController.emailFocus,
                                    nextFocus: signInController.passwordFocus,
                                    textFieldType: TextFieldType.EMAIL_ENHANCED,
                                    decoration: inputDecoration(
                                      isShowLabel: false,
                                      context,
                                      fillColor: appScreenBackground,
                                      filled: true,
                                      hintText: locale.value.email,
                                    ).copyWith(
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(12),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: lightPrimaryColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: commonLeadingWid(imgPath: Assets.iconsIcMail, color: appColorPrimary, size: 14),
                                      ),
                                      hintStyle: secondaryTextStyle(size: 13),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: appColorPrimary, width: 1.5),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    ),
                                  ),
                                  20.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(locale.value.password, style: boldTextStyle(size: 13, color: primaryTextColor)),
                                      InkWell(
                                        onTap: () {
                                          Get.to(() => ForgetPassword());
                                        },
                                        child: Text(
                                          locale.value.forgotPassword,
                                          style: primaryTextStyle(size: 12, color: appColorPrimary, fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    ],
                                  ),
                                  8.height,
                                  Obx(
                                    () => AppTextField(
                                      textStyle: primaryTextStyle(size: 14),
                                      controller: signInController.passwordCont,
                                      focus: signInController.passwordFocus,
                                      textFieldType: TextFieldType.PASSWORD,
                                      obscureText: !signInController.isPasswordVisible.value,
                                      decoration: inputDecoration(
                                        isShowLabel: false,
                                        context,
                                        fillColor: appScreenBackground,
                                        filled: true,
                                        hintText: locale.value.password,
                                      ).copyWith(
                                        prefixIcon: Container(
                                          margin: const EdgeInsets.all(12),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: lightPrimaryColor,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: commonLeadingWid(imgPath: Assets.iconsIcLock, color: appColorPrimary, size: 14),
                                        ),
                                        hintStyle: secondaryTextStyle(size: 13),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: appColorPrimary, width: 1.5),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                        suffixIcon: IconButton(
                                          onPressed: () => signInController.togglePasswordVisibility(),
                                          icon: Icon(
                                            signInController.isPasswordVisible.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                            color: secondaryTextColor,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  12.height,
                                  Obx(
                                    () => Row(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: signInController.isRememberMe.value,
                                            activeColor: appColorPrimary,
                                            checkColor: whiteColor,
                                            shape: RoundedRectangleBorder(borderRadius: radius(6)),
                                            side: const BorderSide(color: borderColor, width: 1.5),
                                            onChanged: (val) {
                                              signInController.toggleSwitch();
                                            },
                                          ),
                                        ),
                                        10.width,
                                        Text(
                                          locale.value.rememberMe,
                                          style: secondaryTextStyle(size: 13, color: secondaryTextColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            12.height,
                            Container(
                              width: Get.width,
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              child: Column(
                                children: [
                                  AppButton(
                                    width: Get.width,
                                    height: 54,
                                    text: locale.value.signIn,
                                    color: appColorPrimary,
                                    shapeBorder: RoundedRectangleBorder(borderRadius: radius(16)),
                                    textStyle: boldTextStyle(size: 15, color: Colors.white),
                                    onTap: () {
                                      if (signInController.signInformKey.currentState!.validate()) {
                                        signInController.signInformKey.currentState!.save();
                                        signInController.saveForm();
                                      }
                                    },
                                  ),
                                  if (signInController.isLoading.value) 8.height,
                                  if (signInController.isLoading.value)
                                    const LinearProgressIndicator(
                                      color: appColorPrimary,
                                      backgroundColor: Color(0xFFE8F0FE),
                                      minHeight: 3,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Get.height * 0.035),
                    Text(locale.value.chooseYourRole, style: secondaryTextStyle(size: 12, color: Colors.white60)),
                    14.height,
                    Wrap(
                      runSpacing: 12,
                      spacing: 12,
                      alignment: WrapAlignment.center,
                      children: loginRoles
                          .map(
                            (e) => GestureDetector(
                              onTap: () {
                                signInController.selectedLoginRole(e);
                              },
                              child: Obx(
                                () => RoleComponent(
                                  loginUserRole: e,
                                  isSelected: signInController.selectedLoginRole.value.id == e.id,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    24.height,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(locale.value.notAMember, style: secondaryTextStyle(size: 13, color: Colors.white70)),
                        4.width,
                        InkWell(
                          onTap: () {
                            Get.to(() => SignUpScreen());
                            signInController.signInformKey.currentState?.reset();
                          },
                          child: Text(
                            locale.value.signUp,
                            style: boldTextStyle(size: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Get.height * 0.04),
                  ],
                ),
              ),
            ),
            Obx(
              () => signInController.isLoading.value
                  ? Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : const Offstage(),
            ),
          ],
        ),
      ),
    );
  }
}

void chooseEmployeeType(BuildContext context, {RxBool? isLoading, required Function(LoginRoleData) onChange, bool isFromDemoAccountTap = false}) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: boxDecorationDefault(
        color: context.cardColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
      ),
      child: ListView.separated(
        itemCount: loginRoles.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return SettingItemWidget(
            title: loginRoles[index].roleName,
            titleTextStyle: primaryTextStyle(size: 14),
            leading: CachedImageWidget(url: loginRoles[index].icon, color: appColorPrimary, height: 22, fit: BoxFit.fitHeight, width: 22),
            onTap: () {
              onChange(loginRoles[index]);
              Get.back();
            },
          );
        },
        separatorBuilder: (context, index) => commonDivider.paddingSymmetric(vertical: 6),
      ),
    ),
  );
}

class RoleComponent extends StatelessWidget {
  final LoginRoleData loginUserRole;
  final bool isSelected;

  const RoleComponent({super.key, required this.loginUserRole, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedImageWidget(
            url: loginUserRole.icon,
            height: 16,
            fit: BoxFit.fitHeight,
            color: isSelected ? appColorPrimary : Colors.white70,
          ),
          8.width,
          Text(
            loginUserRole.roleName,
            style: boldTextStyle(
              size: 13,
              color: isSelected ? appColorPrimary : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}


