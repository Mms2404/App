import 'package:app/core/constants/colors.dart';
import 'package:app/core/widgets/buttons.dart';
import 'package:app/features/purchase/screens/home.dart';
import 'package:flutter/material.dart';

class Purchase extends StatelessWidget {
  const Purchase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              _IconBadge(),
              const SizedBox(height: 32),
              _BrandTag(),
              const SizedBox(height: 16),
              const _Headline(),
              const SizedBox(height: 14),
              const _Subhead(),
              const Spacer(flex: 3),
              _CtaBlock(),
              const SizedBox(height: 24),
              const _MetaRow(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.success.withOpacity(0.35),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.25),
              blurRadius: 24,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Icon(
          Icons.spa_rounded,
          size: 40,
          color: AppColors.success,
        ),
      ),
    );
  }
}

class _BrandTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'PLANT SHOP',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Find your\nperfect plant.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
        height: 1.1,
        letterSpacing: -1,
      ),
    );
  }
}

class _Subhead extends StatelessWidget {
  const _Subhead();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Easy-care succulents and houseplants, delivered to your door.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.lightTextSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}

class _CtaBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _LightPrimaryButton(
      label: 'Browse plants',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Home()),
        );
      },
    );
  }
}

class _LightPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _LightPrimaryButton({required this.label, required this.onPressed});

  @override
  State<_LightPrimaryButton> createState() => _LightPrimaryButtonState();
}

class _LightPrimaryButtonState extends State<_LightPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 52,
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFF2E7D4F) : AppColors.success,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _MetaChip(icon: Icons.local_shipping_outlined, label: 'Free delivery'),
        const SizedBox(width: 12),
        _Dot(),
        const SizedBox(width: 12),
        _MetaChip(icon: Icons.workspace_premium_outlined, label: '30-day guarantee'),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.lightTextTertiary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.lightTextTertiary,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.lightTextTertiary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}