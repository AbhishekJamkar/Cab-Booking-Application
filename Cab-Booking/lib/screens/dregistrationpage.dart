import 'package:cab_rider/globalvariables.dart';
import 'package:cab_rider/screens/dmainpage.dart';
import 'package:cab_rider/screens/loginpage.dart';
import 'package:cab_rider/screens/mainpage.dart';
import 'package:cab_rider/screens/vehicleinfo.dart';
import 'package:cab_rider/widgets/progressdialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cab_rider/brand_colors.dart';
import 'package:cab_rider/widgets/TaxiButton.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity/connectivity.dart';
class DRegistrationPage extends StatelessWidget {
  //
  //  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  //  void showSnackBar(String title){
  // final snackbar = SnackBar(content: Text(title,textAlign: TextAlign.center,style: TextStyle(fontSize: 15),));
  // scaffoldKey.currentState.showSnackBar(snackbar);
  //  }
  //

  static const String  id = 'dregister';

  var fullNameController = TextEditingController();
  var phoneController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;


  void registerUser(BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context)=> ProgressDialog('Registering you...'));

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (userCredential.user != null) {

        DatabaseReference userRef = FirebaseDatabase.instance.reference().child("users/${userCredential.user?.uid}");

        String userId = userCredential.user!.uid;

        // Create a map of user data to be stored in the database.
        Map<String, dynamic> userData = {
          "full_name": fullNameController.text,
          "email": emailController.text,
          "phone": phoneController.text,

          // Add any other user data you want to store here.
        };

        // Push the user data to the database.
        await userRef.set(userData);

        currentFirebaseUser = userCredential.user;


        Fluttertoast.showToast(
          msg: 'Registration successful!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,

          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(context, VehicleInfoPage.id, (route) => false);
        // Registration successful, navigate to another page or show a success message.
      } else {
        Fluttertoast.showToast(msg: 'something went wrong');
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'something went wrong');
      print("Error: $e");
      Navigator.pop(context);
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


                //Image
                Image(
                  alignment: Alignment.center,
                  height: 100.0,
                  width: 100.0,
                  image: AssetImage('images/logo.png'),
                ),
                SizedBox(height: 40,),
                Text('Create a Driver\'s Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25,fontFamily: 'Brand-Bold'
                  ),

                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 15,),

                      //Full name
                      TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Full name',
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

                      //Email
                      TextField(
                        controller: emailController,
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


                      //Phone
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: 'Phone',
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
                        controller: passwordController,
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

                    if(fullNameController.text.length == 0 || emailController.text.length == 0
                        || passwordController.text.length==0 || phoneController.text.length == 0){
                      Fluttertoast.showToast(msg: 'All fields are required');
                      return;
                    }

                    if(fullNameController.text.length < 3){
                      Fluttertoast.showToast(msg:'Please enter a valid full name');
                      return;
                    }

                    if(phoneController.text.length < 10){
                      Fluttertoast.showToast(msg: 'Please provide the valid phone number');
                      return;
                    }

                    if(!emailController.text.contains('@')){
                      Fluttertoast.showToast(msg: 'Please provide the valid email address');
                      return;
                    }

                    if(passwordController.text.length < 8){
                      Fluttertoast.showToast(msg: 'password must be at least 8 characters');
                      return;
                    }

                    registerUser(context);
                  },
                  child : Container(
                    height: 50,
                    width: 270,
                    child: Center(

                      child: Text(
                        "REGISTER",
                        style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
                  },
                  child: Text('Already have a Rider Account? Log in'),
                ),
              ],
            ),
          ),
        )
    );
  }
}
