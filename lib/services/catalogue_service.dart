import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';

class CatalogueService {
  final Box _usersBox = Hive.box('usersBox');

  // Obtenir tous les produits d'un utilisateur
  List<Product> getProducts(String userEmail) {
    try {
      final catalogueKey = 'catalogue_$userEmail';
      final productsData = _usersBox.get(catalogueKey, defaultValue: []);
      
      final List<dynamic> productsList = List.from(productsData);
      
      return productsList.map((item) {
        final Map<String, dynamic> productMap = Map<String, dynamic>.from(item);
        return Product.fromMap(productMap);
      }).toList();
    } catch (e) {
      print('Erreur getProducts: $e');
      return [];
    }
  }

  // Ajouter un produit
  Future<bool> addProduct(String userEmail, Product product) async {
    try {
      final products = getProducts(userEmail);
      products.add(product);
      
      final catalogueKey = 'catalogue_$userEmail';
      final productsMaps = products.map((p) => p.toMap()).toList();
      await _usersBox.put(catalogueKey, productsMaps);
      
      return true;
    } catch (e) {
      print('Erreur addProduct: $e');
      return false;
    }
  }

  // Modifier un produit
  Future<bool> updateProduct(String userEmail, int index, Product product) async {
    try {
      final products = getProducts(userEmail);
      if (index < 0 || index >= products.length) return false;
      
      products[index] = product;
      
      final catalogueKey = 'catalogue_$userEmail';
      final productsMaps = products.map((p) => p.toMap()).toList();
      await _usersBox.put(catalogueKey, productsMaps);
      
      return true;
    } catch (e) {
      print('Erreur updateProduct: $e');
      return false;
    }
  }

  // Supprimer un produit
  Future<bool> deleteProduct(String userEmail, int index) async {
    try {
      final products = getProducts(userEmail);
      if (index < 0 || index >= products.length) return false;
      
      products.removeAt(index);
      
      final catalogueKey = 'catalogue_$userEmail';
      final productsMaps = products.map((p) => p.toMap()).toList();
      await _usersBox.put(catalogueKey, productsMaps);
      
      return true;
    } catch (e) {
      print('Erreur deleteProduct: $e');
      return false;
    }
  }

  // Obtenir la valeur totale
  double getTotalValue(String userEmail) {
    final products = getProducts(userEmail);
    return products.fold(0.0, (sum, product) => sum + product.prix);
  }

  // Rechercher des produits
  List<Product> searchProducts(String userEmail, String query) {
    final products = getProducts(userEmail);
    if (query.isEmpty) return products;
    
    return products.where((product) {
      return product.titre.toLowerCase().contains(query.toLowerCase()) ||
             product.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Trier les produits
  List<Product> sortProducts(List<Product> products, String sortBy) {
    final sortedProducts = List<Product>.from(products);
    
    switch (sortBy) {
      case 'prix_asc':
        sortedProducts.sort((a, b) => a.prix.compareTo(b.prix));
        break;
      case 'prix_desc':
        sortedProducts.sort((a, b) => b.prix.compareTo(a.prix));
        break;
      case 'titre':
        sortedProducts.sort((a, b) => a.titre.compareTo(b.titre));
        break;
      default:
        break;
    }
    
    return sortedProducts;
  }
}