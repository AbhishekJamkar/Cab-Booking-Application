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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {

  static const String  id = 'mainpage';
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin{
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  GoogleMapController? mapController;
  double searchBarHeight = 250;
  double rideDetailsHeight = 0;
  double requestingSheetHeight=0;
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
      rideref = FirebaseDatabase.instance.reference().child('rideRequest');
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('rideRequest').get();
      if(snapshot.exists){

      }else{
        requestingSheetHeight =0;
        searchBarHeight = 260;
      }

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

  void showDetailisSheet()async{
    await getDirection();

    setState(() {
      searchBarHeight = 0;
      mapBottomPadding = (Platform.isAndroid) ? 240 : 230;
      rideDetailsHeight = (Platform.isAndroid) ? 235 : 260;
      drawerCanOpen = false;
    });
  }
  //
  void showRequestingSheet(){
    setState(() {

      rideDetailsHeight = 0;
      requestingSheetHeight =  195 ;
      mapBottomPadding =  200 ;
      drawerCanOpen = true;

    });

    createRideRequest();
  }

  void createRideRequest() {
    rideref = FirebaseDatabase.instance.reference().child('rideRequest').push();
    var pickup = Provider.of<AppData>(context,listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context,listen: false).destinationAddress;

    Map pickupMap={
      'latitude':pickup!.latitude.toString(),
      'longitude': pickup.longitude.toString(),
    };

    Map destMap={
      'latitude':destination!.latitude.toString(),
      'longitude': destination.longitude.toString(),
    };

    Map rideMap= {
      'created_at' : DateTime.now().toString(),
      'ride_name' : currUserInfo?.fullName,
      'ride_phone' : currUserInfo?.phone,
      'pickup_address': pickup?.placename,
      'destination_address': destination?.placename,
      'location': pickupMap,
      'destination': destMap,
      'payment_method': 'card',
      'driver_id': 'waiting'
    };

    rideref?.set(rideMap);

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HelperMethods.getCurrentUserInfo();
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
                             Text(currUserInfo?.fullName ?? "Ayush", style: TextStyle(fontSize: 20,fontFamily: 'Brand-Bold'),),
                             SizedBox(height: 5,),

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
            bottom: 260,
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
                  resetApp();
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
              curve: Curves.easeIn,

              child: Container(
                height: searchBarHeight,

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                  boxShadow: [BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,0.7,
                    )
                  )]
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal:0,vertical: 18),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 5,),
                      Text('Nice to see you!', style: TextStyle(fontSize: 10),),
                      Text('Where are you going?',style: TextStyle(fontSize: 18,fontFamily: 'Brand-Bold'),),
                      SizedBox(height: 20,),

                      GestureDetector(
                        onTap: () async {
                          var response = await Navigator.push(context,MaterialPageRoute(
                              builder: (context) => SearchPage()
                            ));
                          if(response == 'getDirection'){
                            showDetailisSheet();
                            // await getDirection();
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 320,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [BoxShadow(
                              color: Colors.black12,
                                blurRadius: 5.0,
                              spreadRadius: 0.5,
                              offset: Offset(
                                0.7,0.7,
                              )
                            )]
                          ),
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 3 ,),
                              Icon(Icons.search, color: Colors.blueAccent,) ,
                              SizedBox(width: 10,),
                              Text('Search Destination'),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 22,),
                       Row(
                          children: <Widget>[
                            SizedBox(width: 15 ,),
                            Icon(Icons.home, color: BrandColors.colorDimText,) ,
                            SizedBox(width: 12,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 3,),
                                  Text(
                                    Provider.of<AppData>(context).pickupAddress?.placename ?? 'Add Home',
                                    overflow: TextOverflow.ellipsis,maxLines:1,
                                    style: TextStyle(fontSize: 12),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                       SizedBox(height: 10,),
                      BrandDivider(),
                       SizedBox(height: 16,),
                      Row(
                        children: <Widget>[
                          SizedBox(width: 15 ,),
                          Icon(Icons.work_outline, color: BrandColors.colorDimText,) ,
                          SizedBox(width: 12,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 3,),
                                Text(Provider.of<AppData>(context).destinationAddress?.placename ?? 'Add Work',
                                  overflow: TextOverflow.ellipsis,maxLines:1,
                                  style: TextStyle(fontSize: 11,color: BrandColors.colorDimText),),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],

                  ),
                ),
              ),
            ),
          ),

          //Ridedetails
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
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          primary: BrandColors.colorGreen,
                          onPrimary: Colors.white,
                        ),
                          onPressed: (){
                          showRequestingSheet();
                          },
                        child : Container(
                          height: 50,
                          width: 270,
                          child: Center(

                            child: Text(
                              "REQUEST CAB",
                              style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
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
              curve: Curves.easeIn,
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
                height: requestingSheetHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24,vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    SizedBox(height: 10,),

                    SizedBox(
                      width: double.infinity,
                      child: TextLiquidFill(
                        text: 'Requesting a Ride...',
                        waveColor: BrandColors.colorTextSemiLight,
                        boxBackgroundColor: Colors.white,
                        textStyle: TextStyle(
                            color: BrandColors.colorText,
                            fontSize: 22.0,
                            fontFamily: 'Brand-Bold'
                        ),
                        boxHeight: 40.0,
                      ),
                    ),
                    SizedBox(height: 20,),
                    GestureDetector(
                      onTap: (){
                        cancelRequest();
                        resetApp();
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(width: 1.0, color: BrandColors.colorLightGrayFair),

                        ),
                        child: Icon(Icons.close, size: 25,),
                      ),
                    ),
                    SizedBox(height: 10,),

                    Container(
                      width: double.infinity,
                      child: Text(
                        'Cancel ride',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getDirection() async{
    var pickup =  Provider.of<AppData>(context,listen: false).pickupAddress;
    var destination =  Provider.of<AppData>(context,listen: false).destinationAddress;

    var pickLatLng = LatLng(pickup!.latitude!, pickup!.longitude!);
    var destLatLng = LatLng(destination!.latitude!, destination!.longitude!);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context)=> ProgressDialog('Please wait...'),
    );

    var thisDetails = await HelperMethods.getDirectionDetails(pickLatLng, destLatLng);

    tripDirectionDetails = thisDetails;

    Navigator.pop(context);
    print(thisDetails?.encodedPoints);


    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails!.encodedPoints!);

    polylineCoordinates.clear();
    if(results.isNotEmpty){
      results.forEach((PointLatLng points) {
        polylineCoordinates.add(LatLng(points.latitude, points.longitude));
      });

    }

    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Colors.blue,
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 8,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyline);
    });

    LatLngBounds bounds;
    if(pickLatLng.latitude! > destLatLng.latitude! && pickLatLng.longitude! > destLatLng.longitude!){
      bounds = LatLngBounds(southwest: destLatLng, northeast: pickLatLng);
    }
    else if(pickLatLng.longitude! > destLatLng.longitude!){
      bounds = LatLngBounds(southwest: LatLng(pickLatLng.latitude, destLatLng.longitude),
          northeast: LatLng(destLatLng.latitude,pickLatLng.longitude));
    }
    else if(pickLatLng.latitude > destLatLng.latitude){
        bounds = LatLngBounds(southwest: LatLng(destLatLng.latitude,pickLatLng.longitude), northeast: LatLng(pickLatLng.latitude,destLatLng.longitude));
    }
    else{
      bounds = LatLngBounds(southwest: pickLatLng, northeast: destLatLng);
    }

    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.placeId, snippet: 'My Location' )
    );

    Marker destMarker = Marker(markerId: MarkerId('destination'),
        position: destLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: destination.placeId, snippet: 'Destination' )
    );

    setState(() {
      // _markers.add(pickupMarker);
      _markers.add(destMarker);
    });

    Circle pCircle = Circle(circleId: CircleId('pickup'),
    strokeColor: Colors.white,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: BrandColors.colorGreen
    );

    Circle dCircle = Circle(circleId: CircleId('dest'),
        strokeColor: Colors.white,
        strokeWidth: 3,
        radius: 12,
        center: destLatLng,
        fillColor: Colors.white54
    );

    setState(() {
      _circles.add(pCircle);
      _circles.add(dCircle);
    });
  }

  void cancelRequest(){
    rideref?.remove();
  }


  resetApp(){

    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
      _markers.clear();
      _circles.clear();
       requestingSheetHeight=0;
      rideDetailsHeight=0;
      searchBarHeight=250;
      mapBottomPadding=250;
      drawerCanOpen=true;

      getCurrentLocation();
    });



  }
}
