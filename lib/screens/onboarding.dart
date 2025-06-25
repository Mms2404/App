import 'dart:ui';
import 'package:app/common/buttons.dart';
import 'package:app/common/dialogBox.dart';
import 'package:app/constants/colors.dart';
import 'package:app/screens/authentication/presentation/screens/login_form.dart';
import 'package:app/screens/authentication/presentation/screens/signUp_screen.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          RiveAnimation.asset("assets/rive/triangle_light.riv"),
      
          Positioned.fill(child: (BackdropFilter(filter: ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 10),
            child: SizedBox(),))),
      
          Positioned(
            top: 150,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SafeArea(
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text("N" , style: TextStyle(fontSize: 150 , color: AppColors.black),),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("OW ",style: TextStyle(fontSize: 40 , color: AppColors.black),),
                            Row(
                              children: [
                                Text(" OR  " , style: TextStyle( fontWeight:FontWeight.bold , color:  AppColors.palegreen)) , 
                                SizedBox(
                                  width: 180,
                                  child: Divider(thickness: 2,color: AppColors.palegreen,)),
                              ],
                            ),
                            Text("EVER",style: TextStyle(fontSize: 40 , color: AppColors.black),),
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: ElevatedButton(
                            onPressed: (){
                              Future.delayed(
                                Duration(milliseconds: 800),
                                (){
                                 AppDialog.show(context, LoginForm());
                              });
                            },
                            style:AppButtonStyles.topButton,
                            child: Text("LOGIN")
                      ),
                    ),

                    SizedBox(height: 30,),

                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: ElevatedButton(
                            onPressed: (){
                              Future.delayed(
                                Duration(milliseconds: 800),
                                (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpScreen()));
                              });
                            },
                            style:AppButtonStyles.bottomButton,
                            child: Text("SIGN UP")
                      ),
                    )
                  ],
                )
              ),
            ),
          ),

      
          
         
        ],
      ),
    );
  }


}