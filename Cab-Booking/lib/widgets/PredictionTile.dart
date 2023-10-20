


import 'dart:io';

import 'package:cab_rider/brand_colors.dart';
import 'package:cab_rider/datamodels/address.dart';
import 'package:cab_rider/datamodels/prediction.dart';
import 'package:cab_rider/dataprovider/appdata.dart';
import 'package:cab_rider/widgets/progressdialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PredictionTile extends StatelessWidget {

   final Prediction? prediction;
    PredictionTile({this.prediction});
  void getPlaceDetails(Prediction? p, context) async{
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context)=> ProgressDialog('Please wait...'),
    );
      await Future.delayed(Duration(seconds: 2));
    Address thisaddress = Address();
    thisaddress.placeId = p?.placeId;
    thisaddress.placename = p?.mainText;
    thisaddress.latitude = double.parse(p!.lat!);
    thisaddress.longitude = double.parse(p!.lon!);
    Provider.of<AppData>(context,listen: false).updateDestinationAddress(thisaddress);

    print(thisaddress.placename);
    Navigator.pop(context);
    Navigator.pop(context,'getDirection');

  }
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (){
        getPlaceDetails(this.prediction, context);
      },
      child: Container(
        child: Row(

          children: <Widget>[
            SizedBox(width: 8,),
            Icon(Icons.location_on, color: BrandColors.colorDimText,),
            SizedBox(width: 4,),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Text( prediction?.mainText ?? 'Main address',overflow: TextOverflow.ellipsis,maxLines:1,style: TextStyle(fontSize: 16),),
                  SizedBox(height: 2,),
                  Text(prediction?.secondaryText ?? 'secondary address',  overflow: TextOverflow.ellipsis,maxLines:1,style: TextStyle(fontSize: 12,color: BrandColors.colorDimText),)
                ],
              ),
            )
          ],
        ),
      ),
    );

  }
}