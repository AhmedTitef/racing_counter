import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_counter/counter_screen.dart';
import 'package:race_counter/searchService.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  static const String id = "search_screen";

  @override
  _SearchScreenState createState() => new _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
  }

  var queryResultSet = [];
  var tempSearchStore = [];

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var capitalizedValue =
        value.substring(0, 1).toLowerCase() + value.substring(1);

    if (queryResultSet.length == 0 && value.length == 1) {
      SearchService().searchByName(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          queryResultSet.add(docs.documents[i].data);
          //print(queryResultSet);
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['username'].startsWith(capitalizedValue)) {
          setState(() {
            //tempSearchStore.add(element['data']);
            tempSearchStore.add(element);
            //print(tempSearchStore );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text('Search For Opponent IG'),
        ),
        body: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (val) {
                initiateSearch(val);
              },
              decoration: InputDecoration(
                  prefixIcon: IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.arrow_back),
                    iconSize: 20.0,
                    onPressed: () {},
                  ),
                  contentPadding: EdgeInsets.only(left: 25.0),
                  hintText: 'Search by username',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0))),
            ),
          ),
          SizedBox(height: 10.0),
          GridView.count(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              primary: false,
              shrinkWrap: true,
              children: tempSearchStore.map((element) {
                return buildResultCard(element, context);
              }).toList())
        ]));
  }
}

Widget buildResultCard(data, context) {
  String choosenUID;
  String combinedUID;
  String combinedUIDreversed;

  combineUID(myUID, opponentUID) {
    combinedUID = myUID + opponentUID;
    return combinedUID;
  }

  combineUIDreversed(uidopponent, uid) {
    combinedUIDreversed = uidopponent + uid;
    return combinedUIDreversed;
  }

  return GestureDetector(
    onTap: () async {
      final _auth = FirebaseAuth.instance;

      final FirebaseUser user = await _auth.currentUser();
      choosenUID = data['uid'];
      final userUID = user.uid;
      final snapShotForCombinedUID = await Firestore.instance
          .collection('users')
          .document(combineUID(userUID, choosenUID))
          .get();

      final snapShotForCombinedUIDreversed = await Firestore.instance
          .collection('users')
          .document(combineUIDreversed(choosenUID, userUID))
          .get();
      if (snapShotForCombinedUID.exists &&
          snapShotForCombinedUIDreversed.exists) {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new CounterScreen(
                      combinedUID: combinedUID,
                      combinedUIDreversed: combinedUIDreversed,
                      opponentUID: choosenUID,
                      myUID: userUID,
                    )));
      } else {
        Firestore.instance
            .collection("users")
            .document(combineUID(userUID, choosenUID))
            .setData({
          "myUID": "$userUID",
          "opponentuid": "$choosenUID",
          "status": "offline",
          "opponentStatus": "offline",
          "ready": "Not Ready",
          "opponentReady": "Not Ready"
        });

        Firestore.instance
            .collection("users")
            .document(combineUIDreversed(choosenUID, userUID))
            .setData({
          "myUID": "$userUID",
          "opponentuid": "$choosenUID",
          "status": "offline",
          "opponentStatus": "offline",
          "ready": "Not Ready",
          "opponentReady": "Not Ready"
        });

        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new CounterScreen(
                      combinedUID: combinedUID,
                      combinedUIDreversed: combinedUIDreversed,
                      opponentUID: choosenUID,
                      myUID: userUID,
                    )));
      }
    },
    child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 4.0,
        child: Container(
            child:
            Center(
                child: Text(
              data['username'],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
              ),
            )),


        )),
  );
}
