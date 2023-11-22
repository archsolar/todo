import 'package:flutter/material.dart';

const String appName = "secret-todo";
//TODO needs fixing.
ThemeData whiteTheme() {
  const Color primaryColor = Colors.white;
  const Color buttonColor = Colors.blue;
  const Color textColor = Colors.black;

  const Color appBarBackgroundColor = primaryColor;
  const Color scaffoldBackgroundColor = appBarBackgroundColor;
  const Color appBarTextColor = textColor;
  const Color iconButtonColor = textColor;

  return ThemeData(
    // Define the primary color for your app
    primaryColor: primaryColor,
    // Define the color of text
    textTheme: TextTheme(
      bodySmall: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 20),
      bodyLarge: TextStyle(color: textColor, fontSize: 30),
    ),
    cardColor: primaryColor,
    // Define the background color of your app
    scaffoldBackgroundColor: scaffoldBackgroundColor, // Adjust as needed

    // Define the color for your buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor, // Adjust as needed
      ),
    ),

    // Define the AppBar theme
    appBarTheme: AppBarTheme(
      color: appBarBackgroundColor, // Adjust as needed
      titleTextStyle: TextStyle(color: appBarTextColor, fontSize: 35),

      iconTheme:
          IconThemeData(color: iconButtonColor), // Set the icon button color
    ),

    // Add other global theme configurations here
  );
}
