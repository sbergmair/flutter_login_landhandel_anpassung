import 'package:quiver/core.dart';

class RecoverDataTwoFields {
  final String mail;
  final String customerNumber;

  RecoverDataTwoFields({required this.mail, required this.customerNumber});

  @override
  String toString() {
    return '$runtimeType($mail, $customerNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (other is RecoverDataTwoFields) {
      return mail == other.mail && customerNumber == other.customerNumber;
    }
    return false;
  }

  @override
  int get hashCode => hash2(mail, customerNumber);
}
