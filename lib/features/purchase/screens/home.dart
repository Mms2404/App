import 'package:app/core/constants/colors.dart';
import 'package:app/features/purchase/data/shop_repository.dart';
import 'package:app/features/purchase/providers/cart_model.dart';
import 'package:app/features/purchase/providers/shop_catalog.dart';
import 'package:app/features/purchase/screens/cart.dart';
import 'package:app/features/purchase/screens/shop.dart';
import 'package:app/features/purchase/screens/widgets/navBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {

// PROVIDER SCOPING — why providers live HERE
// -----------------------------------------------------------------------------
// These providers are scoped to the shop feature, not global. They're created
// when Home builds and disposed when Home leaves the tree. CartModel, the
// catalog, and the repository only matter while the user is shopping — no
// reason to keep them alive app-wide.
//
// The catch: provider scope does NOT cross Navigator routes. Shop and Cart
// (inside _HomeView's IndexedStack) are part of THIS widget subtree, so they
// see these providers fine. But any screen pushed with Navigator.push (like
// CheckoutScreen) becomes a SIBLING route in the navigator stack — outside this
// subtree — and can't see CartModel.
//
// That's why CheckoutScreen is pushed wrapped in ChangeNotifierProvider.value
// (see cart.dart): we hand the SAME CartModel instance across the route
// boundary so checkout reads the same cart, not a fresh empty one.
// -----------------------------------------------------------------------------
    
    return MultiProvider(
      providers: [
        Provider<ShopRepository>(
          create: (_) => ShopRepository(),
          dispose: (_, repo) => repo.dispose(),
        ),
        ChangeNotifierProvider<CartModel>(
          create: (_) => CartModel(),
        ),
        ChangeNotifierProxyProvider<ShopRepository, ShopCatalog>(
          create: (ctx) => ShopCatalog(ctx.read<ShopRepository>())..fetchAll(),
          update: (_, repo, prev) => prev ?? ShopCatalog(repo)..fetchAll(),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _selectedIndex = 0;

  static const _pages = [Shop(), Cart()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Exit',
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.lightTextPrimary,
            size: 18.sp,
          ),
        ),
      ),
      bottomNavigationBar: Navbar(
        onTabChange: (i) => setState(() => _selectedIndex = i),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }
}