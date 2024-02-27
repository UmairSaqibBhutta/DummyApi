import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class StoreData {
  Future<void> storeApiData(String json) async {
    log("data to store = $json");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("data", json);
  }

  Future<String?> getApiData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getString("data") == null) {
      return "";
    }
    return preferences.getString("data");
  }
}
