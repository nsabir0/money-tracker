import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../classes/constants.dart';
import '../database_management/shared_preferences_services.dart';
import '../localization/language.dart';
import '../localization/methods.dart';
import '../provider.dart';
import '../real_main.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({super.key});

  @override
  SelectLanguageState createState() => SelectLanguageState();
}

class SelectLanguageState extends State<SelectLanguage> {
  @override
  Widget build(BuildContext context) {
    List<Language> languageList = Language.languageList;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: blue3,
          title: Text(
            getTranslated(context, 'Select a language') ?? 'Select a language',
            style: TextStyle(fontSize: 21.sp),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 5.w),
              child: TextButton(
                child: Text(
                  getTranslated(context, 'Save') ?? 'Save',
                  style: TextStyle(fontSize: 18.5.sp, color: white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ChangeNotifierProvider<OnLanguageSelected>(
            create: (context) => OnLanguageSelected(),
            builder: (context, widget) => ListView.builder(
                itemCount: languageList.length,
                itemBuilder: (context, int count) {
                  return buildLanguageItem(context, count, languageList[count]);
                }),
          ),
        ));
  }

  Widget buildLanguageItem(BuildContext context, int count, Language language) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Locale locale = sharedPrefs.setLocale(language.languageCode);
        log('Changing locale to: ${locale.languageCode}'); // Debugging line
        MyApp.setLocale(context, locale);
        context.read<OnLanguageSelected>().onSelect(language.languageCode);
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 23.w),
            child: Row(
              children: [
                Text(language.flag, style: TextStyle(fontSize: 45.sp)),
                SizedBox(width: 35.w),
                Text(language.name, style: TextStyle(fontSize: 20.sp)),
                const Spacer(),
                Consumer<OnLanguageSelected>(
                  builder: (context, selectedLanguage, child) {
                    return selectedLanguage.languageCode ==
                            language.languageCode
                        ? Icon(Icons.check_circle, size: 25.sp, color: blue3)
                        : const SizedBox();
                  },
                ),
                SizedBox(width: 15.w),
              ],
            ),
          ),
          Divider(indent: 90.w, height: 0, thickness: 0.25.h, color: grey),
        ],
      ),
    );
  }
}
