import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../localization/methods.dart';
import 'constants.dart';

class CustomToast extends StatelessWidget {
  final String message;
  const CustomToast(this.message, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        boxShadow: const [BoxShadow()],
        borderRadius: BorderRadius.circular(25.r),
        color: const Color.fromRGBO(239, 247, 253, 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check,
            color: blue3,
          ),
          SizedBox(
            width: 12.w,
          ),
          Text(
            getTranslated(context, message) ?? message,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

void customToast(BuildContext context, String message) {
  var fToast = FToast();
  fToast.init(context);
  fToast.showToast(
    child: CustomToast(message),
    gravity: ToastGravity.TOP,
    toastDuration: const Duration(seconds: 2),
  );
}
