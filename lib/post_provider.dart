import 'dart:convert';
import 'dart:developer';

import 'package:demo_api/post_model.dart';
import 'package:demo_api/store_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  String _error = '';
  int _currentPage = 1;
  bool _hasMore = true;

  List<Post> get posts => _posts;

  bool get isLoading => _isLoading;

  String get error => _error;

  bool get hasMore => _hasMore;

  Future<void> fetchPosts() async {
    _currentPage = 1;
    log("_currentPage = $_currentPage");
    _isLoading = true;
    notifyListeners();

    StoreData storeData = StoreData();
    try {
      final response = await http.get(Uri.parse(
          'https://jsonplaceholder.typicode.com/posts?_page=$_currentPage'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _posts = data.map((json) => Post.fromJson(json)).toList();
        _hasMore = true;
        storeData.storeApiData(response.body);
      } else {
        _error = 'Failed to load posts';
      }
    } catch (e) {
      // _error = 'Network error: $e';
    } finally {
      var apiData = await storeData.getApiData();
      if (apiData != "") {
        List<dynamic> data = json.decode(apiData!);
        _posts = data.map((json) => Post.fromJson(json)).toList();
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMorePosts() async {
    log("_currentPage = $_currentPage");

    if (_isLoading || !_hasMore) {
      return;
    }

    _currentPage++;
    _isLoading = true;

    notifyListeners();

    try {
      final response = await http.get(Uri.parse(
          'https://jsonplaceholder.typicode.com/posts?page=$_currentPage'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _posts.addAll(data.map((json) => Post.fromJson(json)).toList());
        _hasMore = data.isNotEmpty;
      } else {
        _error = 'Failed to load more posts';
      }
    } catch (e) {
      // _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
