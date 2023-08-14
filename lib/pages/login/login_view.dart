import 'package:coursebubble/config/app_config.dart';
import 'package:coursebubble/utils/platform_infos.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:coursebubble/widgets/layouts/login_scaffold.dart';
import 'package:coursebubble/widgets/matrix.dart';
import 'login.dart';

class LoginView extends StatelessWidget {
  final LoginController controller;
  const LoginView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async {
      return false;
    }, child: LoginScaffold(
      body: Builder(
        builder: (context) {
          return AutofillGroup(
            child: controller.loading
                ? const Center(child: CircularProgressIndicator())
                : controller.needpush
                    ? Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            Image.asset(
                              'assets/duo.png',
                              width: 200,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            const Text(
                              "Push Request Sent to your Device",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            )
                          ]))
                    : controller.syncing
                        ? const Center(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                CircularProgressIndicator(),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "🔄\nSyncing your Clemson Account\n(~15 seconds)",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20),
                                )
                              ]))
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            children: <Widget>[
                              PlatformInfos.isMobile
                                  ? const SizedBox(
                                      height: 90,
                                    )
                                  : const SizedBox(height: 15),
                              const Text(
                                "1. Select Your School",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 18),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        showDragHandle: true,
                                        context: context,
                                        builder: (context) {
                                          return Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: Column(
                                                children: [
                                                  Divider(),
                                                  InkWell(
                                                      borderRadius: BorderRadius
                                                          .circular(AppConfig
                                                              .borderRadius),
                                                      onTap: () {
                                                        controller.changeSchool(
                                                          'Clemson University',
                                                        );
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: const Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              IgnorePointer(
                                                                child: Image(
                                                                    width: 70,
                                                                    height: 70,
                                                                    image: AssetImage(
                                                                        'assets/colleges/clemson.png')),
                                                              ),
                                                              VerticalDivider(),
                                                              Expanded(
                                                                  child: Text(
                                                                "Clemson University",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 25,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ))
                                                            ]),
                                                      )),
                                                  Divider()
                                                ],
                                              ));
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 36, vertical: 24),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          (controller.dropdownval != null
                                              ? controller.dropdownval!
                                              : 'Choose School'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(Icons
                                            .arrow_drop_down_circle_outlined)
                                      ],
                                    )),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                "2. Login with Your School Email and School Password",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 18),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: TextField(
                                  readOnly: controller.loading,
                                  autocorrect: false,
                                  autofocus: true,
                                  enabled: controller.dropdownval != null,
                                  onChanged:
                                      controller.checkWellKnownWithCoolDown,
                                  controller: controller.usernameController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: controller.loading
                                      ? null
                                      : [AutofillHints.username],
                                  decoration: InputDecoration(
                                    prefixIcon:
                                        const Icon(Icons.email_outlined),
                                    errorText: controller.usernameError,
                                    errorStyle:
                                        const TextStyle(color: Colors.orange),
                                    hintText: L10n.of(context)!.emailOrUsername,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: TextField(
                                  readOnly: controller.loading,
                                  autocorrect: false,
                                  enabled: controller.dropdownval != null,
                                  autofillHints: controller.loading
                                      ? null
                                      : [AutofillHints.password],
                                  controller: controller.passwordController,
                                  textInputAction: TextInputAction.go,
                                  obscureText: !controller.showPassword,
                                  onSubmitted: (_) => controller.login(),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.lock_outlined),
                                    errorText: controller.passwordError,
                                    errorStyle:
                                        const TextStyle(color: Colors.orange),
                                    suffixIcon: IconButton(
                                      onPressed: controller.toggleShowPassword,
                                      icon: Icon(
                                        controller.showPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                    ),
                                    hintText: L10n.of(context)!.password,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Hero(
                                tag: 'signinButton',
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    onPressed: controller.dropdownval == null
                                        ? null
                                        : controller.login,
                                    icon: const Icon(Icons.login_outlined),
                                    label: controller.loading
                                        ? const LinearProgressIndicator()
                                        : Text(
                                            L10n.of(context)!.login,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              const Opacity(
                                opacity: 0.2,
                                child: Text(
                                  "CourseBubble",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: "poppins"),
                                ),
                              ),
                            ],
                          ),
          );
        },
      ),
    ));
  }
}
