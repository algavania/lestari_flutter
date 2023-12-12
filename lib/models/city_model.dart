import 'dart:convert';

CityModel cityModelFromJson(String str) => CityModel.fromJson(json.decode(str));

String cityModelToJson(CityModel data) => json.encode(data.toJson());

class CityModel {
  CityModel({
    required this.results,
  });

  final List<City> results;

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
    results: List<City>.from(json["results"].map((x) => City.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
  };
}

class City {
  City({
    required this.cityId,
    required this.provinceId,
    required this.province,
    required this.type,
    required this.cityName,
    required this.postalCode,
  });

  final String cityId;
  final String provinceId;
  final String province;
  final String type;
  final String cityName;
  final String postalCode;

  factory City.fromJson(Map<String, dynamic> json) => City(
    cityId: json["city_id"],
    provinceId: json["province_id"],
    province: json["province"],
    type: json["type"],
    cityName: json["city_name"],
    postalCode: json["postal_code"],
  );

  Map<String, dynamic> toJson() => {
    "city_id": cityId,
    "province_id": provinceId,
    "province": province,
    "type": type,
    "city_name": cityName,
    "postal_code": postalCode,
  };
}
