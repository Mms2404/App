import 'package:app/core/constants/colors.dart';
import 'package:app/core/widgets/light_searchBar.dart';
import 'package:app/features/purchase/data/models.dart';
import 'package:app/features/purchase/providers/cart_model.dart';
import 'package:app/features/purchase/providers/shop_catalog.dart';
import 'package:app/features/purchase/screens/widgets/pot_tile.dart';
import 'package:app/features/purchase/screens/widgets/succulent_tile.dart';
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
          backgroundColor: AppColors.lightTextPrimary,
          action: SnackBarAction(
            label: 'View',
            textColor: AppColors.success,
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
          LightSearchBar(
            controller: _searchController,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Consumer<ShopCatalog>(
              builder: (_, catalog, __) {
                if (catalog.isLoading && !catalog.hasData) {
                  return const _LightLoading(message: 'Loading the shop…');
                }

                if (catalog.error != null && !catalog.hasData) {
                  return _LightError(
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
                      const Text(
                        'Highlights ..',
                        style: TextStyle(
                          fontSize: 25,
                          color: AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                      const Text(
                        'Choose a pot ..',
                        style: TextStyle(
                          fontSize: 25,
                          color: AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                  color: AppColors.lightTextTertiary,
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

class _LightLoading extends StatelessWidget {
  final String message;
  const _LightLoading({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LightError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LightError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 32,
            color: AppColors.danger,
          ),
          const SizedBox(height: 12),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                color: AppColors.lightTextTertiary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.lightSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lightBorderStrong),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 14, color: AppColors.lightTextPrimary),
                  SizedBox(width: 6),
                  Text(
                    'Try again',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}