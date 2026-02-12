import 'package:flutter/material.dart';

class Category {
  final String label;
  final IconData icon;
  final bool isPrimary;

  const Category({
    required this.label,
    required this.icon,
    this.isPrimary = false,
  });
}
