import 'dart:convert';
import 'dart:io';
import 'package:app/core/constants/api_config.dart';
import 'package:app/core/utils/logger.dart';
import 'package:app/features/purchase/data/models.dart';
import 'package:app/features/purchase/data/shop_exceptions.dart';
import 'package:http/http.dart' as http;

class ShopRepository {
  final http.Client _client;

  ShopRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Succulents>> fetchSucculents() async {
    try {
      log.d('Fetching succulents');
      final response = await _client.get(
        Uri.parse('${ApiConfig.shop_url}/succulents/'),
      );
      log.d('Succulents response: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw ServerException(response.statusCode, response.body);
      }

      final List data = json.decode(response.body);
      return data.map((j) => Succulents(
        name: j['name'],
        imagePath: j['image_path'],
        price: j['price'].toString(),
        description: j['description'],
      )).toList();
    } on SocketException {
      throw const NetworkException();
    } on FormatException catch (e) {
      throw ParseException(e.message);
    } on ShopException {
      rethrow;
    } catch (e) {
      log.e('Unknown error fetching succulents', error: e);
      throw UnknownShopException(e.toString());
    }
  }

  Future<List<Pots>> fetchPots() async {
    try {
      log.d('Fetching pots');
      final response = await _client.get(
        Uri.parse('${ApiConfig.shop_url}/pots/'),
      );
      log.d('Pots response: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw ServerException(response.statusCode, response.body);
      }

      final List data = json.decode(response.body);
      return data.map((j) => Pots(
        name: j['name'],
        imagePath: j['image_path'],
        material: j['material'],
        height: j['height'],
        width: j['width'],
        price: j['price'].toString(),
        description: j['description'],
      )).toList();
    } on SocketException {
      throw const NetworkException();
    } on FormatException catch (e) {
      throw ParseException(e.message);
    } on ShopException {
      rethrow;
    } catch (e) {
      log.e('Unknown error fetching pots', error: e);
      throw UnknownShopException(e.toString());
    }
  }

  void dispose() => _client.close();
}