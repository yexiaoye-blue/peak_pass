import 'package:peak_pass/data/models/icon_model.dart';

class GroupUIModel {
  const GroupUIModel({required this.name, required this.iconModel});

  final String name;
  final IconModel iconModel;

  @override
  String toString() => 'GroupUIModel(name: $name, iconModel: $iconModel)';
}
