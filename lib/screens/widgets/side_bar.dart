import 'package:app/constants/colors.dart';
import 'package:flutter/material.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {

  bool isExit = false ;
  bool isContinue =false ;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Container(
          width: 260,
          height: double.infinity,
          color: AppColors.black,
          child: Column(
            children: [
              Spacer(flex: 1,),
              ListTile(
                leading: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.white,
                  child: Icon(Icons.person_2_outlined, color:Colors.grey,),
                ),
                title: Center(child: Text("MADHUMITA" , style: TextStyle(color: AppColors.white , fontWeight: FontWeight.bold),)),
                subtitle: Text("Just going with the flow ...", 
                textAlign: TextAlign.center,
                style: TextStyle(color: const Color.fromARGB(255, 197, 195, 195)),
                ),
              ),
          
          
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    _featureTile(Icons.search, "A search screen [Gemini LLM, YouTube API]"),
                    _featureTile(Icons.shopping_bag, "A purchase screen [Online plants shopping]"),
                    _featureTile(Icons.account_balance_wallet, "A user screen [Expense tracker, Django API]"),
                    _featureTile(Icons.chat, "A chat screen [Messaging, notifications]"),
                    _featureTile(Icons.book, "A ledger screen [Hyperledger Fabric backend]"),
                  ],
                ),
              ),
          
              Divider(thickness: 1,color: Colors.grey,indent: 10,endIndent: 10,),
          
              Stack(
                children: [
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 200),
                    height: 56,
                    width: isExit? 260 : 0,
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.palegreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        isExit = !isExit ;
                        isContinue = false ;  
                      });
                    },
                    child: ListTile(
                      leading: Icon(Icons.logout_rounded, ),
                      title: Text("Wanna Exit ?" ,style: TextStyle(
                      color: isExit? AppColors.black : AppColors.white , fontWeight: FontWeight.bold),),
                    ),
                  ),
                ],
              ),
               Spacer(flex: 1,),
            ],
          ),
        )
      ),
    );
  }
}


Widget _featureTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.palegreen, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }