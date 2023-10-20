import 'package:cab_rider/datamodels/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

String mapKey = 'AIzaSyCKD7IZAgJ-pHtdL3UhmcEeqhlLspCEdAc';
String tempKey = 'AIzaSyAr1dn7Gm4qQzKjgqocTqTCya1g8CKp7ZY';

User? currentFirebaseUser;
Userclass? currUserInfo;
// https://maps.googleapis.com/maps/api/directions/json?origin=Disneyland&destination=Universal+Studios+Hollywood&key=AIzaSyAr1dn7Gm4qQzKjgqocTqTCya1g8CKp7ZY