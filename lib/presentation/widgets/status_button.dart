import 'package:flutter/material.dart';

class StatusButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function() onPressed;
  final Color? color;

  const StatusButton({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Theme.of(context).primaryColor,
          backgroundColor: isSelected
              ? color ?? Theme.of(context).primaryColor
              : Colors.white,
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1,
            ),
          ),
        ),
        child: Text(title),
      ),
    );
  }
}