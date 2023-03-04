class RecipieModel {


  //defineing variables

  int? id;
  String? title;
  String? description;
  List<dynamic>? ingredients; // 1 - done | 2 - ongoing | 3 - pending

  RecipieModel(
    this.id,
    this.title, 
    this.description, 
    this.ingredients
    );

  // convert to json
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'ingredients': ingredients,
  };

  // convert from json
  factory RecipieModel.fromJson(Map<String, dynamic> json) => RecipieModel(
    json['id'],
    json['title'],
    json['description'],
    json['ingredients'],
  );


}