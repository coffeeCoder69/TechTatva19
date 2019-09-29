import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techtatva19/main.dart';
import 'dart:convert';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:techtatva19/DataModel.dart';

UserData user;

Dio dio = new Dio();

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isVerifying = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //   _cacheUserDetails();
    dio.options.baseUrl = "https://register.techtatva.in";
    dio.options.connectTimeout = 5000; //5s
    dio.options.receiveTimeout = 3000;
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.teal.withOpacity(0.3), Colors.greenAccent],
  ).createShader(Rect.fromLTRB(0.0, 0.0, 400.0, 70.0));

  @override
  Widget build(BuildContext context) {
    return !isLoggedIn ? _loginPage(context) : _userPage(context);
  }

  _loginPage(context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Container(
              //color: Colors.red,
              margin: EdgeInsets.only(top: height * 0.07),
              height: height * 0.17,
              width: 150.0,
              child: Image.asset("assets/logo_NEW_NEW.png"),
            ),
            Container(
              width: 1.0,
              height: height * 0.12,
              alignment: Alignment.center,
              child: Text(
                "Welcome.",
                style: TextStyle(
                    fontSize: 35.0,
                    foreground: Paint()..shader = linearGradient),
              ),
              //  color: Colors.red,
            ),
            Container(
              child: Center(
                child: Container(
                  padding: EdgeInsets.only(left: 20.0),
                  alignment: Alignment.center,
                  height: height * 0.18,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: "email address",
                            labelStyle: TextStyle(color: Colors.white54),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.white54,
                            )),
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'password',
                            labelStyle: TextStyle(color: Colors.white54),
                            prefixIcon:
                                Icon(Icons.lock, color: Colors.white54)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 20.0,
              height: height * 0.04,
            ),
            Container(
              //color: Colors.red,
              height: height * 0.25,
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black,
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [0.1, 0.3, 0.7, 0.9],
                            colors: [
                              Colors.greenAccent.withOpacity(0.9),
                              Colors.greenAccent.withOpacity(0.7),
                              Colors.teal.withOpacity(0.8),
                              Colors.teal.withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25.0)),
                      height: MediaQuery.of(context).size.height * 0.055,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          _loginRequest("akshit.razor@gmail.com", "xxakshitxx");
                        },
                        splashColor: Colors.greenAccent,
                        child: Container(
                          width: 300.0,
                          alignment: Alignment.center,
                          child: Text(
                            "Login",
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: new Border.all(color: Colors.greenAccent),
                          borderRadius: BorderRadius.circular(25.0)),
                      height: MediaQuery.of(context).size.height * 0.055,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {},
                        splashColor: Colors.greenAccent,
                        child: Container(
                          width: 300.0,
                          alignment: Alignment.center,
                          child: Text(
                            "Register Now",
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    //color: Colors.red,
                    width: height * 0.085,
                    height: height * 0.085,
                    alignment: Alignment.center,
                    child: isVerifying ? CircularProgressIndicator() : null,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _userPage(context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(6.0),
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.only(left: 16.0),
              child: Text(
                user.name,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.0,
                    fontWeight: FontWeight.w100),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              color: Colors.greenAccent,
              height: 0.5,
              margin: EdgeInsets.symmetric(horizontal: 24.0),
              width: MediaQuery.of(context).size.width * 0.9,
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _buildUserTile(context, "Delegate ID", user.id.toString()),
                  _buildUserTile(context, "Registration No.", user.regNo),
                  _buildUserTile(
                      context, "College", user.collegeName),
                  _buildUserTile(context, "Phone", user.mobilNumber),
                  _buildUserTile(context, "Email ID", user.emailId),
                ],
              ),
            ),
            Container(
              color: Colors.greenAccent,
              height: 0.5,
              margin: EdgeInsets.symmetric(horizontal: 24.0),
              width: MediaQuery.of(context).size.width * 0.9,
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 16.0),
                child: FutureBuilder(
                    future: _getQRCode(context),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          height: 170.0,
                          width: 170.0,
                        );
                      }
                      return snapshot.data;
                    })),
            Container(
              margin: EdgeInsets.fromLTRB(90.0,10,90.0,0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.1, 0.3, 0.7, 0.9],
                      colors: [
                        Colors.red.withOpacity(0.8),
                        Colors.red.withOpacity(0.8),
                        Colors.redAccent.withOpacity(1),
                        Colors.redAccent.withOpacity(1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25.0)),
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: MaterialButton(
                  onPressed: () {
                    _logoutRequest();
                  },
                  child: Container(
                    width: 300.0,
                    alignment: Alignment.center,
                    child: Text(
                      "Logout",
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getQRCode(context) async {
    preferences = await SharedPreferences.getInstance();
    String qr = preferences.getString('userQR');
    print(qr);
    String url =
        "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$qr";

    return Container(
      margin: EdgeInsets.only(top: 10.0),
      height: 170.0,
      width: 600,
      alignment: Alignment.center,
      child: Container(
          width: 170.0,
          height: 170.0,
          child: CachedNetworkImage(
              placeholder: (context, url) => CircularProgressIndicator(),
              imageUrl: url)),
    );
  }

  _logoutRequest() async {
    var resp = await dio.get("/logout");
    if (resp.statusCode == 200) {
      print("NO");
      print("LOgged Out");
      isLoggedIn = false;
      preferences = await SharedPreferences.getInstance();
      preferences.setBool('isLoggedIn', false);
      setState(() {});
    }
  }

  _buildUserTile(context, key, value) {
    return Container(
      margin: EdgeInsets.fromLTRB(24, 6, 20, 6),
      height: 30.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(key,
              style: TextStyle(
                color: Colors.white70,
              )),
          Text(value,
              style: TextStyle(
                color: Colors.white,
              )),
        ],
      ),
    );
  }

  _loginRequest(String email, String password) async {
    isVerifying = true;
    setState(() {});
    try {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      String token = "kr4Ju4ImZ7aPJoQLhepb";
      String type = "invisible";

      var cookieJar = PersistCookieJar(
          dir: tempPath, ignoreExpires: false, persistSession: false);

      dio.interceptors.add(CookieManager(cookieJar));

      var response = await dio.post("/login", data: {
        "email": email,
        "password": password,
        'g-recaptcha-response': token,
        'type': type
      });

      print(response.statusCode);
      print(response.data);

      if (response.statusCode == 200 && response.data['success'] == true) {
        print("object");
        preferences = await SharedPreferences.getInstance();
        preferences.setBool('isLoggedIn', true);
        var resp = await dio.get("/userProfile");
        isLoggedIn = true;

        print("******");
        print(resp.data['data']['id']);

        user = UserData(
            id: resp.data['data']['id'],
            name: resp.data['data']['name'],
            regNo: resp.data['data']['regno'],
            mobilNumber: resp.data['data']['mobile'],
            emailId: resp.data['data']['email'],
            qrCode: resp.data['data']['qr'],
            collegeName: resp.data['data']['collname']);
        print("******");
        print(user.name);
        preferences.setString('userId', user.id.toString());
        preferences.setString('userName', user.name);
        preferences.setString('userReg', user.regNo.toString());
        preferences.setString('userMob', user.mobilNumber.toString());
        preferences.setString('userEmail', user.emailId);
        preferences.setString('userQR', user.qrCode);
        preferences.setString('userCollege', user.collegeName);
        isVerifying = false;
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }
}