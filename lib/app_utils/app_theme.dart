import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AppTheme {
  static Color primaryColor = Color(0xff519657);
  static Color sub = Color(0xff51adcf);
  static Color chatBackground = Color(0xffECE5DD);
  static Color checkMarkBlue = Color(0xff34B7F1);
  static Color textColor = Color(0xff29434E);

  static get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xffFFFFFF),
        primaryColor: primaryColor,
        secondaryHeaderColor: sub,
        textTheme: TextTheme(
          ///header 1
          headline1: GoogleFonts.lora(
            color: textColor,
            // fontFamily: "Lora",
            fontWeight: FontWeight.w700,
            fontSize: 20.0.sp, //28
          ),

          ///header 2
          headline6: GoogleFonts.lora(
            color: textColor,
            // fontFamily: "Lora",
            fontWeight: FontWeight.w400,
            fontSize: 18.0.sp, //20
          ),

          ///paragraph 1
          bodyText1: GoogleFonts.rubik(
            color: textColor,
            // fontFamily: "Rubik",
            fontWeight: FontWeight.w400,
            fontSize: 16.0.sp, //18
          ),

          ///paragraph 2
          bodyText2: GoogleFonts.rubik(
            color: textColor,
            // fontFamily: "Rubik",
            fontWeight: FontWeight.w400,
            fontSize: 14.0.sp, //16
          ),
          subtitle2: GoogleFonts.rubik(
            color: Color(0xff29434E),
            // fontFamily: "Rubik",
            fontWeight: FontWeight.w400,
            fontSize: 12.0.sp, //16
          ),
        ),
        dividerColor: Color(0xffFB8C00),
        dividerTheme: DividerThemeData(
          thickness: 1.0,
        ),
        buttonColor: Color(0xff519657),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xffFFFFFF),
        ),
        unselectedWidgetColor: Color(0xff29434E),
        accentIconTheme: IconThemeData(
          color: primaryColor,
        ),
        accentColorBrightness: Brightness.light,
        appBarTheme: AppBarTheme(
          elevation: 0.0,
          iconTheme: IconThemeData(
            color: textColor,
          ),
          brightness: Brightness.light,
          color: Colors.transparent,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
        ),
        indicatorColor: Color(0xffFB8C00),
        toggleableActiveColor: sub,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppTheme.primaryColor,
        ),
      );

  static get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xff303030),
        primaryColor: primaryColor,
        secondaryHeaderColor: sub,
        accentColor: sub,
        accentColorBrightness: Brightness.dark,
        accentIconTheme: IconThemeData(
          color: chatBackground,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0.0,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          actionsIconTheme: IconThemeData(
            color: Colors.white,
          ),
          brightness: Brightness.dark,
          color: Color(0xff424242),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: sub,
        ),
        indicatorColor: sub,
        toggleableActiveColor: sub,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppTheme.primaryColor,
        ),
      );
}
