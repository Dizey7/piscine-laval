import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/mtl_theme.dart';

/// Écran de connexion (Google + Apple Sign-In)
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MtlColors.darkBg,
      appBar: AppBar(
        backgroundColor: MtlColors.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MTL',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: MtlColors.orangeMtl,
                    ),
                  ),
                  Text(
                    ' Live',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: MtlColors.blanc,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Connecte-toi pour sauvegarder tes\névénements et recevoir des notifications',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: MtlColors.darkTextSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Google Sign-In
              _AuthButton(
                icon: Icons.g_mobiledata,
                label: 'Continuer avec Google',
                color: MtlColors.blanc,
                textColor: MtlColors.darkBg,
                loading: _loading,
                onPressed: () => _signInWith('google'),
              ),
              const SizedBox(height: 14),

              // Apple Sign-In
              _AuthButton(
                icon: Icons.apple,
                label: 'Continuer avec Apple',
                color: MtlColors.darkCard,
                textColor: MtlColors.blanc,
                loading: _loading,
                onPressed: () => _signInWith('apple'),
              ),
              const SizedBox(height: 32),

              // Skip
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Continuer sans compte',
                  style: TextStyle(
                    color: MtlColors.darkTextSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWith(String provider) async {
    setState(() => _loading = true);
    try {
      final authService = ref.read(authServiceProvider);
      if (provider == 'google') {
        await authService.signInWithGoogle();
      } else {
        await authService.signInWithApple();
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion : $e'),
            backgroundColor: MtlColors.annule,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _AuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final bool loading;
  final VoidCallback onPressed;

  const _AuthButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
