import 'package:flutter/material.dart';

const Color primaryColor = Color.fromARGB(255, 0, 163, 3);
const Color kSecondaryColor = Color.fromARGB(255, 247, 247, 247);
const Color kSecondarydarkColor = Color.fromARGB(255, 17, 17, 17);
const Color klightgreyColor = Color(0xFFE5E5E5);
const Color kdarkgreyColor = Color(0xFFBDBDBD);
const Color kgreyColor = Color.fromARGB(255, 139, 139, 139);
const Color kblackColor = Color(0xFF000000);
const Color kwhiteColor = Color(0xFFFFFFFF);
const Color kredColor = Color(0xFFFF0000);
const Color kgreenColor = Color(0xFF15BE78);
const Color kthemeColor = Color.fromRGBO(22, 22, 22, 1);
const Color korangeColor = Color(0xFFFFA500);
const Color kyellowColor = Color(0xFFFFD700);
const Color kdarkmodeColor = Color.fromRGBO(33, 33, 33, 1);
const kAppBarColor = Color(0xFF0F172A);
const kdefwhiteColor = Colors.white;
const kdefgreyColor = Colors.grey;
const kmediumblackColor = Color(0xFF6B7280);
const kDiscountColor = Color(0xFF22C55E);
const MaterialColor primaryMaterialColor =
    MaterialColor(0xFF9581FF, <int, Color>{
      50: Color(0xFFEFECFF),
      100: Color(0xFFD7D0FF),
      200: Color(0xFFBDB0FF),
      300: Color(0xFFA390FF),
      400: Color(0xFF8F79FF),
      500: Color(0xFF7B61FF),
      600: Color(0xFF7359FF),
      700: Color(0xFF684FFF),
      800: Color(0xFF5E45FF),
      900: Color(0xFF6C56DD),
    });

final ColorScheme kColorScheme = ColorScheme(
  primary: primaryColor,
  secondary: kSecondaryColor,
  surface: kwhiteColor,
  error: kredColor,
  onPrimary: kwhiteColor,
  onSecondary: kwhiteColor,
  onSurface: kblackColor,
  onError: kwhiteColor,
  brightness: Brightness.light,
);

final ColorScheme kDarkColorScheme = ColorScheme(
  primary: primaryColor,
  secondary: kSecondaryColor,
  surface: kblackColor,
  error: kredColor,
  onPrimary: kwhiteColor,
  onSecondary: kwhiteColor,
  onSurface: kwhiteColor,
  onError: kwhiteColor,
  brightness: Brightness.dark,
);
