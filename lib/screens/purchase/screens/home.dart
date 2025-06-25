import 'package:app/screens/purchase/models/userCart.dart';
import 'package:app/screens/purchase/screens/cart.dart';
import 'package:app/screens/purchase/screens/shop.dart';
import 'package:app/screens/purchase/screens/widgets/navBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _selectedIndex = 0;

  // to update selected index ( 0 = shop  , 1 = cart)
  void navigate(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> pages = [
    Shop(),
    Cart()
  ];


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserCart(),
      builder: (context , child) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: "Exit",
            onPressed:()=> Navigator.of(context).pop(), 
            icon: Icon(Icons.arrow_back_ios))
        ),
      
        bottomNavigationBar: Navbar(
          onTabChange: (index) => navigate(index),),
      
        body: pages[_selectedIndex],
      ),
    );
  }
}