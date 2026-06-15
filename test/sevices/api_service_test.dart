import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:xpower_partners/services/api_service.dart';

void main() {
  test('ApiService getPackages returns package list on success', () async {
    // Create mock client:
    final mockClient = MockClient((request) async {
      final responseMap = {
        'success': true,
        'data': [
          {
            'id': 1,
            'package_name': 'basic',
            'package_amount': 5000.0,
            'description': 'test pkg',
            'modules': [],
          },
        ],
      };
      return http.Response(json.encode(responseMap), 200);
    });

    // 1. Pass mockClient to ApiService:
    final apiService = ApiService(client: mockClient);

    // 2. Execute target function:
    final packages = await apiService.getPackages();

    // 3. Assert correct output:
    expect(packages.length, 1);
    expect(packages.first.packageName, 'basic');
    expect(packages.first.packageAmount, 5000.0);
  });
}
