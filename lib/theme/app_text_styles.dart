import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const double tiny = 11.0;
  static const double small = 12.0;
  static const double bodySmall = 13.0;
  static const double body = 14.0;
  static const double bodyLarge = 15.0;
  static const double subtitle = 16.0;
  static const double title = 18.0;
  static const double heading = 20.0;
  static const double largeHeading = 24.0;

  static const TextStyle bodyText = TextStyle(
    fontSize: body,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontSize: bodySmall,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: subtitle,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: title,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle statistic = TextStyle(
    fontSize: largeHeading,
    fontWeight: FontWeight.w800,
  );
}