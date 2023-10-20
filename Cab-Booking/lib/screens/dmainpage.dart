import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cab_rider/brand_colors.dart';
import 'package:cab_rider/datamodels/directionDetails.dart';
import 'package:cab_rider/dataprovider/appdata.dart';
import 'package:cab_rider/globalvariables.dart';
import 'package:cab_rider/helpers/helpermethods.dart';
import 'package:cab_rider/main.dart';
import 'package:cab_rider/screens/loginpage.dart';
import 'package:cab_rider/screens/searchpage.dart';
import 'package:cab_rider/widgets/branddivier.dart';
import 'package:cab_rider/widgets/progressdialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class DMainPage extends StatefulWidget {

  static const String  id = 'dmainpage';
  const DMainPage({super.key});

  @override
  State<DMainPage> createState() => _MainPageState();
}

class _MainPageState extends State<DMainPage> with TickerProviderStateMixin{
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  GoogleMapController? mapController;
  double searchBarHeight = 0;
  double rideDetailsHeight = 0;
  double requestingSheetHeight=0;
  double mylocationHeight =100;
  bool drawerCanOpen = true;
  double mapBottomPadding = 0;

  List<LatLng> polylineCoordinates= [];
  Set<Polyline> _polylines ={};
  Set<Marker> _markers ={};
  Set<Circle> _circles ={};

  var geoLocator = Geolocator();
  Position? currentPosition;

  DirectionDetails? tripDirectionDetails;

  DatabaseReference? rideref;


  void getCurrentLocation() async {
    try {
      getRequest();
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      setState(() {
        currentPosition = position;
      });

      LatLng pos = LatLng(position.latitude, position.longitude);
      CameraPosition cp = CameraPosition(target: pos, zoom: 14);
      mapController?.animateCamera(CameraUpdate.newCameraPosition(cp));

      String address = await HelperMethods.findCordinateAddress(position,context);
      print(address);
    } catch (e) {
      print("Error getting location: $e");
    }
  }


  void cancelRequest(){
    Fluttertoast.showToast(msg: 'Ride request declined.');
    rideDetailsHeight=0;
    rideref?.remove();
  }


  void acceptRequest(){
    Fluttertoast.showToast(msg: 'Accepted.');
    rideDetailsHeight=0;
    rideref?.remove();
  }


  void getRequest()async {
   rideref = FirebaseDatabase.instance.reference().child('rideRequest');
   final ref = FirebaseDatabase.instance.ref();
   final snapshot = await ref.child('rideRequest').get();
   if(snapshot.exists){
     rideDetailsHeight=250;
     mylocationHeight= 260;
     print('*********************************************');
     print(snapshot.value);
     print('*********************************************');
   }
   else{
     rideDetailsHeight=0;
   }
 }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HelperMethods.getCurrentUserInfo();
  }


  resetApp(){

    setState(() {
      rideDetailsHeight=0;
      mylocationHeight=100;
      getCurrentLocation();
    });



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(

        width: 250,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: <Widget>[

              Container(
                height: 160,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset('images/user_icon.png',height: 60,width: 60,),
                      SizedBox(width: 15,),
                      Column(
                        children: <Widget>[
                          Text('Abhishek', style: TextStyle(fontSize: 20,fontFamily: 'Brand-Bold'),),
                          SizedBox(height: 5,),
                          Text('View Profile'),

                        ],
                      )
                    ],
                  ),
                ),
              ),

              BrandDivider(),
              SizedBox(height: 10,),

              ListTile(
                leading: Icon(Icons.card_giftcard),
                title: Text('Free Rides',style: TextStyle(fontSize: 16),),
              ),
              ListTile(
                leading: Icon(Icons.credit_card),
                title: Text('Payments',style: TextStyle(fontSize: 16),),
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('Ride History',style: TextStyle(fontSize: 16),),
              ),
              ListTile(
                leading: Icon(Icons.headset_mic),
                title: Text('Support',style: TextStyle(fontSize: 16),),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('About',style: TextStyle(fontSize: 16),),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.pushReplacementNamed(context, LoginPage.id);
                },
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('LogOut',style: TextStyle(fontSize: 16),),
                ),
              ),
            ],
          ),

        ),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapBottomPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            polylines: _polylines,
            markers: _markers,
            circles: _circles,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194), // Change to your desired initial position
              zoom: 14.0, // Adjust the initial zoom level as needed
            ),

            myLocationButtonEnabled: false,

            onMapCreated: (GoogleMapController controller){
              _controller.complete(controller);
              mapController = controller;
              setState(() {
                mapBottomPadding = 250;
              });
              getCurrentLocation();

            },

          ),
          Positioned(
            bottom: mylocationHeight,
            right: 10.0,

            child: ElevatedButton(
              onPressed: () {
                getCurrentLocation();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                shape: CircleBorder(),
                padding: EdgeInsets.all(10),
              ),
              child: Icon(
                Icons.my_location,
                color: Colors.blue,
              ),
            ),
          ),

          Positioned(
            left: 20,
            top: 44,
            child: GestureDetector(
              onTap: (){
                if(drawerCanOpen) {
                  scaffoldKey.currentState?.openDrawer();
                }
                else{
                  // resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5.0,
                        spreadRadius: 0.5,
                        offset: Offset(
                          0.7,0.7,
                        ),

                      )
                    ]
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon((drawerCanOpen) ? Icons.menu : Icons.arrow_back),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,

            child: AnimatedSize(
              duration: new Duration(milliseconds: 150),
              curve:  Curves.easeIn,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                              0.7,0.7
                          )
                      )
                    ]
                ),
                height: rideDetailsHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: <Widget>[


                      Container(
                        width: double.infinity,
                        color: BrandColors.colorAccent1,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: <Widget>[
                              Image.asset('images/taxi.png',height: 70,width: 70,),
                              SizedBox(width: 16,),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Taxi',style: TextStyle(fontSize: 18,fontFamily: 'Brand-Bold'),),
                                  Text(
                                    (tripDirectionDetails != null) ? tripDirectionDetails!.distanceVal.toString() + ' meters' : '13 Km',
                                    style: TextStyle(fontSize: 16, color: BrandColors.colorDimText),
                                  )

                                ],
                              ),
                              Expanded(child: Container()),
                              Text( (tripDirectionDetails != null) ? '\$' + HelperMethods.estimateFares(tripDirectionDetails!).toString() : '\$13'
                                ,style: TextStyle(fontSize: 18,fontFamily: 'Brand-Bold'),)

                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 22,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: <Widget>[
                                  Icon(FontAwesomeIcons.moneyBillAlt, size: 18, color: BrandColors.colorTextLight,),
                                  SizedBox(width: 16,),
                                  Text('Cash'),
                                  SizedBox(width: 5,),
                                  Icon(Icons.keyboard_arrow_down, color: BrandColors.colorTextLight, size: 16,),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                      SizedBox(height: 22,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust this as needed
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              primary: Colors.red, // You can customize the color for "Decline"
                            ),
                            onPressed: () {
                              cancelRequest();
                              resetApp();
                            },
                            child: Container(
                              height: 50,
                              width: 120, // Adjust the width as needed
                              child: Center(
                                child: Text(
                                  "Decline",
                                  style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold', color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              primary: Colors.green, // You can customize the color for "Accept"
                            ),
                            onPressed: () {
                              acceptRequest();
                              resetApp();
                            },
                            child: Container(
                              height: 50,
                              width: 120, // Adjust the width as needed
                              child: Center(
                                child: Text(
                                  "Accept",
                                  style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold', color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )


                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
}
