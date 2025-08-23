import 'package:faker/faker.dart';

class FakerUtils {
  FakerUtils._();
  static final FakerUtils instance = FakerUtils._();

  final Faker _faker = Faker();

  String get name => _faker.person.name();
  String get title => _faker.lorem.word();
}
