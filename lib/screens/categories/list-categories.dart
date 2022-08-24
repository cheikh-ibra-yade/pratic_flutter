import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:thick_app/models/category.dart';
import 'package:thick_app/services/category-service.dart';

class CategoryList extends StatelessWidget {
  CategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
        future: CategoryService.getAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Expanded(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            List<Category> _categories = snapshot.data!;
            return ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return Text(_categories[index].name);
                });
          } else if (snapshot.hasError) {
            // if (snapshot.error.runtimeType == DioError) {
            //   DioError _error = snapshot.error as DioError;
            //   ApiError _error = apiErrorFromJson(_error.response.toString());
            // }
            return Text(
                '${snapshot.error.toString()} ${snapshot.data.toString()}');
          }
          return Text('H');
        });
  }
}
