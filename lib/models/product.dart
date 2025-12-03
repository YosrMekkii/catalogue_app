class Product {
  final String titre;
  final String description;
  final double prix;
  final String? image; // Base64 image

  Product({
    required this.titre,
    required this.description,
    required this.prix,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'description': description,
      'prix': prix.toString(),
      'image': image,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      titre: map['titre'] ?? '',
      description: map['description'] ?? '',
      prix: double.tryParse(map['prix']?.toString() ?? '0') ?? 0.0,
      image: map['image'],
    );
  }
}