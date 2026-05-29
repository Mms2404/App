import 'package:app/core/constants/colors.dart';
import 'package:app/features/purchase/providers/cart_model.dart';
import 'package:app/features/purchase/screens/widgets/cartItem.dart';
import 'package:app/features/purchase/screens/checkout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Column(
        children: [
          Text(
            'My Cart',
            style: TextStyle(
              fontSize: 30.sp,
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Manrope',
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Consumer<CartModel>(
              builder: (_, cart, __) {
                if (cart.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 40.sp,
                          color: AppColors.lightTextTertiary,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14.sp,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: cart.itemCount,
                  itemBuilder: (_, i) => CartItem(item: cart.lines[i].item),
                );
              },
            ),
          ),
           Consumer<CartModel>(
            builder: (_, cart, __) {
              final disabled = cart.isEmpty;
              return Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                child: _BuyButton(
                  enabled: !disabled,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // CheckoutScreen is a NEW Navigator route — it lives outside Home's
                        // MultiProvider subtree, so it can't see CartModel on its own.
                        // ChangeNotifierProvider.value passes the EXISTING instance across the
                        // route boundary. (Using .value, not create: — we reuse the live cart,
                        // we don't build a new empty one.)
                        builder: (_) => ChangeNotifierProvider.value(
                          value: cart,
                          child: const CheckoutScreen(),
                        ),
                      )
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


class _BuyButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _BuyButton({required this.enabled, required this.onTap});

  @override
  State<_BuyButton> createState() => _BuyButtonState();
}

class _BuyButtonState extends State<_BuyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 52.h,
        decoration: BoxDecoration(
          color: !widget.enabled
              ? AppColors.lightElevated
              : _pressed
                  ? const Color(0xFF2E7D4F)
                  : AppColors.success,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Buy now',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: widget.enabled
                      ? Colors.white
                      : AppColors.lightTextTertiary,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16.sp,
                color: widget.enabled
                    ? Colors.white
                    : AppColors.lightTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}