import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:seeds/services/services.dart';
import 'package:seeds/utils/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Users extends StatefulWidget {
  Users({Key key}) : super(key: key);

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  ApiListener mApiListener;
  StreamController _messageController;
  Timer timer;
  @override
  void initState() {
    super.initState();
    _messageController = new StreamController();
    timer = Timer.periodic(Duration(seconds: 1), (_) => loadPosts());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  loadPosts() async {
    WebServices(this.mApiListener).getAllUsers().then((res) async {
      print("=======>>>>$res");
      _messageController.add(res);

      return res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Connections'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                StreamBuilder(
                  stream: _messageController.stream,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    List<Widget> children;

                    if (snapshot.hasData) {
                      dynamic data = snapshot.data;
                      children = <Widget>[
                        for (var item in data)
                          Column(
                            children: <Widget>[
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      item['photo_url']),
                                  backgroundColor: Colors.indigoAccent,
                                  foregroundColor: Colors.white,
                                ),
                                title: Text(item['username']),
                                subtitle: Text(item['address']),
                                trailing: Text(item['type']),
                              ),
                              Divider()
                            ],
                          )
                      ];
                    } else if (snapshot.hasError) {
                      children = <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                              'something Went Wrong !'), //Error: ${snapshot.error}
                        )
                      ];
                    } else {
                      children = <Widget>[
                        SizedBox(
                          child: SpinKitPulse(
                            color: Colors.grey,
                            size: 120.0,
                          ),
                          width: 50,
                          height: 50,
                        ),
                      ];
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: children,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }

  Future<bool> deleteModalBottomSheet(context, item) {
    return showModalBottomSheet(
        enableDrag: true,
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              child: new Wrap(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: ListTile(
                        title: Text('Do you really want to delete?'),
                        trailing: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      )),
                  Divider(
                    height: 0,
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: RaisedButton(
                          child: Text('Discard'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )),
                        Expanded(
                            child: RaisedButton(
                          color: Colors.red,
                          child: Text(
                            'Yes',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            showWaitingProgress(context, 'Deleting..');

                            await WebServices(this.mApiListener).deletePost(
                              item['post_id'],
                            );
                            Navigator.pop(context);
                          },
                        ))
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }
}
