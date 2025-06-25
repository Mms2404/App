import 'package:app/constants/colors.dart';
import 'package:flutter/material.dart';

class AppButtonStyles {

static ButtonStyle topButton = ElevatedButton.styleFrom(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.palegreen,
      minimumSize: Size(400, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(25),
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
    );
  

static ButtonStyle bottomButton = ElevatedButton.styleFrom(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.palegreen,
      minimumSize: Size(400, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(10),
        ),
      ),
    );

static ButtonStyle commonButton= ElevatedButton.styleFrom(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.palegreen,
      minimumSize: Size(400, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
    );


}
