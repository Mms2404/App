import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/core/widgets/buttons.dart';
import 'package:app/features/purchase/screens/home.dart';
import 'package:flutter/material.dart';

class Purchase extends StatelessWidget {
  const Purchase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: OrbBackground(
        blurIntensity: 1.8,
        brightness: 0.5,
        child: SafeArea(
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
          color: Color(0xFF5DE6C8).withOpacity(0.10),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Color(0xFF5DE6C8).withOpacity(0.25),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF5DE6C8).withOpacity(0.15),
              blurRadius: 24,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Icon(
          Icons.spa_rounded,
          size: 40,
          color: Color(0xFF5DE6C8),
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
              color: Color(0xFF5DE6C8),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'PLANT SHOP',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6,
              color: Color(0xFF5DE6C8),
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
        color: AppColors.textPrimary,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Easy-care succulents and houseplants, delivered to your door.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}

class _CtaBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Browse plants',
      trailingIcon: Icons.arrow_forward_rounded,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Home()),
        );
      },
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
        Icon(icon, size: 12, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
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
        color: AppColors.textDisabled,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}