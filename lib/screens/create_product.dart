import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seeds/services/services.dart';
import 'package:seeds/utils/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateProduct extends StatefulWidget {
  CreateProduct({Key key}) : super(key: key);

  @override
  _CreateProductState createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  //final ImagePicker _imagePicker = ImagePickerChannel();

  File _imageFile;
  dynamic _currentSelectedCategory = "Vegitable";
  dynamic _currentSelectedOption = "Kg";
  final _description = TextEditingController(text: "");
  final _price = TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ApiListener mApiListener;

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

  Widget _buildImage(context) {
    if (_imageFile != null) {
      //Navigator.pop(context);
      return GestureDetector(
        child: Image.file(
          _imageFile,
          height: 200,
        ),
        onTap: () {
          _showOptions();
        },
      );
    } else {
      return GestureDetector(
        child: Image.asset(
          'assets/placeholder.png',
          height: 200,
        ),
        onTap: () {
          showDialog(
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
                                Navigator.of(context);

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
                                Navigator.of(context);

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
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var _currencies = [
      "Vegitable",
      "Greens(கீரை)",
      "Fruits(பழங்கள்)",
      "Beet(கிழங்கு)",
      "Unripe fruits(காய் கறி)",
      "Nuts(தானியங்கள்)",
      "Herbs(மூலிகைகள்)",
      "Other"
    ];

    var _options = [
      "Kg",
      "Piece",
    ];

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Create New'),
        ),
        body: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                  child: Text(
                'Picture',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
              Center(child: _buildImage(context)),
              Padding(
                padding: EdgeInsets.all(16),
                child: FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                          errorStyle: TextStyle(
                              color: Colors.redAccent, fontSize: 16.0),
                          hintText: 'Please select expense',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      isEmpty: _currentSelectedCategory == '',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _currentSelectedCategory,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _currentSelectedCategory = newValue;
                              state.didChange(newValue);
                            });
                          },
                          items: _currencies.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Text(
                          'Rs.',
                          style: TextStyle(fontSize: 20),
                        )),
                    Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: _price,
                          style: TextStyle(fontSize: 20),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Enter the price";
                            }
                          },
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 4,
                      child: FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                                errorStyle: TextStyle(
                                    color: Colors.redAccent, fontSize: 16.0),
                                hintText: 'Please select expense',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                            isEmpty: _currentSelectedOption == '',
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _currentSelectedOption,
                                isDense: true,
                                onChanged: (String newValue) {
                                  setState(() {
                                    _currentSelectedOption = newValue;
                                    state.didChange(newValue);
                                  });
                                },
                                items: _options.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.description),
                title: TextFormField(
                  maxLines: null,
                  controller: _description,
                  validator: (value) {
                    // if (value.isEmpty) {
                    //   return "Description cannot be empty";
                    // }
                  },
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Description',
                  ),
                  onChanged: (value) {},
                ),
              ),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: FlatButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        var deviceId = prefs.getString("device_id");
                        if (_imageFile != null) {
                          showWaitingProgress(context, "Please Wait..");
                          await WebServices(this.mApiListener)
                              .createPost(
                                  deviceId,
                                  _currentSelectedCategory,
                                  _price.text,
                                  _currentSelectedOption,
                                  _description.text,
                                  _imageFile.path)
                              .then((value) {
                            Navigator.pop(context);
                            if (value == 200) {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                backgroundColor: Colors.green,
                                content: Text("Posted Successfully"),
                              ));
                            } else {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(
                                    "Something went wrong. Please try again."),
                              ));
                            }
                          });
                        } else {
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text("Please Choose a Picture"),
                          ));
                        }
                      }
                    },
                    child: Text('Submit Post'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        side: BorderSide(color: Colors.amber)),
                    color: Colors.amber,
                  ),
                ),
              )
            ],
          ),
        )));
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

  Widget _buildButtons() {
    return ConstrainedBox(
        constraints: BoxConstraints.expand(height: 70.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(
                key: Key('retake'),
                text: 'Photos',
                onPressed: () => captureImage(ImageSource.gallery),
              ),
              _buildActionButton(
                key: Key('upload'),
                text: 'Camera',
                onPressed: () => captureImage(ImageSource.camera),
              ),
            ]));
  }

  Widget _buildActionButton({Key key, String text, Function onPressed}) {
    return Expanded(
      child: FlatButton(
          key: key,
          child: Text(text, style: TextStyle(fontSize: 20.0)),
          shape: RoundedRectangleBorder(),
          color: Colors.blueAccent,
          textColor: Colors.white,
          onPressed: onPressed),
    );
  }
}
