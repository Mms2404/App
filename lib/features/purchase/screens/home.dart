import 'package:app/features/purchase/data/shop_repository.dart';
import 'package:app/features/purchase/providers/cart_model.dart';
import 'package:app/features/purchase/providers/shop_catalog.dart';
import 'package:app/features/purchase/screens/cart.dart';
import 'package:app/features/purchase/screens/shop.dart';
import 'package:app/features/purchase/screens/widgets/navBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Exit',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
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