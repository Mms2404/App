import 'package:app/core/constants/colors.dart';
import 'package:app/core/utils/logger.dart';
import 'package:app/core/utils/validators.dart';
import 'package:app/core/widgets/textField.dart';
import 'package:app/features/purchase/providers/cart_model.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color _shopAccent = AppColors.success;

  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _fetchingLocation = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _fetchingLocation = true);

    try {
      // 1. Check if location service is on
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        _showSnackbar(
          'Location services are off. Turn on GPS to use this feature.',
          actionLabel: 'Open Settings',
          onAction: () => AppSettings.openAppSettings(
            type: AppSettingsType.location,
          ),
        );
        return;
      }

      // 2. Check / request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          _showSnackbar(
            'Location permission denied. You can type your address manually.',
            actionLabel: 'Try again',
            onAction: _useCurrentLocation,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _showSnackbar(
          'Location permission permanently denied. Enable it in settings to use this feature.',
          actionLabel: 'Open Settings',
          onAction: () => AppSettings.openAppSettings(),
        );
        return;
      }

      // 3. Fetch position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // 4. Reverse geocode
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        if (!mounted) return;
        _showSnackbar('Could not determine address. Try typing manually.');
        return;
      }

      final p = placemarks.first;
      final address = [
        p.name,
        p.subLocality,
        p.locality,
        p.administrativeArea,
        p.postalCode,
      ].where((s) => s != null && s.isNotEmpty).join(', ');

      if (!mounted) return;
      setState(() {
        _addressCtrl.text = address;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackbar('Couldn\'t fetch location. Try again or type manually.');
    } finally {
      if (mounted) {
        setState(() => _fetchingLocation = false);
      }
    }
  }

  void _showSnackbar(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.lightTextPrimary,
          action: actionLabel != null && onAction != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: _shopAccent,
                  onPressed: onAction,
                )
              : SnackBarAction(
                  label: 'Dismiss',
                  textColor: _shopAccent,
                  onPressed: () {},
                ),
        ),
      );
  }

  void _pay() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: wire Razorpay + Django backend
    log.d('Pay tapped. Phone: ${_phoneCtrl.text}, Address: ${_addressCtrl.text}');
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final subtotal = cart.subtotal;
    final delivery = cart.isEmpty ? 0.0 : 20.0;
    final grandTotal = subtotal + delivery;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.lightTextPrimary,
            size: 18,
          ),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionLabel('Order summary'),
                const SizedBox(height: 8),
                _SummaryCard(),
                const SizedBox(height: 24),
                _SectionLabel('Contact'),
                const SizedBox(height: 8),
                LightTextField(
                  controller: _phoneCtrl,
                  labelText: 'Phone',
                  hintText: 'Phone number',
                  prefixText: '+91',
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: AppValidators.phone,
                  ),
                const SizedBox(height: 20),
                _SectionLabel('Delivery address'),
                const SizedBox(height: 8),
                LightTextField(
                  controller: _addressCtrl,
                  labelText: 'Address',
                  hintText: 'Street, area, city, pincode',
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
  validator: (v) => AppValidators.minLength(v, 10, 'Address')
),
                const SizedBox(height: 32),
                GestureDetector(
  onTap: _fetchingLocation ? null : _useCurrentLocation,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.lightElevated,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.lightBorder, width: 0.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _fetchingLocation
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  valueColor: AlwaysStoppedAnimation(AppColors.success),
                ),
              )
            : const Icon(
                Icons.my_location_rounded,
                size: 16,
                color: AppColors.success,
              ),
        const SizedBox(width: 8),
        Text(
          _fetchingLocation ? 'Fetching…' : 'Use current location',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.success,
          ),
        ),
      ],
    ),
  ),
),
const SizedBox(height: 32),
                _PayButton(
                  amount: grandTotal,
                  onTap: _pay,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: AppColors.lightTextTertiary,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  static const double _deliveryFee = 20.0;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final subtotal = cart.subtotal;
    final delivery = cart.isEmpty ? 0.0 : _deliveryFee;
    final total = subtotal + delivery;

    if (cart.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightBorder, width: 0.5),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_bag_outlined,
                  size: 32, color: AppColors.lightTextTertiary),
              const SizedBox(height: 8),
              Text(
                'Your cart is empty',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder, width: 0.5),
      ),
      child: Column(
        children: [
          // Each line with thumbnail, name, qty stepper, line total
          ...cart.lines.map((line) => _SummaryLine(line: line)),
          const SizedBox(height: 4),
          Divider(color: AppColors.lightBorder, height: 16),
          _TotalRow(label: 'Subtotal', value: subtotal),
          const SizedBox(height: 6),
          _TotalRow(label: 'Delivery', value: delivery),
          const SizedBox(height: 8),
          Divider(color: AppColors.lightBorder, height: 16),
          _TotalRow(label: 'Total', value: total, emphasized: true),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final CartLine line;
  const _SummaryLine({required this.line});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartModel>();
    final item = line.item;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical:4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
                onTap: () => cart.removeLine(item),
                child: Icon(Icons.close_rounded,
                    size: 16, color: AppColors.lightTextTertiary),
              ),
              const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imagePath,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 45,
                height: 45,
                color: AppColors.lightElevated,
                child: const Icon(Icons.local_florist_outlined,
                    size: 18, color: AppColors.lightTextTertiary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rs. ${item.price}',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniStepper(
                  qty: line.qty,
                  onIncrement: () => cart.increment(item),
                  onDecrement: () => cart.decrement(item),
                ),
              SizedBox(height: 4),
              Text(
                'Rs. ${line.lineTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 75, 73, 73),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _MiniStepper({
    required this.qty,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.lightBorder, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: const Padding(
              padding: EdgeInsets.all(5),
              child: Icon(Icons.remove_rounded, size: 14, color: AppColors.success),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$qty',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: const Padding(
              padding: EdgeInsets.all(5),
              child: Icon(Icons.add_rounded, size: 14, color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasized;

  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: emphasized ? 15 : 13,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
            color: emphasized
                ? AppColors.lightTextPrimary
                : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          'Rs. ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: emphasized ? 17 : 13,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
            color: AppColors.lightTextPrimary,
            letterSpacing: emphasized ? -0.3 : 0,
          ),
        ),
      ],
    );
  }
}
class _PayButton extends StatefulWidget {
  final double amount;
  final VoidCallback onTap;

  const _PayButton({required this.amount, required this.onTap});

  @override
  State<_PayButton> createState() => _PayButtonState();
}

class _PayButtonState extends State<_PayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 56,
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFF2E7D4F) : AppColors.success,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'Pay Rs. ${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}