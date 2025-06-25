// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:app/constants/colors.dart';

class Navbar extends StatelessWidget {
  final Function(int)? onTabChange;
  Navbar({ super.key, required this.onTabChange,}) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:EdgeInsets.symmetric(vertical: 15) ,
      child: GNav(
        color: AppColors.grey,
        activeColor: AppColors.black,
        tabActiveBorder: Border.all(color: AppColors.palegreen),
        tabBorderRadius: 14,
        gap: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        onTabChange: (value)=> onTabChange!(value),
        tabs: const [
        GButton(
          icon: Icons.home,
          text: 'Shop',),
        GButton(
          icon: Icons.shopping_bag_rounded,
          text: 'Cart',)
      ]),
    );
  }
}
