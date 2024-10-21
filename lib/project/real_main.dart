import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'auth_pages/sign_in.dart';
import 'database_management/shared_preferences_services.dart';
import 'localization/app_localization.dart';
// import 'home.dart';

void realMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.sharePrefsInit();
  sharedPrefs.setItems(setCategoriesToDefault: false);
  sharedPrefs.getCurrency();
  sharedPrefs.getAllExpenseItemsLists();
  runApp(const MyApp()
      // AppLock(
      // builder: (args) => MyApp(),
      // lockScreen: MainLockScreen(),
      // enabled: sharedPrefs.isPasscodeOn ? true : false)
      );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    MyAppState state = context.findAncestorStateOfType<MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late Locale? _locale;
  setLocale(Locale locale) {
    log('Locale changed to: ${locale.languageCode}'); // Debugging line
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    Locale appLocale = sharedPrefs.getLocale();
    setState(() {
      _locale = appLocale;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (_locale == null) {
      return SizedBox(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!)),
        ),
      );
    } else {
      return ScreenUtilInit(
        designSize: const Size(428.0, 926.0),
        builder: (_, child) => MaterialApp(
          title: 'Money Assistant',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: const TextTheme(
              displaySmall: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 45.0,
                color: Colors.black,
              ),
              labelLarge: TextStyle(
                fontFamily: 'OpenSans',
              ),
              titleMedium: TextStyle(fontFamily: 'NotoSans'),
              bodyMedium: TextStyle(fontFamily: 'NotoSans'),
            ),
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
                .copyWith(secondary: Colors.orange),
            textSelectionTheme:
                const TextSelectionThemeData(cursorColor: Colors.amberAccent),
          ),
          builder: (context, widget) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1)),
            child: widget!,
          ),
          home: const SignIn(),
          // Home(),
          locale: _locale,
          localizationsDelegates: const [
            AppLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale!.languageCode &&
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          supportedLocales: const [
            Locale("en", "US"),
            Locale("de", "DE"),
            Locale("es", "ES"),
            Locale("fr", "FR"),
            Locale("hi", "IN"),
            Locale("ja", "JP"),
            Locale("ko", "KR"),
            Locale("pt", "PT"),
            Locale("ru", "RU"),
            Locale("tr", "TR"),
            Locale("vi", "VN"),
            Locale("zh", "CN"),
            Locale("bn", "BD"), // Added Bangla (Bengali)
          ],
        ),
      );
    }
  }
}
