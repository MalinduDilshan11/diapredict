import 'package:flutter_test/flutter_test.dart';
import 'package:diapredict/services/api_service.dart';

void main() {

  test('Signup API returns success', () async {

    final email = "test${DateTime.now().millisecondsSinceEpoch}@mail.com";

    final result = await ApiService.signup(
      'Test User',
      email,
      '123456'
    );

    expect(result['success'], true);

  });

}