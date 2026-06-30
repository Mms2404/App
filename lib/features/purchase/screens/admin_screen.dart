// ADMIN SCREEN
// -----------------------------------------------------------------------------
// Accessible by double-tapping the plant logo on the Purchase landing page.
// Flow:
//   1. AdminLoginSheet  — username / password → POST api-token-auth
//   2. AdminOrdersScreen — lists ALL orders, admin can change status
// Token is kept in memory (never persisted — session only).
// -----------------------------------------------------------------------------

import 'package:app/core/constants/colors.dart';
import 'package:app/features/purchase/data/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ---------------------------------------------------------------------------
// Entry point — just opens the login bottom sheet
// ---------------------------------------------------------------------------
void showAdminLogin(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AdminLoginSheet(),
  );
}

// ---------------------------------------------------------------------------
// Login sheet
// ---------------------------------------------------------------------------
class _AdminLoginSheet extends StatefulWidget {
  const _AdminLoginSheet();

  @override
  State<_AdminLoginSheet> createState() => _AdminLoginSheetState();
}

class _AdminLoginSheetState extends State<_AdminLoginSheet> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _repo = OrderRepository();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter username and password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await _repo.adminLogin(
        username: username,
        password: password,
      );
      if (!mounted) return;
      Navigator.of(context).pop(); // close sheet
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AdminOrdersScreen(token: token),
      ));
    } on OrderException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.lightBorderStrong,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.admin_panel_settings_outlined,
                      color: AppColors.success, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Admin login',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _LightField(
              controller: _usernameCtrl,
              hint: 'Username',
              icon: Icons.person_outline_rounded,
            ),
            SizedBox(height: 12.h),
            _LightField(
              controller: _passwordCtrl,
              hint: 'Password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              suffix: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18.sp,
                  color: AppColors.lightTextTertiary,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              onSubmitted: (_) => _login(),
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
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.success.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: _loading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'Enter admin panel',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Admin orders screen
// ---------------------------------------------------------------------------
class AdminOrdersScreen extends StatefulWidget {
  final String token;
  const AdminOrdersScreen({super.key, required this.token});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _repo = OrderRepository();
  List<OrderDetail> _orders = [];
  bool _loading = true;
  String? _error;
  String? _filterStatus; // null = all

  static const _statuses = [
    'pending',
    'pending_cod',
    'confirmed',
    'shipped',
    'delivered',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await _repo.fetchAllOrders(
        widget.token,
        statusFilter: _filterStatus,
      );
      setState(() => _orders = orders);
    } on OrderException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(OrderDetail order, String newStatus) async {
    // Optimistic update
    final idx = _orders.indexOf(order);
    setState(() {
      _orders[idx] = order.copyWith(status: newStatus);
    });
    try {
      await _repo.updateOrderStatus(
        token: widget.token,
        orderId: order.id,
        status: newStatus,
      );
    } on OrderException catch (e) {
      // Roll back
      setState(() => _orders[idx] = order);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
          'Orders',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh_rounded,
                color: AppColors.lightTextSecondary, size: 20.sp),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter chips
          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filterStatus == null,
                  onTap: () {
                    setState(() => _filterStatus = null);
                    _load();
                  },
                ),
                ..._statuses.map((s) => _FilterChip(
                      label: _cap(s),
                      selected: _filterStatus == s,
                      onTap: () {
                        setState(() => _filterStatus = s);
                        _load();
                      },
                    )),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.success,
                      strokeWidth: 2,
                    ),
                  )
                : _error != null
                    ? _ErrorView(message: _error!, onRetry: _load)
                    : _orders.isEmpty
                        ? Center(
                            child: Text(
                              'No orders found.',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14.sp,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: AppColors.success,
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                              itemCount: _orders.length,
                              itemBuilder: (_, i) => _AdminOrderCard(
                                order: _orders[i],
                                onStatusChange: (s) =>
                                    _updateStatus(_orders[i], s),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  String _cap(String s) {
    if (s == 'pending_cod') return 'Pending COD';
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }
}

// ---------------------------------------------------------------------------
// Admin order card
// ---------------------------------------------------------------------------
class _AdminOrderCard extends StatelessWidget {
  final OrderDetail order;
  final ValueChanged<String> onStatusChange;

  static const _statuses = [
    'pending',
    'pending_cod',
    'confirmed',
    'shipped',
    'delivered',
    'cancelled',
  ];

  const _AdminOrderCard({
    required this.order,
    required this.onStatusChange,
  });

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
          // Header row: order id + status badge
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
          SizedBox(height: 6.h),
          Text(
            order.phone,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12.sp,
              color: AppColors.lightTextSecondary,
            ),
          ),
          Text(
            order.address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12.sp,
              color: AppColors.lightTextTertiary,
            ),
          ),
          SizedBox(height: 8.h),
          // Items
          ...order.items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.productName} × ${item.quantity}',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12.sp,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      'Rs. ${(item.productPrice * item.quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              )),
          Divider(color: AppColors.lightBorder, height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total  Rs. ${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Status dropdown
              _StatusDropdown(
                current: order.status,
                statuses: _statuses,
                onChanged: onStatusChange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------
class _StatusDropdown extends StatelessWidget {
  final String current;
  final List<String> statuses;
  final ValueChanged<String> onChanged;

  const _StatusDropdown({
    required this.current,
    required this.statuses,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.success.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.success.withOpacity(0.06),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isDense: true,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
          dropdownColor: AppColors.lightSurface,
          items: statuses
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(_cap(s)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null && v != current) onChanged(v);
          },
        ),
      ),
    );
  }

  String _cap(String s) {
    if (s == 'pending_cod') return 'Pending COD';
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  static const _colors = {
    'pending':     Color(0xFFFACC15),
    'pending_cod': Color(0xFFFF9500), // orange — COD not yet collected
    'confirmed':   Color(0xFF60A5FA),
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color.withOpacity(0.85),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 8.h,),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.success
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? AppColors.success
                : AppColors.lightBorderStrong,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined,
              size: 32.sp, color: AppColors.danger),
          SizedBox(height: 12.h),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.sp, color: AppColors.lightTextSecondary)),
          SizedBox(height: 16.h),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: TextButton.styleFrom(foregroundColor: AppColors.success),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared light text field used across admin + tracking sheets
// ---------------------------------------------------------------------------
class _LightField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;
  final TextInputType keyboardType;

  const _LightField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightElevated,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.lightBorderStrong),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onSubmitted: onSubmitted,
        keyboardType: keyboardType,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 14.sp,
          color: AppColors.lightTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14.sp,
            color: AppColors.lightTextTertiary,
          ),
          prefixIcon:
              Icon(icon, size: 18.sp, color: AppColors.lightTextTertiary),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }
}
