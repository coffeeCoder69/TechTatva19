import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techtatva19/DataModel.dart';
import 'package:http/http.dart' as http;
import 'package:techtatva19/pages/Schedule.dart';
import 'dart:async';
import 'Schedule.dart';
import 'dart:convert';
import 'package:flare_flutter/flare_actor.dart';
import '../main.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> with TickerProviderStateMixin {
  bool isBottomSheetTapped = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  SharedPreferences _preferences;

  bool isTapped = true;

  _buildFloatingActionButton() {
    return InkWell(
      child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.fastLinearToSlowEaseIn,
          height: isTapped ? 56.0 : 40.0,
          width: isTapped
              ? 56
              : MediaQuery.of(_scaffoldKey.currentContext).size.width * 0.7,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.greenAccent,
              borderRadius: BorderRadius.circular(100.0)),
          child: isTapped
              ? IconButton(
                  icon: Icon(Icons.search, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      isTapped = !isTapped;
                    });
                  },
                )
              : Container(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            isTapped = !isTapped;
                          });
                        },
                      ),
                      Container(
                        width: !isTapped
                            ? MediaQuery.of(context).size.width * 0.5
                            : 10.0,
                        alignment: Alignment.center,
                        child: ClipRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: TextField(
                            // initialValue: "search here ...",

                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "search here...",
                                hintStyle: TextStyle(
                                    color: Colors.black.withOpacity(0.5))),
                            onSubmitted: (str) {
                              setState(() {
                                isTapped = !isTapped;
                              });
                            },
                            //   autofocus: true,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                    ],
                  ),
                )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        floatingActionButton: _buildFloatingActionButton(),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBarDelegate.buildSliverAppBar(
                  "Categories", "assets/Categories.png")
            ];
          },
          body: FutureBuilder(
            future: loadCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Container(
                    height: 300.0,
                    width: 300.0,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator());
              else {
                return Container(
                  padding: EdgeInsets.only(top: 10.0),
                  child: ListView.builder(
                    itemCount: allCategories.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (allCategories[index].type == "TECHNICAL")
                        return _buildCategoryCard(context, index);
                    },
                  ),
                );
              }
            },
          ),
        ));
  }

  _showBottomModalSheet(BuildContext context, int index) {
    TabController _controller = TabController(length: 4, vsync: this);
    showModalBottomSheet(
        backgroundColor: Colors.black,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 600.0,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20.0),
                  alignment: Alignment.center,
                  child: Text(allCategories[index].name,
                      style: TextStyle(fontSize: 26.0)),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 1.0,
                  color: Colors.greenAccent,
                ),
                Container(
                  height: 5.0,
                  width: 200.0,
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      _buildBottomSheetContactTile(allCategories[index].cc1Name ?? "unavailable", allCategories[index].cc1Contact ?? "unavailable"),
                      Container(
                        height: 5.0,
                        width: 1.0,
                      ),
                      _buildBottomSheetContactTile(
                          allCategories[index].cc2Name ?? "unavailable", allCategories[index].cc2Contact ?? "unavailable"),
                      Container(
                        height: 10.0,
                      ),
                      TabBar(
                        controller: _controller,
                        tabs: <Widget>[
                          Tab(
                            text: "Day 1",
                          ),
                          Tab(
                            text: "Day 2",
                          ),
                          Tab(
                            text: "Day 3",
                          ),
                          Tab(
                            text: "Day 4",
                          )
                        ],
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: TabBarView(
                          controller: _controller,
                          children: <Widget>[
                            _buildScheduleCard(allSchedule, context),
                            _buildScheduleCard(allSchedule, context),
                            _buildScheduleCard(allSchedule, context),
                            //_buildCard(allSchedule, context),
                            Column(
                              children: <Widget>[
                                Container(
                                //  color: Colors.red,
                                  height: 270.0,
                                  width: 270.0,
                                //  color: Colors.red,
                                  alignment: Alignment.topCenter,
                                  child: FlareActor(
                                    'assets/NoEvent.flr',
                                    animation: 'noEvents',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    "No Events Today.",
                                    style: TextStyle(color: Colors.white54,fontSize: 18.0),
                                  ),
                                )
                              ],
                            ),
                          //  _buildCard(allSchedule, context),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget _buildScheduleCard(List<ScheduleData> allSchedule, BuildContext context) =>
      Container(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.all(2.0),
          height: MediaQuery.of(context).size.height * 0.74,
          child: ListView.builder(
            itemCount: allSchedule.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: Card(
                  color: Colors.white10,
                  child: InkWell(
                    onTap: () {
                      //  _showBottomModalSheet(context,allSchedule[index]);
                    },
                    child: ListTile(
                      title: Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Text(allSchedule[index].name ?? "ee",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22.0,
                                  )),
                            ),
                            Container(
                              color: Colors.greenAccent,
                              width: 400.0,
                              height: 1.0,
                              margin: EdgeInsets.only(top: 10.0),
                            ),
                            Padding(padding: EdgeInsets.all(5.0)),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Icon(
                                          Icons.schedule,
                                          size: 12.0,
                                          color: Colors.greenAccent,
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(left: 2.0),
                                          child: Text(
                                            "1:00 PM - 5:00 PM",
                                            style: TextStyle(
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Icon(
                                          Icons.location_on,
                                          size: 12.0,
                                          color: Colors.greenAccent,
                                        ),
                                        Container(
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.35),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 3.0),
                                          child: Text(
                                            allSchedule[index].location ?? "hhhh",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(7.0)),
                            Container(
                              padding: EdgeInsets.only(left: 5.0),
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    width: 40.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Icon(
                                          Icons.assessment,
                                          size: 15.0,
                                        ),
                                        Text(
                                          "R2",
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 20.0,
                                      color: Colors.greenAccent,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

  Row _buildBottomSheetContactTile(String name, String contact) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.person,
              size: 25.0,
              color: Colors.white,
            ),
            Container(
              width: 10.0,
            ),
            Text(
              name,
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              contact,
              style: TextStyle(fontSize: 18.0, color: Colors.white54),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, int index) {
    return Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        Card(
          color: Colors.white.withOpacity(0.1),
          margin: EdgeInsets.all(10.0),
          child: InkWell(
            onTap: () {
              _showBottomModalSheet(context, index);
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(60.0, 10, 10, 10),
              width: MediaQuery.of(context).size.width * 0.85,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      allCategories[index].name,
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.w400),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(4.0),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(40.0))),
                        height: 0.7,
                        width: 200.0),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(4.0, 4.0, 5.0, 4.0),
                    child: Text(
                      allCategories[index].description,
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.017,
          top: 25.0,
          child: CircleAvatar(
            radius: 45.0,
            child: Image.asset("assets/QI.png"),
          ),
        )
      ],
    );
  }

  // Future<String> loadCategories() async {
  //   List<CategoryData> temp = await _fetchCategories();

  //   try {
  //     for (var item in temp) {
  //       if (item.type == "TECHNICAL") {
  //         allCategories.add(item);
  //       }
  //     }
  //   } catch (e) {
  //     print("lol ho gaya");
  //     return "success";
  //   }
  //   return "success";
  // }

  // _fetchCategories() async {
  //   List<CategoryData> category = [];

  //   _preferences = await SharedPreferences.getInstance();

  //   var jsonData;

  //   try {
  //     String data = _preferences.getString('Categories') ?? null;

  //     if (data != null) {
  //       jsonData = jsonDecode(jsonDecode(data));
  //       // print("EREEEH");
  //       // print(jsonData);
  //     } else {
  //       final response = await http
  //           .get(Uri.encodeFull("https://api.techtatva.in/categories"));

  //       if (response.statusCode == 200) jsonData = json.decode(response.body);
  //     }

  //     for (var json in jsonData['data']) {
  //       try {
  //         var id = json['id'];
  //         var name = json['name'];
  //         var description = json['description'];
  //         var type = json['type'];
  //         var cc1Name = json['cc1Name'];
  //         var cc1Contact = json['cc1Contact'];
  //         var cc2Name = json['cc2Name'];
  //         var cc2Contact = json['cc2Contact'];

  //         // add more with changes to API

  //         CategoryData temp = CategoryData(
  //             id: id,
  //             name: name,
  //             description: description,
  //             type: type,
  //             cc1Contact: cc1Contact,
  //             cc1Name: cc1Name,
  //             cc2Contact: cc2Contact,
  //             cc2Name: cc2Name);

  //         category.add(temp);
  //       } catch (e) {
  //         // show error messages

  //         print("CANT DO categories");
  //       }
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  //   return category;

  //   // catch (e) {
  //   //   //show error messages

  //   //   print("I CAN't");
  //   // }
  // }
}