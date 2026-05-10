abstract class CartItemModel{
  String get imagePath;
  String get name ;
  String get price;
  
}


class Succulents implements CartItemModel {
  
  @override
  final String imagePath;
  @override
  final String name;
  @override
  final String price;
  final String description;

  Succulents({
    required this.imagePath, 
    required this.name, 
    required this.price, 
    required this.description});
}

class Pots implements CartItemModel{

  @override
  final String imagePath;
  @override
  final String name;
  @override
  final String price;
  
  final String material;
  final String height;
  final String width;
  final String description ;

  Pots({
    required this.imagePath,
    required this.name, 
    required this.material, 
    required this.height, 
    required this.width,
    required this.price,
    required this.description 
    });
}




