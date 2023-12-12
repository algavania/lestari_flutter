import 'dart:convert';

ProvinceModel provinceModelFromJson(String str) => ProvinceModel.fromJson(json.decode(str));

String provinceModelToJson(ProvinceModel data) => json.encode(data.toJson());

class ProvinceModel {
  ProvinceModel({
    required this.results,
  });

  final List<Province> results;

  factory ProvinceModel.fromJson(Map<String, dynamic> json) => ProvinceModel(
    results: List<Province>.from(json["results"].map((x) => Province.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
  };
}

class Province {
  Province({
    required this.provinceId,
    required this.province,
  });

  final String provinceId;
  final String province;

  factory Province.fromJson(Map<String, dynamic> json) => Province(
    provinceId: json["province_id"],
    province: json["province"],
  );

  Map<String, dynamic> toJson() => {
    "province_id": provinceId,
    "province": province,
  };
}
