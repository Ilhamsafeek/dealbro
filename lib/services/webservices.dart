import 'dart:convert';
import 'dart:io';

import 'package:seeds/services/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WebServices {
  ApiListener mApiListener;

  WebServices(this.mApiListener);

  Future<dynamic> getPostData() async {
    var response = await http.get("https://www.chadmin.online/seeds/allposts");
    var jsonServerData = json.decode(response.body);

    return jsonServerData;
  }

  Future<dynamic> getAllUsers() async {
    var response = await http.get("https://www.chadmin.online/seeds/allusers");
    var jsonServerData = json.decode(response.body);

    return jsonServerData;
  }

  Future<dynamic> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString("device_id");
    var url = 'https://www.chadmin.online/seeds/getuser';

    var response = await http.post(url, body: {
      'device_id': deviceId,
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    var jsonServerData = json.decode(response.body);

    return jsonServerData;
  }

  Future createAccount(deviceId) async {
    var url = 'https://www.chadmin.online/seeds/createaccount';

    var response = await http.post(url, body: {
      'device_id': deviceId,
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  Future updateAccount(deviceId, phone, username, address) async {
    var url = 'https://www.chadmin.online/seeds/updateaccount';

    var response = await http.post(url, body: {
      'device_id': deviceId,
      'phone': phone,
      'username': username,
      'address': address,
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  Future<dynamic> getUserDataByDeviceID(deviceId) async {
    var url = 'https://www.chadmin.online/seeds/getuserdatabydeviceid';

    var response = await http.post(url, body: {
      'device_id': deviceId,
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return response.statusCode;
  }

  Future createPost(
      deviceId, category, price, unit, description, imageUrl) async {
    String base64Image = base64Encode(File(imageUrl).readAsBytesSync());
    print("base Image: $base64Image");
    String fileName = File(imageUrl).path.split('/').last;
    var url = 'https://www.chadmin.online/seeds/createpost';

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.files.add(http.MultipartFile('image',
        File(imageUrl).readAsBytes().asStream(), File(imageUrl).lengthSync(),
        filename: imageUrl.split("/").last));
    request.fields['device_id'] = deviceId;
    request.fields['category'] = category;
    request.fields['price'] = price;
    request.fields['unit'] = unit;
    request.fields['description'] = description;
    request.fields['filename'] = fileName;
    var response = await request.send();

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.stream.bytesToString()}');
    return response.statusCode;
  }

  Future updateProfilePhoto(deviceId, imageUrl) async {
    String fileName = File(imageUrl).path.split('/').last;
    var url = 'https://www.chadmin.online/seeds/updateprofilephoto';

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.files.add(http.MultipartFile('image',
        File(imageUrl).readAsBytes().asStream(), File(imageUrl).lengthSync(),
        filename: imageUrl.split("/").last));
    request.fields['device_id'] = deviceId;
    request.fields['filename'] = fileName;
    var response = await request.send();

  
   return response;
  }

  Future deletePost(postId) async {
    var url = 'https://www.chadmin.online/seeds/deletepost';

    var response = await http.post(url, body: {
      'post_id': postId,
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}
