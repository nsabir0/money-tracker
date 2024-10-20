import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../database_management/shared_preferences_services.dart';
import '../localization/methods.dart';
import '../provider.dart';
// import 'custom_toast.dart';

class MainLockScreen extends StatelessWidget {
  const MainLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenLock(
      correctString: sharedPrefs.passcodeScreenLock,
      cancelButton: const SizedBox.shrink(),
      onUnlocked: () => AppLock.of(context)!.didUnlock(),
      deleteButton:
          const Icon(Icons.close, color: Color.fromRGBO(89, 129, 163, 1)),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          getTranslated(
                context,
                'Please Enter Passcode',
              ) ??
              'Please Enter Passcode',
          style: const TextStyle(
              color: Color.fromRGBO(71, 131, 192, 1),
              fontWeight: FontWeight.w500,
              fontSize: 20),
        ),
      ),
      config: const ScreenLockConfig(
        backgroundColor: Color.fromRGBO(210, 234, 251, 1),
      ),
      secretsConfig: const SecretsConfig(
          secretConfig: SecretConfig(
        borderColor: Color.fromRGBO(79, 94, 120, 1),
        enabledColor: Color.fromRGBO(89, 129, 163, 1),
      )),
      keyPadConfig: const KeyPadConfig(
        buttonConfig: KeyPadButtonConfig(
          backgroundColor: Color.fromRGBO(71, 131, 192, 1),
        ),
      ),
    );
  }
}

class OtherLockScreen extends StatelessWidget {
  final BuildContext providerContext;
  const OtherLockScreen({super.key, required this.providerContext});

  @override
  Widget build(BuildContext context) {
    final inputController = InputController();
    log(getTranslated(
      context,
      'Please Enter Passcode',
    ).toString());
    return ScreenLock(
      correctString: '',
      title: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Text(
          getTranslated(
                context,
                'Please Enter Passcode',
              ) ??
              'Please Enter Passcode',
          style: TextStyle(
              color: const Color.fromRGBO(71, 131, 192, 1),
              fontWeight: FontWeight.w500,
              fontSize: 20.sp),
        ),
      ),
      inputController: inputController,
      deleteButton:
          const Icon(Icons.close, color: Color.fromRGBO(71, 131, 192, 1)),
      config: const ScreenLockConfig(
        backgroundColor: Color.fromRGBO(210, 234, 251, 1),

        // onConfirmed: (passCode) {
        //   sharedPrefs.passcodeScreenLock = passCode;
        //   Navigator.pop(context);
        //   customToast(context, 'Passcode has been enabled');
        // },
      ),
      secretsConfig: const SecretsConfig(
          secretConfig: SecretConfig(
        borderColor: Color.fromRGBO(79, 94, 120, 1),
        enabledColor: Color.fromRGBO(89, 129, 163, 1),
      )),
      keyPadConfig: const KeyPadConfig(
        buttonConfig: KeyPadButtonConfig(
          backgroundColor: Color.fromRGBO(71, 131, 192, 1),
        ),
      ),
      cancelButton: TextButton(
          onPressed: () {
            providerContext.read<OnSwitch>().onSwitch();
            Navigator.pop(context);
          },
          child: Text(getTranslated(context, 'Cancel') ?? 'Cancel',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(71, 131, 192, 1)))),
      onUnlocked: () {},
    );
  }
}
