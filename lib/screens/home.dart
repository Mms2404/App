import 'dart:math';

import 'package:app/constants/colors.dart';
import 'package:app/screens/chat.dart';
import 'package:app/screens/ledger.dart';
import 'package:app/screens/purchase/screens/purchase.dart';
import 'package:app/screens/search.dart';
import 'package:app/screens/user/presentation/screens/expense_list_screen.dart';
import 'package:app/screens/user/presentation/screens/expense_login_screen.dart';
import 'package:app/screens/widgets/side_bar.dart';
import 'package:app/utils/rive.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  RiveIcons selectedNavIcon = bottomIcons[0];
  bool isDrawerClosed = true;


  // for hiding the navbar and MenuBtn in secondary screens 
  bool isMainScreen(int index) {
  // only main screens those in the bottom nav bar return true.
  return index >= 0 && index < screens.length;
 }
 bool get showNavigation => isMainScreen(selectedIndex);

  late AnimationController _animationController;
  late Animation<double> animation;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {});
      });

    animation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));

    scaleAnimation =
        Tween<double>(begin: 1, end: 0.8).animate(CurvedAnimation(   // begin and end values adjusts the size of the screen given to the body 
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleDrawer() {
    if (isDrawerClosed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {
      isDrawerClosed = !isDrawerClosed;
    });
  }

  void _handleLogout() {
  Navigator.of(context).pop(); 
}
  
  // for Expense_Tracker_Login_Screen 
  void _handleLoginSuccess() {
    Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ExpenseListScreen(onLogout: _handleLogout),
    ),
  );
}



  List<Widget> get screens => [     // getter imp
    Search(),
    Purchase(),
    ExpenseLoginScreen(onLoginSuccess: _handleLoginSuccess),
    Chat(),
    Ledger(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,  // this one and the next line is to make the body
      extendBody: true,                // use the full screen  
      backgroundColor: AppColors.black,

      bottomNavigationBar: showNavigation 
      ?Transform.translate(
        offset: Offset(0, 100 * animation.value),
        child: Container(
          height: 70,
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(167, 49, 49, 49),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...List.generate(
                bottomIcons.length,
                (index) => GestureDetector(
                  onTap: () {
                    if (bottomIcons[index] != selectedNavIcon) {
                      setState(() {
                        selectedIndex = index;
                        selectedNavIcon = bottomIcons[index];
                      });
                    }
                    bottomIcons[index].input?.change(true);
                    Future.delayed(
                      Duration(seconds: 1),
                      () {
                        bottomIcons[index].input?.change(false);
                      },
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        height: 4,
                        width: bottomIcons[index] == selectedNavIcon ? 20 : 0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.palegreen,
                        ),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        height: 30,
                        width: 35,
                        child: Opacity(
                          opacity:
                              bottomIcons[index] == selectedNavIcon ? 1 : 0.5,
                          child: RiveAnimation.asset(
                            bottomIcons[index].src,
                            artboard: bottomIcons[index].artboard,
                            onInit: (artboard) {
                              StateMachineController controller =
                                  RiveUtils.getRiveController(
                                artboard,
                                stateMachineName:
                                    bottomIcons[index].stateMachineName,
                              );
        
                              bottomIcons[index].input =
                                  controller.findSMI("active") as SMIBool?;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ): null,   // hiding of navBar handled


      body: Stack(
        children: [

          // Sidebar
          AnimatedPositioned(
            duration: Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            width: 288,
            left: isDrawerClosed ? -288 : 0,
            height: MediaQuery.of(context).size.height,
            child: SideBar(),
          ),

          // Display screen transformation
          !isDrawerClosed? Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0009)  //imp
              ..rotateY(animation.value - 30 * animation.value * pi / 180),
            child: Transform.translate(
              offset: Offset(animation.value * 233, 0),
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: screens[selectedIndex],   // make sure the screen given to body has bottom: false,
                ),
              ),
            ),
          ): screens[selectedIndex],
          

          // Menu button
          if (showNavigation)
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            child: MenuBtn(
              isDrawerClosed: isDrawerClosed,
              press: toggleDrawer,
            ),
          )
        ],
      ),

      
    );
  }
}

class MenuBtn extends StatelessWidget {
  final bool isDrawerClosed;
  final VoidCallback press;

  const MenuBtn({
    super.key,
    required this.isDrawerClosed,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: press,
        child: Container(
          margin: EdgeInsets.only(left: 16),
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: const Color.fromARGB(184, 49, 49, 49),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDrawerClosed ? Icons.menu : Icons.close,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class RiveIcons {
  final String artboard, stateMachineName, title, src;
  SMIBool? input;

  RiveIcons(
    this.src, {
    required this.artboard,
    required this.stateMachineName,
    required this.title,
    this.input,
  });

  set setInput(SMIBool? status) {
    input = status;
  }
}

List<RiveIcons> bottomIcons = [
  RiveIcons("assets/rive/icons.riv",
      artboard: "SEARCH",
      stateMachineName: "SEARCH_Interactivity",
      title: "Search"),
  RiveIcons("assets/rive/icons.riv",
      artboard: "LIKE/STAR",
      stateMachineName: "STAR_Interactivity",
      title: "Purchase"),
  RiveIcons("assets/rive/icons.riv",
      artboard: "USER",
      stateMachineName: "USER_Interactivity",
      title: "Me"),
  RiveIcons("assets/rive/icons.riv",
      artboard: "CHAT",
      stateMachineName: "CHAT_Interactivity",
      title: "Chat"),
  RiveIcons("assets/rive/icons.riv",
      artboard: "REFRESH/RELOAD",
      stateMachineName: "RELOAD_Interactivity",
      title: "Blockchain"),
];
