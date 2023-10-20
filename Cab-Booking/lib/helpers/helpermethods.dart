

import 'package:cab_rider/datamodels/address.dart';
import 'package:cab_rider/datamodels/directionDetails.dart';
import 'package:cab_rider/datamodels/user.dart';
import 'package:cab_rider/dataprovider/appdata.dart';
import 'package:cab_rider/globalvariables.dart';
import 'package:cab_rider/helpers/requesthelper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class HelperMethods{
  static void getCurrentUserInfo() async {
    User? currentFirebaseUser = FirebaseAuth.instance.currentUser;
    String userid = currentFirebaseUser!.uid;
    print('*********************************************');
    print(userid);
    print('*********************************************');

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('users/$userid').get();
    if(snapshot.exists){
      print('*********************************************');
      print(snapshot.value);
      Userclass currUserInfo = Userclass.fromSnapshot(snapshot);
      print(currUserInfo);

      print('*********************************************');
    }


    // if (snapshot.value != null) {

    // }
  }



static  Future<String> findCordinateAddress(Position position, context) async{
      String placeAddress ='';
      String placeAddress1='';
      var connectivityResult  = await Connectivity().checkConnectivity();
      if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
        return placeAddress;
      }
      String url = 'https://us1.locationiq.com/v1/reverse?key=pk.1e122888da2d291df2d1a57e060ea351&lat=${position.latitude}&lon=${position.longitude}&format=json';
      String url1 = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$tempKey';
       var response = await RequestHelper.getRequest(url);
       var res1 = await RequestHelper.getRequest(url1);
       if(response != 'Failed'){

         placeAddress = response['display_name'];
         placeAddress1 = res1['results'][0]['formatted_address'];
         Address pickupAddress = new Address();

         pickupAddress.longitude = position.longitude;
         pickupAddress.latitude  = position.latitude;
         pickupAddress.placename = placeAddress1;

         Provider.of<AppData>(context,listen: false).updatePickUpAddress(pickupAddress);
       }
      return placeAddress;
}


static Future<DirectionDetails?> getDirectionDetails(LatLng startPosition, LatLng endPosition)async{
    String url = 'https://us1.locationiq.com/v1/directions/driving/${startPosition.latitude},${startPosition.longitude};${endPosition.latitude},${endPosition.longitude}?key=pk.1e122888da2d291df2d1a57e060ea351&overview=full&geometries=polyline';

    String url1 = 'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$tempKey';
    var res1 = await RequestHelper.getRequest(url1);
    var response = await RequestHelper.getRequest(url);

    if(response == 'Failed' || res1 == 'Failed'){
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.distanceVal =   response['routes'][0]['legs'][0]['distance'];
    directionDetails.durationVal = response['routes'][0]['legs'][0]['duration'];
    // directionDetails.encodedPoints = response['routes'][0]['geometry'];
    directionDetails.encodedPoints =  res1['routes'][0]['overview_polyline']['points'];
    return directionDetails;
}

static int estimateFares (DirectionDetails details){
   double basefare = 3;
   double distfare = (details.distanceVal/1000)*0.3;
   double timefare = (details.durationVal/60)*0.2;
   double totalfare = basefare+distfare+timefare;

   return totalfare.truncate();
}
}