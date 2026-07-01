import 'dart:math';
import 'package:app/core/constants/colors.dart';
import 'package:app/core/utils/rive.dart';
import 'package:app/features/chat/chat_gateway.dart';
import 'package:app/features/expense_tracker/expense_tracker_gateway.dart';
import 'package:app/features/music/music_gateway.dart';
import 'package:app/features/onboarding.dart';
import 'package:app/features/purchase/screens/purchase.dart';
import 'package:app/features/search/presentation/screens/search.dart';
import 'package:app/core/widgets/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

// manual override to hide the navBar and MenuBtn in secondary screens
bool _chromeOverride = true;
void _setChromeVisible(bool visible) {
  if (_chromeOverride == visible) return;
  setState(() => _chromeOverride = visible);
}

 bool get showNavigation => isMainScreen(selectedIndex) && _chromeOverride;

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

  void _exitToOnboarding() {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const Onboarding()),
    (route) => false,
  );
}



  List<Widget> get screens => [     // getter imp
    Search(),
    Purchase(),
    ExpenseTrackerGateway(onChromeOverride: _setChromeVisible),  // passing the override callback to the gateway
    MusicGateway(onChromeOverride: _setChromeVisible),  // passing the override callback to the gateway
    ChatGateway(onChromeOverride: _setChromeVisible),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,  // this one and the next line is to make the body
      extendBody: true,                // use the full screen  
      backgroundColor: Color.fromARGB(255, 22, 23, 23),

      bottomNavigationBar: showNavigation 
      ?Transform.translate(
        offset: Offset(0, 100 * animation.value),
        child: Container(
          height: 70.h,
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: const Color.fromARGB(167, 49, 49, 49),
            borderRadius: BorderRadius.circular(25.r),
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
                        height: 4.h,
                        width: bottomIcons[index] == selectedNavIcon ? 20 : 0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: AppColors.palegreen,
                        ),
                      ),
                      SizedBox(height: 4.5.h),
                      SizedBox(
                        height: 30.h,
                        width: 35.w,
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
            width: 288.w,
            left: isDrawerClosed ? -288.w : 0,
            height: MediaQuery.of(context).size.height,
            child: SideBar(onExit: _exitToOnboarding),
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
                  borderRadius: BorderRadius.circular(25.r),
                  child: screens[selectedIndex],   // make sure the screen given to body has bottom: false,
                ),
              ),
            ),
          ):screens[selectedIndex],
          

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
          margin: EdgeInsets.only(left: 16.w),
          height: 40.h,
          width: 40.w,
          decoration: BoxDecoration(
            color: const Color.fromARGB(184, 49, 49, 49),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDrawerClosed ? Icons.menu : Icons.close,
            color: Colors.white,
            size: 28.h,
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
      artboard: "REFRESH/RELOAD",
      stateMachineName: "RELOAD_Interactivity",
      title: "Blockchain"),
  RiveIcons("assets/rive/icons.riv",
      artboard: "CHAT",
      stateMachineName: "CHAT_Interactivity",
      title: "Chat"),
];
