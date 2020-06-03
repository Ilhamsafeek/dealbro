import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetail extends StatefulWidget {
  final dynamic postData;
  ProductDetail(this.postData, {Key key}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              
              title: Text(
                widget.postData['category'],
                style: TextStyle(
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(0, 0),
                      blurRadius: 3.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              background: CachedNetworkImage(
                imageUrl: widget.postData['image_url'],
                fit: BoxFit.cover,
              ),
            ),

            
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == "report") {
                    // Navigator.of(context).push(CupertinoPageRoute<Null>(
                    //     builder: (BuildContext context) {
                    //   return new EditAppeal(item);
                    // }));
                  } else {
                    // _deleteModalBottomSheet(context, item['id']);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                
                  PopupMenuItem<String>(
                    value: 'report',
                    child: Text("Report this"),
                  ),
                ],
              )
            
            ],
            // pinned: false,
            
          ),
          
          SliverFillRemaining(
              child: Column(
            children: <Widget>[
              ExpansionTile(
                title: Text(
                  widget.postData['username'],
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(widget.postData['address']),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(widget.postData['photo_url']),
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Comments'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      maxLines: null,
                      // controller: _description,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Description cannot be empty";
                        }
                      },
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Write your comment',
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                ],
                initiallyExpanded: false,
              ),
              Card(
                child: ListTile(
                  title: Text("Posted: ${widget.postData['date_time']}"),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Text('Price:'),
                  title: Chip(
                    label: Text(
                        "Rs. ${widget.postData['price']}/${widget.postData['unit']}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.amber,
                  ),
                  trailing: Text("Negotiable"),
                ),
              ),
              Card(
                  child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    color: Colors.grey[200],
                    width: double.infinity,
                    child: Text('Description'),
                  ),
                  ListTile(
                    title: Text("${widget.postData['description']}"),
                  ),
                ],
              ))
            ],
          )),
        ],
      ),
      bottomSheet: BottomSheet(
        onClosing: () {},
        builder: (BuildContext context) {
          return Container(
            child: SizedBox(
                height: 60,
                width: double.infinity,
                // height: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: FlatButton(
                    onPressed: () {
                      _launchURL("tel://${widget.postData['phone']}");
                    },
                    child: Text('Contact seller'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        side: BorderSide(color: Colors.amber)),
                    color: Colors.amber,
                  ),
                )),
          );
        },
      ),
    );
  }

  Widget _buildProduct(index) {
    return new Container(
        color: Colors.green,
        child: new Center(
          child: new CircleAvatar(
            backgroundColor: Colors.white,
            child: new Text('$index'),
          ),
        ));
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
