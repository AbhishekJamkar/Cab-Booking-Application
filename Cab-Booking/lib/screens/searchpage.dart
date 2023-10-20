import 'package:cab_rider/brand_colors.dart';
import 'package:cab_rider/datamodels/prediction.dart';
import 'package:cab_rider/dataprovider/appdata.dart';
import 'package:cab_rider/helpers/requesthelper.dart';
import 'package:cab_rider/widgets/PredictionTile.dart';
import 'package:cab_rider/widgets/branddivier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var pickupController = TextEditingController();
  var destinationController = TextEditingController();
  var focusDestination = FocusNode();
  bool focused = false;
  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  List<Prediction>? destinationPredictionList;
  void searchPlace(String placeName) async {
    if (placeName.length > 1) {
      String url =
          'https://api.locationiq.com/v1/autocomplete?key=pk.1e122888da2d291df2d1a57e060ea351&lat&q=$placeName';

      var response = await RequestHelper.getRequest(url);
      if (response == 'Failed') {
        return;
      }
      var predictions = response;
      var thislist =
          (predictions as List).map((e) => Prediction.fromJson(e)).toList();

      setState(() {
        destinationPredictionList = thislist;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    setFocus();
    String address =
        Provider.of<AppData>(context).pickupAddress?.placename ?? '';
    pickupController.text = address;

    return Scaffold(

      body: SafeArea(

        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, top: 48, right: 24, bottom: 20),
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.arrow_back)),
                          Center(
                            child: Text(
                              'Set Destination',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Brand-Bold',
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      Row(
                        children: <Widget>[
                          Image.asset(
                            'images/pickicon.png',
                            height: 16,
                            width: 16,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: BrandColors.colorLightGrayFair,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                controller: pickupController,
                                decoration: InputDecoration(
                                    hintText: 'Pickup location',
                                    fillColor: BrandColors.colorLightGrayFair,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 10, top: 8, bottom: 8)),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          Image.asset(
                            'images/desticon.png',
                            height: 16,
                            width: 16,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: BrandColors.colorLightGrayFair,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                onChanged: (value) {
                                  searchPlace(value);
                                },
                                focusNode: focusDestination,
                                controller: destinationController,
                                decoration: InputDecoration(
                                    hintText: 'Where to?',
                                    fillColor: BrandColors.colorLightGrayFair,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 10, top: 8, bottom: 8)),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // Column(
              //   children: <Widget>[
              //
              //     PredictionTile()
              //   ],
              // )
              SingleChildScrollView(
                  child: (destinationPredictionList != null)
                      ? ListView.separated(
                          itemBuilder: (context, index) {
                            return PredictionTile(
                              prediction: destinationPredictionList?[index],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              BrandDivider(),
                          itemCount: destinationPredictionList?.length ?? 0,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                        )
                      : Container()),
            ],
          ),
        ),
      ),
    );
  }
}

// class PredictionTile extends StatelessWidget {
//   const PredictionTile({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Row(
//         children: <Widget>[
//           Icon(Icons.location_on, color: BrandColors.colorDimText,),
//           SizedBox(width: 12,),
//
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//
//               Text('afga', style: TextStyle(fontSize: 16),),
//               SizedBox(height: 2,),
//               Text('afd', style: TextStyle(fontSize: 12,color: BrandColors.colorDimText),)
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
