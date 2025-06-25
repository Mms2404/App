import 'package:app/common/buttons.dart';
import 'package:app/constants/colors.dart';
import 'package:app/screens/home.dart';
import 'package:app/utils/rive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rive/rive.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isShowLoading =false;

  late SMITrigger check;
  late SMITrigger error;
  late SMITrigger reset;

 
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text("WELCOME BACK !" , style: TextStyle(fontSize: 25 , fontWeight: FontWeight.bold),),

                SizedBox(height: 10,),
            
                TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return "";
                    }
                    return null ;
                  },
                  onSaved: (email){} ,
                  cursorColor: AppColors.palegreen,
                  decoration: InputDecoration(
                    //prefix icon
                    hintText: "Email"
                  ),
                ),
            
                SizedBox(height: 20,),
            
                TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return "";
                    }
                    return null ;
                  },
                  onSaved: (password){},
                  obscureText: true,
                  cursorColor: AppColors.palegreen,
                  decoration: InputDecoration(
                    //prefix icon
                    hintText: "Password"
                  ),
                ),
            
                SizedBox(height: 80,),
            
                ElevatedButton(
                  onPressed: (){
                    setState(() {
                      isShowLoading = true;
                    });
                    Future.delayed(Duration(seconds: 1),
                    (){
                     if(_formKey.currentState!.validate()){
                      check.fire();
                      Future.delayed(Duration(seconds: 2),
                      (){
                        setState(() {
                          isShowLoading = false;
                        });
                      });
                      Future.delayed(Duration(seconds: 3),
                      (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
                      });
                     } 
                     else{
                      error.fire();
                      Future.delayed(Duration(seconds: 2),
                      (){
                        setState(() {
                          isShowLoading = false;
                        });
                      });
                    } 
                    });
                  }, 
                  style: AppButtonStyles.topButton,
                  child: Text("LOGIN"),),
            
                  SizedBox(height: 20,),
                  Text("---------  OR  ---------" ,),
                  SizedBox(height: 20,),
            
                  ElevatedButton(
                  onPressed: (){}, 
                  style:AppButtonStyles.bottomButton,
                  child: Text("Don't have an account ?"),
                  ),
            
              ],
            )
          ),
        ),

        isShowLoading?
         Ani_Positioned(
          size: 100,
          child:RiveAnimation.asset(
                  "assets/rive/check_error.riv",
                  onInit: (artboard){
                    StateMachineController controller = 
                    RiveUtils.getRiveController(artboard);
                    check = controller.findSMI("Check") as SMITrigger;
                    error = controller.findSMI("Error") as SMITrigger;
                    reset = controller.findSMI("Reset") as SMITrigger;
                  },),): SizedBox()
      ],
    );
  }
}


class Ani_Positioned extends StatelessWidget {
  const Ani_Positioned({super.key , required this.child , required this.size});

  final Widget child;
  final double size;


  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
          child: Column(
            children: [
              Spacer(flex: 2),
              SizedBox(
                height: size,
                width: size,
                child: child, 
              ),
              Spacer(flex: 2,)
            ],
          )
      );
  }
}