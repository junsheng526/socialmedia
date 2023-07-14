import 'package:flutter/material.dart';

class CommentButton extends StatelessWidget {
  final void Function()? onTap;
  const CommentButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 18,
        child: Image.asset(
          'lib/icons/beacon.png',
          // color: Colors.grey,
        ),
      ),
    );
  }
}
