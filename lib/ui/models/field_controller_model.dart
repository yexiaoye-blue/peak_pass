import 'package:flutter/material.dart';

class FieldControllerModel {
  final TextEditingController controller;
  final FocusNode? focusNode;

  FieldControllerModel({required this.controller, this.focusNode});
}
