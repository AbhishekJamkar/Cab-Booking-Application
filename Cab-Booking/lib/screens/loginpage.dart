import 'package:cab_rider/globalvariables.dart';
import 'package:cab_rider/screens/dloginpage.dart';
import 'package:cab_rider/screens/mainpage.dart';
import 'package:cab_rider/screens/registrationpage.dart';
import 'package:cab_rider/widgets/progressdialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cab_rider/brand_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatelessWidget {
  static const String  id = 'login';
  var emailcontroller = TextEditingController();
  var passwordcontroller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void login(BuildContext context) async{
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (BuildContext context)=> ProgressDialog('Logging you in'));

   try{
     UserCredential userCredential = await _auth.signInWithEmailAndPassword(
       email: emailcontroller.text,
       password: passwordcontroller.text,
     );
     Navigator.pop(context);
     Fluttertoast.showToast(msg: 'Login successful');
     currentFirebaseUser = userCredential.user;
     Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
   } on FirebaseAuthException catch(e){
     Navigator.pop(context);
     Fluttertoast.showToast(msg: 'Invaild email or password');

   }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
     child: SingleChildScrollView(
        child: Column(
          children: <Widget>[

            SizedBox(height: 70,),
            Image(
              alignment: Alignment.center,
              height: 100.0,
              width: 100.0,
              image: AssetImage('images/logo.png'),
            ),
            SizedBox(height: 40,),
            Text('Sign In as a Rider',
            textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,fontFamily: 'Brand-Bold'
              ),

            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[


                  //Email

                  TextField(
                    controller: emailcontroller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: 'Email address',
                        labelStyle: TextStyle(
                          fontSize: 14,

                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        )
                    ),
                    style: TextStyle(
                      fontSize: 14,

                    ),
                  ),
                  SizedBox(height: 10,),

                  //password
                  TextField(
                    controller: passwordcontroller,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          fontSize: 14,

                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        )
                    ),
                    style: TextStyle(
                      fontSize: 14,

                    ),
                  ),

                  SizedBox(height: 40,),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                primary: BrandColors.colorGreen,
                onPrimary: Colors.white,
              ),
              onPressed: () async{
                var connectivityResult  = await Connectivity().checkConnectivity();
                if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                  Fluttertoast.showToast(msg: 'No Internet');
                }

                if(!emailcontroller.text.contains('@')){
                  Fluttertoast.showToast(msg: 'Please enter a vaild email');
                  return;
                }

                if(passwordcontroller.text.length < 8){
                  Fluttertoast.showToast(msg: 'password must be at least 8 characters');
                  return;
                }
                login(context);
                // Add your onPressed callback here
              },
              child : Container(
                height: 50,
              width: 270,
              child: Center(

              child: Text(
                "LOGIN",
                style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
              ),
            ),
            ),
            ),
            TextButton(
                onPressed: (){
                  Navigator.pushNamedAndRemoveUntil(context, RegistrationPage.id, (route) => false);
                },
                child: Text('Don\'t have an account, sign up here')
            ),
            TextButton(
                onPressed: (){
                  Navigator.pushNamedAndRemoveUntil(context, DLoginPage.id, (route) => false);
                },
                child: Text('Login as a Driver'),
            ),
          ],
        ),
      ),
    )
    );
  }
}
