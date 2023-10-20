import 'package:flutter/material.dart';
import 'package:cab_rider/brand_colors.dart';



class TaxiButton extends StatelessWidget {
  final String title;
  final Color colorofbutton;
  final Function onPressed;

  TaxiButton(this.title ,this.colorofbutton,this.onPressed);


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        primary: colorofbutton,
        onPrimary: Colors.white,
      ),
      onPressed: onPressed(),
      child : Container(
        height: 50,
        width: 270,
        child: Center(

          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
          ),
        ),
      ),
    );
  }
}