import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seeds/screens/my_posts.dart';
import 'package:seeds/services/services.dart';
import 'package:seeds/utils/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  final dynamic deviceId;
  Profile(this.deviceId, {Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File _imageFile;
  ApiListener mApiListener;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _mobileNumber = TextEditingController(text: "Mobile");
  var _userName = TextEditingController(text: "User name");
  var _address = TextEditingController(text: "Address");

  dynamic _profilePhoto = AssetImage('assets/placeholder.png');
  Future<void> captureImage(ImageSource imageSource) async {
    try {
      final imageFile = await ImagePicker.pickImage(source: imageSource);
      setState(() {
        _imageFile = imageFile;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WebServices(this.mApiListener).getUserData().then((data) {
      if (data != null) {
        setState(() {
          _mobileNumber = TextEditingController(text: data['phone']);
          _userName = TextEditingController(text: data['username']);
          _address = TextEditingController(text: data['address']);
          _profilePhoto = CachedNetworkImageProvider(
            data['photo_url'],
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('My Profile'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: _buildImage(context))),
                EditableText(
                  textAlign: TextAlign.center,
                  controller: _userName,
                  focusNode: FocusNode(),
                  style: TextStyle(
                      fontFamily: 'SourceSansPro',
                      fontSize: 22,
                      color: Colors.black),
                  cursorColor: Colors.black,
                  backgroundCursorColor: Colors.amber,
                  onSubmitted: (val) async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    var deviceId = prefs.getString("device_id");
                    showWaitingProgress(context, 'Updating..');

                    await WebServices(this.mApiListener).updateAccount(deviceId,
                        _mobileNumber.text, _userName.text, _address.text);
                    Navigator.pop(context);
                  },
                ),
                EditableText(
                  textAlign: TextAlign.center,
                  controller: _address,
                  focusNode: FocusNode(),
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'SourceSansPro',
                    color: Colors.red[400],
                    letterSpacing: 2.5,
                  ),
                  cursorColor: Colors.black,
                  backgroundCursorColor: Colors.amber,
                  onSubmitted: (val) async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    var deviceId = prefs.getString("device_id");
                    showWaitingProgress(context, 'Updating..');

                    await WebServices(this.mApiListener).updateAccount(deviceId,
                        _mobileNumber.text, _userName.text, _address.text);
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  height: 20.0,
                  width: 200,
                  child: Divider(
                    color: Colors.teal[100],
                  ),
                ),
                Card(
                    color: Colors.white,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                    child: ListTile(
                        leading: Icon(
                          Icons.phone,
                          color: Colors.teal[900],
                        ),
                        title: EditableText(
                          controller: _mobileNumber,
                          focusNode: FocusNode(),
                          style: TextStyle(color: Colors.black, fontSize: 18.0),
                          cursorColor: Colors.black,
                          backgroundCursorColor: Colors.amber,
                          onSubmitted: (val) async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            var deviceId = prefs.getString("device_id");
                            showWaitingProgress(context, 'Updating..');

                            await WebServices(this.mApiListener).updateAccount(
                                deviceId,
                                _mobileNumber.text,
                                _userName.text,
                                _address.text);
                            Navigator.pop(context);
                          },
                        )

                        // Text(
                        //   '+91 85465XXX8XX',
                        //   style: TextStyle(fontFamily: 'BalooBhai', fontSize: 20.0),
                        // ),
                        )),
                ListTile(
                  leading: Icon(Icons.camera_rear),
                  title: Text('My Posts'),
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    var deviceId = prefs.getString("device_id");
                    Navigator.of(context).push(CupertinoPageRoute<Null>(
                        builder: (BuildContext context) {
                      return new MyPosts(deviceId);
                    }));
                  },
                ),
                Divider(
                  height: 0,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildImage(context) {
    if (_imageFile != null) {
      Navigator.pop(context);
      _updateImage();
      return GestureDetector(
        child: CircleAvatar(
          radius: 80,
          backgroundImage: FileImage(
            _imageFile,
          ),
        ),
        onTap: () {
          _showOptions();
        },
      );
    } else {
      return GestureDetector(
        child: CircleAvatar(
          radius: 80,
          backgroundImage: _profilePhoto,
        ),
        onTap: () {
          _showOptions();
        },
      );
    }
  }

  Future _showOptions() {
    return showDialog(
        context: context,
        child: new AlertDialog(
          title: Text("Add Photo"),
          content: new Container(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: GestureDetector(
                        child: Icon(
                          Icons.camera_alt,
                          size: 45,
                        ),
                        onTap: () {
                          captureImage(ImageSource.camera);
                        },
                      )),
                      Expanded(
                          child: GestureDetector(
                        child: Icon(
                          Icons.photo,
                          size: 45,
                        ),
                        onTap: () {
                          captureImage(ImageSource.gallery);
                        },
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          insetPadding: EdgeInsets.symmetric(vertical: 250),
        ));
  }

  _updateImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString("device_id");

    showWaitingProgress(context, "Please Wait..");
    await WebServices(this.mApiListener)
        .updateProfilePhoto(deviceId, _imageFile.path)
        .then((value) {
      Navigator.pop(context);
      if (value.statusCode == 200) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text("Updated Successfully"),
        ));
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(value.body),
        ));
      }
    });
  }
}
