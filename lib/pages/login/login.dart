import 'dart:async';

import 'package:flutter/material.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';

import 'package:coursebubble/utils/localized_exception_extension.dart';
import 'package:coursebubble/widgets/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vrouter/vrouter.dart';
import '../../utils/platform_infos.dart';
import 'login_view.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  LoginController createState() => LoginController();
}

class LoginController extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? usernameError;
  String? passwordError;
  bool loading = false;
  bool showPassword = false;
  String? dropdownval;
  bool gotc = true;
  WebSocketChannel? ws;
  StreamSubscription? ss;
  bool needpush = false;
  bool syncing = false;
  String loadingtext = "";
  TextEditingController code = TextEditingController();

  void changeSchool(String newSchool) {
    setState(() {
      dropdownval = newSchool;
    });
  }

  void toggleShowPassword() =>
      setState(() => showPassword = !loading && !showPassword);

  void login() async {
    Matrix.of(context).getLoginClient().homeserver =
        Uri.parse('https://matrix.coursebubble.online');
    final matrix = Matrix.of(context);

    if (!usernameController.text.contains('@')) {
      setState(() => usernameError = 'Please use email address');
    } else {
      setState(() => usernameError = null);
    }

    if (usernameController.text.isEmpty) {
      setState(() => usernameError = L10n.of(context)!.pleaseEnterYourUsername);
    } else {}
    if (passwordController.text.isEmpty) {
      setState(() => passwordError = L10n.of(context)!.pleaseEnterYourPassword);
    } else {
      setState(() => passwordError = null);
    }

    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        !usernameController.text.contains('@')) {
      return;
    }

    setState(() => loading = true);

    _coolDown?.cancel();

    try {
      final username = usernameController.text;
      AuthenticationIdentifier identifier;
      if (username.isEmail) {
        identifier = AuthenticationThirdPartyIdentifier(
          medium: 'email',
          address: username,
        );
      } else if (username.isPhoneNumber) {
        identifier = AuthenticationThirdPartyIdentifier(
          medium: 'msisdn',
          address: username,
        );
      } else {
        identifier = AuthenticationUserIdentifier(user: username);
      }

      await matrix.getLoginClient().login(
            LoginType.mLoginPassword,
            identifier: identifier,
            // To stay compatible with older server versions
            // ignore: deprecated_member_use
            user: identifier.type == AuthenticationIdentifierTypes.userId
                ? username
                : null,
            password: passwordController.text,
            initialDeviceDisplayName: PlatformInfos.clientName,
          );
    } on MatrixException catch (exception) {
      print(exception);
      //check if login exists at school
      await alternativeLogin();

      setState(() => passwordError = exception.errorMessage);
      return;
    } catch (exception) {
      setState(() => passwordError = exception.toString());
      return;
    } finally {
      matrix.backgroundPush?.setupPush();
    }
  }

  Future<void> getCode() async {
    code.text = "";
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Enter Text Code'),
            content: AutofillGroup(
              child: TextField(
                maxLength: 7,
                controller: code,
                autofillHints: const [AutofillHints.oneTimeCode],
                decoration: const InputDecoration(hintText: "Code"),
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  if (code.text.length == 7) {
                    setState(() {
                      Navigator.pop(context);
                    });
                  }
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    ss?.cancel();
    ws?.sink.close();
    super.dispose();
  }

  Future alternativeLogin() async {
    gotc = false;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('semail', usernameController.text);
    prefs.setString('spass', passwordController.text);
    ws = WebSocketChannel.connect(
      Uri.parse(
        'wss://api.coursebubble.online/login/process/${usernameController.text}/${passwordController.text}',
      ),
    );
    ws?.sink.add('start'); //start login process with provided info
    ss = ws?.stream.listen(onMessage);
  }

  Timer? _coolDown;

  void checkWellKnownWithCoolDown(String userId) async {
    _coolDown?.cancel();
    _coolDown = Timer(
      const Duration(seconds: 1),
      () => _checkWellKnown(userId),
    );
  }

  void onMessage(dynamic m) async {
    String me = m as String;
    print("MESS" + m.toString());
    if (false) {
    } else if (me == 'invalid' || me == 'error') {
      gotc = true;
      setState(() {
        syncing = false;
        loading = false;
      });
      setState(() => passwordError = "Invalid Credentials");
    } else if (me == 'valid') {
      setState(() {
        loading = false;
        syncing = true;
      });
    } else if (me.startsWith('success')) {
      print("got");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var username = usernameController.text;
      print(username);
      await Future.delayed(Duration(milliseconds: 1100));
      //sign in matrix
      await Matrix.of(context).getLoginClient().login(
            LoginType.mLoginPassword,
            identifier: AuthenticationThirdPartyIdentifier(
              medium: 'email',
              address: username,
            ),
            password: passwordController.text,
          );
      await Future.delayed(Duration(milliseconds: 700));
      await Matrix.of(context).getLoginClient().login(
            LoginType.mLoginPassword,
            identifier: AuthenticationThirdPartyIdentifier(
              medium: 'email',
              address: username,
            ),
            password: passwordController.text,
          );
      await Future.delayed(Duration(milliseconds: 700));
      VRouter.of(context).to('/');

      ws?.sink.close(); //close websocket
    } else if (me == 'push') {
      //push needed
      setState(() {
        needpush = true;
      });
    } else if (me == 'code') {
      //code needed
      await getCode();
      ws?.sink.add("code${code.text}");
    } else if (me == 'got') {
      setState(() {
        loadingtext =
            "Confirmed! We'll send you a notification when your school data is synced.";
      });

      //success logged in
      setState(() {
        needpush = false;
      });
    }
  }

  void _checkWellKnown(String userId) async {
    if (mounted) setState(() => usernameError = null);
    if (!userId.isValidMatrixId) return;
    Matrix.of(context).getLoginClient().homeserver =
        Uri.parse('https://matrix.coursebubble.online');

    final oldHomeserver = Uri.parse('https://matrix.coursebubble.online');
    try {
      var newDomain = Uri.https(userId.domain!, '');
      Matrix.of(context).getLoginClient().homeserver = newDomain;
      DiscoveryInformation? wellKnownInformation;
      try {
        wellKnownInformation =
            await Matrix.of(context).getLoginClient().getWellknown();
        if (wellKnownInformation.mHomeserver.baseUrl.toString().isNotEmpty) {
          newDomain = wellKnownInformation.mHomeserver.baseUrl;
        }
      } catch (_) {
        // do nothing, newDomain is already set to a reasonable fallback
      }
      if (newDomain != oldHomeserver) {
        await Matrix.of(context).getLoginClient().checkHomeserver(newDomain);

        if (Matrix.of(context).getLoginClient().homeserver == null) {
          Matrix.of(context).getLoginClient().homeserver = oldHomeserver;
          // okay, the server we checked does not appear to be a matrix server
          Logs().v(
            '$newDomain is not running a homeserver, asking to use $oldHomeserver',
          );
          final dialogResult = await showOkCancelAlertDialog(
            context: context,
            useRootNavigator: false,
            message:
                L10n.of(context)!.noMatrixServer(newDomain, oldHomeserver!),
            okLabel: L10n.of(context)!.ok,
            cancelLabel: L10n.of(context)!.cancel,
          );
          if (dialogResult == OkCancelResult.ok) {
            if (mounted) setState(() => usernameError = null);
          } else {
            Navigator.of(context, rootNavigator: false).pop();
            return;
          }
        }
        usernameError = null;
        if (mounted) setState(() {});
      } else {
        Matrix.of(context).getLoginClient().homeserver = oldHomeserver;
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      Matrix.of(context).getLoginClient().homeserver = oldHomeserver;
      usernameError = e.toLocalizedString(context);
      if (mounted) setState(() {});
    }
  }

  void passwordForgotten() async {
    final input = await showTextInputDialog(
      useRootNavigator: false,
      context: context,
      title: L10n.of(context)!.passwordForgotten,
      message: L10n.of(context)!.enterAnEmailAddress,
      okLabel: L10n.of(context)!.ok,
      cancelLabel: L10n.of(context)!.cancel,
      fullyCapitalizedForMaterial: false,
      textFields: [
        DialogTextField(
          initialText:
              usernameController.text.isEmail ? usernameController.text : '',
          hintText: L10n.of(context)!.enterAnEmailAddress,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
    if (input == null) return;
    final clientSecret = DateTime.now().millisecondsSinceEpoch.toString();
    final response = await showFutureLoadingDialog(
      context: context,
      future: () =>
          Matrix.of(context).getLoginClient().requestTokenToResetPasswordEmail(
                clientSecret,
                input.single,
                sendAttempt++,
              ),
    );
    if (response.error != null) return;
    final password = await showTextInputDialog(
      useRootNavigator: false,
      context: context,
      title: L10n.of(context)!.passwordForgotten,
      message: L10n.of(context)!.chooseAStrongPassword,
      okLabel: L10n.of(context)!.ok,
      cancelLabel: L10n.of(context)!.cancel,
      fullyCapitalizedForMaterial: false,
      textFields: [
        const DialogTextField(
          hintText: '******',
          obscureText: true,
          minLines: 1,
          maxLines: 1,
        ),
      ],
    );
    if (password == null) return;
    final ok = await showOkAlertDialog(
      useRootNavigator: false,
      context: context,
      title: L10n.of(context)!.weSentYouAnEmail,
      message: L10n.of(context)!.pleaseClickOnLink,
      okLabel: L10n.of(context)!.iHaveClickedOnLink,
      fullyCapitalizedForMaterial: false,
    );
    if (ok != OkCancelResult.ok) return;
    final data = <String, dynamic>{
      'new_password': password.single,
      'logout_devices': false,
      "auth": AuthenticationThreePidCreds(
        type: AuthenticationTypes.emailIdentity,
        threepidCreds: ThreepidCreds(
          sid: response.result!.sid,
          clientSecret: clientSecret,
        ),
      ).toJson(),
    };
    final success = await showFutureLoadingDialog(
      context: context,
      future: () => Matrix.of(context).getLoginClient().request(
            RequestType.POST,
            '/client/r0/account/password',
            data: data,
          ),
    );
    if (success.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.passwordHasBeenChanged)),
      );
      usernameController.text = input.single;
      passwordController.text = password.single;
      login();
    }
  }

  static int sendAttempt = 0;

  @override
  Widget build(BuildContext context) => LoginView(this);
}

extension on String {
  static final RegExp _phoneRegex =
      RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
  static final RegExp _emailRegex = RegExp(r'(.+)@(.+)\.(.+)');

  bool get isEmail => _emailRegex.hasMatch(this);

  bool get isPhoneNumber => _phoneRegex.hasMatch(this);
}
