class Predicts{
  String? placeId;
  String? mainText;
  String? secondaryText;

  Predicts({
    this.placeId,
    this.mainText,
    this.secondaryText,
  });

  Predicts.fromJson(Map<String, dynamic> json){
    placeId = json['place_id'];
    mainText= json['structured_formatting']['main_text'];
    secondaryText = json['structured_formatting']['secondary_text'];
  }
}