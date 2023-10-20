import 'package:cab_rider/datamodels/address.dart';
import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier{

Address? pickupAddress;

Address? destinationAddress;

void updatePickUpAddress(Address pickup){
  print('update pickup address');
  pickupAddress = pickup;
  notifyListeners();
}

void updateDestinationAddress(Address destination){
  print('update destination address');
  destinationAddress = destination;
  notifyListeners();
}
}