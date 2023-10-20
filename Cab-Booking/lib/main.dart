import 'package:cab_rider/brand_colors.dart';
import 'package:cab_rider/dataprovider/appdata.dart';
import 'package:cab_rider/globalvariables.dart';
import 'package:cab_rider/screens/dloginpage.dart';
import 'package:cab_rider/screens/dmainpage.dart';
import 'package:cab_rider/screens/dregistrationpage.dart';
import 'package:cab_rider/screens/loginpage.dart';
import 'package:cab_rider/screens/registrationpage.dart';
import 'package:cab_rider/screens/vehicleinfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cab_rider/screens/mainpage.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(const MyApp());
}


final FirebaseDatabase _database = FirebaseDatabase.instance;
Future<void> saveDataToRealtimeDatabase() async {
  try {
    // Example data to save
    Map<String, dynamic> data = {
      'name': 'John Doe',
      'email': 'john@example.com',
      // Add more fields as needed
    };

    // Replace 'nodePath' with the path where you want to store the data in your database
    final DatabaseReference _ref = _database.reference().child('nodePath');

    // Push data to the database
    await _ref.push().set(data);

    print('Data saved to Firebase Realtime Database successfully');
  } catch (e) {
    print('Error saving data to Firebase Realtime Database: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: 'Brand-Regular',
          colorScheme: ColorScheme.fromSeed(seedColor: BrandColors.colorAccentPurple),
        ),
        initialRoute: (currentFirebaseUser == null) ? LoginPage.id : MainPage.id,
        routes:{
          RegistrationPage.id : (context) => RegistrationPage(),
          LoginPage.id :(context) => LoginPage(),
          MainPage.id :(context) => MainPage(),
          DMainPage.id : (context) => DMainPage(),
          DLoginPage.id : (context)=> DLoginPage(),
          DRegistrationPage.id : (context) => DRegistrationPage(),
          VehicleInfoPage.id : (context) => VehicleInfoPage(),
        },
      ),
    );
  }
}



