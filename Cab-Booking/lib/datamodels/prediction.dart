class Prediction{
  String? placeId;
  String? mainText;  //display_text
  String? secondaryText;  //display_address
  String? lat;
  String? lon;

  Prediction({
    this.placeId,
    this.mainText,
    this.secondaryText,
    this.lat,
    this.lon
});

  Prediction.fromJson(Map<String,dynamic> json){
    placeId=json['place_id'];
    mainText = json['display_place'];
    secondaryText = json['display_address'];
    lat= json['lat'];
    lon = json['lon'];

  }
}