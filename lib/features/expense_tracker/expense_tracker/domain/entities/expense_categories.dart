import 'package:flutter/material.dart';
import 'package:app/core/constants/colors.dart';

class ExpenseCategory {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

const List<ExpenseCategory> kExpenseCategories = [
  ExpenseCategory(value: 'home_needs',   label: 'Home Needs',   icon: Icons.home_rounded,            color: Color(0xFF60A5FA)),
  ExpenseCategory(value: 'business',     label: 'Business',     icon: Icons.business_center_rounded, color: Color(0xFFA78BFA)),
  ExpenseCategory(value: 'savings',      label: 'Savings',      icon: Icons.savings_rounded,         color: Color(0xFF4ADE80)),
  ExpenseCategory(value: 'purchases',    label: 'Purchases',    icon: Icons.shopping_bag_rounded,    color: Color(0xFFFB923C)),
  ExpenseCategory(value: 'food',         label: 'Food',         icon: Icons.restaurant_rounded,      color: Color(0xFFF97316)),
  ExpenseCategory(value: 'transport',    label: 'Transport',    icon: Icons.directions_car_rounded,  color: Color(0xFF38BDF8)),
  ExpenseCategory(value: 'health',       label: 'Health',       icon: Icons.favorite_rounded,        color: Color(0xFFFF6B6B)),
  ExpenseCategory(value: 'education',    label: 'Education',    icon: Icons.school_rounded,          color: Color(0xFFFACC15)),
  ExpenseCategory(value: 'fun',          label: 'Fun',          icon: Icons.celebration_rounded,     color: Color(0xFFE879F9)),
  ExpenseCategory(value: 'utilities',    label: 'Utilities',    icon: Icons.bolt_rounded,            color: Color(0xFF34D399)),
  ExpenseCategory(value: 'other',        label: 'Other',        icon: Icons.more_horiz_rounded,      color: AppColors.textTertiary),
];

ExpenseCategory categoryFor(String value) =>
    kExpenseCategories.firstWhere((c) => c.value == value,
        orElse: () => kExpenseCategories.last);
