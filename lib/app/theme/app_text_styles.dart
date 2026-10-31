import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get _base => GoogleFonts.notoSans(
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get mainHeading => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get sectionHeading => _base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get cardHeading => _base.copyWith(
        fontSize: 19,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get body => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get supporting => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get button => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get urdu => GoogleFonts.notoNastaliqUrdu(
        color: AppColors.textPrimary,
        fontSize: 20,
        height: 1.8,
      );
}
