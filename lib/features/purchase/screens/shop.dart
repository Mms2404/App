import 'package:app/core/constants/colors.dart';
import 'package:app/core/widgets/textField.dart';
import 'package:app/features/purchase/data/models.dart';
import 'package:app/features/purchase/providers/cart_model.dart';
import 'package:app/features/purchase/providers/shop_catalog.dart';
import 'package:app/features/purchase/screens/widgets/pot_tile.dart';
import 'package:app/features/purchase/screens/widgets/succulent_tile.dart';
import 'package:app/features/search/presentation/widgets/ui_states.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Shop extends StatefulWidget {
  const Shop({super.key});

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(CartItemModel item) {
    context.read<CartModel>().addItem(item);
    _showAddedSnackbar(item.name);
  }

  void _showAddedSnackbar(String itemName) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$itemName added to cart'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'View',
            onPressed: () {},
          ),
        ),
      );
  }

  List<Succulents> _filteredSucculents(List<Succulents> source) {
    if (_query.isEmpty) return source;
    return source
        .where((s) =>
            s.name.toLowerCase().contains(_query) ||
            s.description.toLowerCase().contains(_query))
        .toList();
  }

  List<Pots> _filteredPots(List<Pots> source) {
    if (_query.isEmpty) return source;
    return source
        .where((p) =>
            p.name.toLowerCase().contains(_query) ||
            p.material.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: _searchController,
            labelText: 'Search',
            suffixIcon: const Icon(Icons.search, color: AppColors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Consumer<ShopCatalog>(
              builder: (_, catalog, __) {
                if (catalog.isLoading && !catalog.hasData) {
                  return const LoadingState(message: 'Loading the shop…');
                }

                if (catalog.error != null && !catalog.hasData) {
                  return ErrorStateView(
                    message: catalog.error!.message,
                    onRetry: catalog.retry,
                  );
                }

                final succulents = _filteredSucculents(catalog.succulents);
                final pots = _filteredPots(catalog.pots);

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Highlights ..',
                          style: TextStyle(fontSize: 25)),
                      const SizedBox(height: 10),
                      _HorizontalRow(
                        height: 340,
                        emptyMessage: _query.isNotEmpty
                            ? 'No matching succulents'
                            : 'No succulents available',
                        itemCount: succulents.length,
                        builder: (i) => SucculentTile(
                          succulent: succulents[i],
                          onTap: () => _addToCart(succulents[i]),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Choose a pot ..',
                          style: TextStyle(fontSize: 25)),
                      const SizedBox(height: 10),
                      _HorizontalRow(
                        height: 320,
                        emptyMessage: _query.isNotEmpty
                            ? 'No matching pots'
                            : 'No pots available',
                        itemCount: pots.length,
                        builder: (i) => PotTile(
                          pot: pots[i],
                          onTap: () => _addToCart(pots[i]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalRow extends StatelessWidget {
  final double height;
  final int itemCount;
  final Widget Function(int) builder;
  final String emptyMessage;

  const _HorizontalRow({
    required this.height,
    required this.itemCount,
    required this.builder,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: itemCount == 0
          ? Center(
              child: Text(
                emptyMessage,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 13,
                ),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              itemBuilder: (_, i) => builder(i),
            ),
    );
  }
}