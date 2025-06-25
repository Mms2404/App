import 'package:app/common/buttons.dart';
import 'package:app/constants/colors.dart';
import 'package:app/screens/purchase/screens/home.dart';
import 'package:flutter/material.dart';

class Purchase extends StatelessWidget {
  const Purchase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          
              Icon(Icons.trolley , size: 100,),
          
              SizedBox(height: 30,),
              Text("DISCOVER YOUR PERFECT SUCCULENT COMPANION", 
                  style: TextStyle( fontSize: 25),textAlign: TextAlign.center),
              SizedBox(height: 15,),
              Text("Beautiful, easy-to-care-for plants that brighten your space and boost your mood every day." , 
                  style: TextStyle(fontSize: 15 , color: AppColors.grey ),textAlign: TextAlign.center,),
              SizedBox(height: 30,),
          
              ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context)=>Home()));
                }, 
                style: AppButtonStyles.commonButton,
                child: Text("Shop Now"))
            ],
          ),
        )
      ),
    );
  }
}