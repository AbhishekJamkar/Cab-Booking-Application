import 'package:firebase_database/firebase_database.dart';

class Userclass{
  String? fullName;
  String? email;
  String? phone;
  String? id;


  Userclass({
    this.email,
    this.fullName,
    this.phone,
    this.id,
  });

  Userclass.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    phone = data['phone'];
    email = data['email'];
    fullName = data['fullname'];
  }

}