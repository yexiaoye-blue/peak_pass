import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';

class CategoryFilterProvider extends ChangeNotifier {
  bool _isCategoryGird = false;
  bool get isCategoryGird => _isCategoryGird;
  set isCategoryGird(bool value) {
    _isCategoryGird = value;
    notifyListeners();
  }

  List<KdbxGroup> _selectedGroups = [];
  List<KdbxGroup> get selectedGroups => _selectedGroups;
  set selectedGroups(List<KdbxGroup> groups) {
    _selectedGroups = groups;
    notifyListeners();
  }
}
