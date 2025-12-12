import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class GameDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onConfirm;
  final String confirmText;

  const GameDialog({
    Key? key,
    required this.message,
    this.onConfirm,
    this.confirmText = 'OK',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1515),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.redAccent.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.whiteText,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            if (onConfirm != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm!();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context,
    String message, {
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameDialog(message: message, onConfirm: onConfirm),
    );
  }
}
