import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert' as convert;
import 'package:thick_app/models/category.dart';
import 'package:thick_app/sharred/consts.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  static Future<List<Category>> getAllCategories() async {
    var url = Uri.https(apiUrl, '/cheikh-ibra-yade/pratic_flutter/categorys');
    List<Category> categories = [];
    var response = await http.get(url);
    print('++++++++++++++++++++++++++ BEG $apiUrl/categorys');
    //print(convert.jsonDecode(response.body) as List<Map<String, dynamic>>);
    print('++++++++++++++++++++++++++ END');
    if (response.statusCode == 200) {

      var responsJson = convert.jsonDecode(response.body);
      print("%%%%%%%%%");
      print((responsJson[0] as Map<String, dynamic>)['name']);
      categories = (responsJson as List<Map<String, dynamic>>)
          .map((categoryJson) => Category.fromJson(categoryJson))
          .toList();
    }
    print("%%%%%%%%%");
    print(categories.runtimeType);
    return categories;
  }
}

const type="application/json";
