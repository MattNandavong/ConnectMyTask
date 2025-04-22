import 'dart:convert';

import 'package:app/model/Review.dart';
import 'package:http/http.dart' as http;

Future<List<Review>> getProviderReviews(String providerId) async {
  final response = await http.get(Uri.parse('http://10.0.2.2:3300/api/tasks/provider/$providerId'));

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => Review.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load reviews');
  }
}
