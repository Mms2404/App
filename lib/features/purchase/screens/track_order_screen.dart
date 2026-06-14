// TRACK ORDER SCREEN
// -----------------------------------------------------------------------------
// Customer enters their phone number to see all their past orders + statuses.
// Opened from a button on the Purchase landing page.
// No auth needed — matches Django's CustomerOrdersView (public, by phone).
// -----------------------------------------------------------------------------

import 'package:app/core/constants/colors.dart';
import 'package:app/features/purchase/data/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final _phoneCtrl = TextEditingController();
  final _repo = OrderRepository();

  List<OrderDetail>? _orders;
  bool _loading = false;
  String? _error;
  bool _searched = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) {
      setState(() => _error = 'Enter a valid 10-digit phone number.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });
    try {
      final orders = await _repo.fetchOrdersByPhone(phone);
      setState(() => _orders = orders);
    } on OrderException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: AppColors.lightTextPrimary, size: 18.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Track your order',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Text(
              'Enter the phone number you used when ordering.',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13.sp,
                color: AppColors.lightTextSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            // Phone input + search button row
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightElevated,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.lightBorderStrong),
                    ),
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onSubmitted: (_) => _search(),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        hintStyle: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14.sp,
                          color: AppColors.lightTextTertiary,
                        ),
                        prefixIcon: Icon(Icons.phone_outlined,
                            size: 18.sp,
                            color: AppColors.lightTextTertiary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: _loading ? null : _search,
                  child: Container(
                    height: 48.h,
                    width: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: _loading
                        ? Padding(
                            padding: EdgeInsets.all(14.w),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Icon(Icons.search_rounded,
                            color: Colors.white, size: 22.sp),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              SizedBox(height: 10.h),
              Text(
                _error!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.red.shade700,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
            SizedBox(height: 20.h),
            // Results
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (!_searched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping_outlined,
                size: 40.sp, color: AppColors.lightTextTertiary),
            SizedBox(height: 12.h),
            Text(
              'Enter your phone number above\nto see your orders.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13.sp,
                color: AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      );
    }

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.success),
      );
    }

    if (_orders == null || _orders!.isEmpty) {
      return Center(
        child: Text(
          'No orders found for this number.',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14.sp,
            color: AppColors.lightTextSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _orders!.length,
      itemBuilder: (_, i) => _CustomerOrderCard(order: _orders![i]),
    );
  }
}

// ---------------------------------------------------------------------------
// Customer-facing order card (read-only)
// ---------------------------------------------------------------------------
class _CustomerOrderCard extends StatelessWidget {
  final OrderDetail order;
  const _CustomerOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id}',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            _formatDate(order.createdAt),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11.sp,
              color: AppColors.lightTextTertiary,
            ),
          ),
          SizedBox(height: 8.h),
          ...order.items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  '${item.productName} × ${item.quantity}',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              )),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13.sp,
                  color: AppColors.lightTextSecondary,
                ),
              ),
              Text(
                'Rs. ${order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          // Progress stepper
          SizedBox(height: 14.h),
          _StatusStepper(status: order.status),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

// ---------------------------------------------------------------------------
// Simple linear status stepper
// ---------------------------------------------------------------------------
class _StatusStepper extends StatelessWidget {
  final String status;
  const _StatusStepper({required this.status});

  static const _steps = ['pending', 'confirmed', 'shipped', 'delivered'];

  static const _stepColors = {
    'pending': Color(0xFFFACC15),
    'confirmed': Color(0xFF60A5FA),
    'shipped': Color(0xFFA78BFA),
    'delivered': Color(0xFF4ADE80),
    'cancelled': Color(0xFFFF6B6B),
  };

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') {
      return Row(
        children: [
          Icon(Icons.cancel_outlined, size: 14.sp, color: const Color(0xFFFF6B6B)),
          SizedBox(width: 6.w),
          Text(
            'Order cancelled',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12.sp,
              color: const Color(0xFFFF6B6B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final currentIdx = _steps.indexOf(status);

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIdx = i ~/ 2;
          final filled = stepIdx < currentIdx;
          return Expanded(
            child: Container(
              height: 2.h,
              color: filled
                  ? AppColors.success
                  : AppColors.lightBorder,
            ),
          );
        }
        // Step dot
        final stepIdx = i ~/ 2;
        final done = stepIdx <= currentIdx;
        final color =
            done ? (_stepColors[_steps[stepIdx]] ?? AppColors.success) : AppColors.lightBorder;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: done ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.5),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _steps[stepIdx][0].toUpperCase() +
                  _steps[stepIdx].substring(1),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 9.sp,
                color: done
                    ? AppColors.lightTextPrimary
                    : AppColors.lightTextTertiary,
                fontWeight:
                    done ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }

  
}


class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  static const _colors = {
    'pending': Color(0xFFFACC15),
    'confirmed': Color(0xFF60A5FA),
    'shipped': Color(0xFFA78BFA),
    'delivered': Color(0xFF4ADE80),
    'cancelled': Color(0xFFFF6B6B),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status] ?? AppColors.lightTextTertiary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}