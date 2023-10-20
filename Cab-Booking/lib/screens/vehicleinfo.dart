import 'package:cab_rider/brand_colors.dart';
import 'package:cab_rider/globalvariables.dart';
import 'package:cab_rider/screens/dmainpage.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class VehicleInfoPage extends StatelessWidget {
  static const String id = 'vehicleinfo';

  var carModelController = TextEditingController();
  var carColorController = TextEditingController();
  var carNumberController = TextEditingController();

  void updateProfile(context){
    String id = currentFirebaseUser!.uid;

    DatabaseReference driverRef = FirebaseDatabase.instance.reference().child("users/$id/vehicledetails");

    Map map = {
      'car_color' : carColorController.text,
      'car_model' : carModelController.text,
      'vehicle_number' : carNumberController.text
    };

    driverRef.set(map);
    Navigator.pushNamedAndRemoveUntil(context, DMainPage.id, (route) => false);


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 100,),
              Image.asset('images/logo.png', height: 110, width: 110,),

              Padding(
                padding:  EdgeInsets.fromLTRB(30,20,30,30),
                child: Column(
                  children: [
                    Text('Enter vehicle details'),

                    //car model
                    TextField(
                      controller: carModelController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Car model',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        )
                      ),
                    ),
                    SizedBox(height: 10,),


                    //car color
                    TextField(
                      controller: carColorController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Car color',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          )
                      ),
                    ),
                    SizedBox(height: 10,),


                    //vehicle number
                    TextField(
                      controller: carNumberController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Vehicle number',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          )
                      ),
                    ),
                    SizedBox(height: 20,),


                    //proceed  button
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

                        if(carModelController.text.length == 0  || carColorController.text.length == 0 || carNumberController.text.length==0 )
                        {
                          Fluttertoast.showToast(msg: 'All fields are required');
                          return;
                        }

                        if(carModelController.text.length < 3){
                          Fluttertoast.showToast(msg:'Please enter a valid model');
                          return;
                        }

                        if(carColorController.text.length < 3){
                          Fluttertoast.showToast(msg: 'Please provide the valid color');
                          return;
                        }


                        if(carNumberController.text.length < 3){
                          Fluttertoast.showToast(msg: 'Number must be at least 4 digits');
                          return;
                        }

                        updateProfile(context);
                      },
                      child : Container(
                        height: 50,
                        width: 270,
                        child: Center(

                          child: Text(
                            "Proceed",
                            style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
