import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../../models/product.dart';
import '../../services/auth_service.dart';
import '../../services/catalogue_service.dart';
import '../auth/signin_page.dart';
import '../profile/profile_page.dart'; 

class CataloguePage extends StatefulWidget {
  @override
  _CataloguePageState createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  final _authService = AuthService();
  final _catalogueService = CatalogueService();
  
  String _searchQuery = '';
  String _sortBy = 'date';
  
  String? get _userEmail => _authService.getCurrentUser()?.email;

  List<Product> _getProducts() {
    if (_userEmail == null) return [];
    
    List<Product> products = _catalogueService.getProducts(_userEmail!);
    
    // Recherche
    if (_searchQuery.isNotEmpty) {
      products = _catalogueService.searchProducts(_userEmail!, _searchQuery);
    }
    
    // Tri
    products = _catalogueService.sortProducts(products, _sortBy);
    
    return products;
  }

  void _addOrEditProduct({Product? product, int? index}) {
    showDialog(
      context: context,
      builder: (context) => ProductDialog(
        product: product,
        onSave: (newProduct) async {
          if (index != null) {
            await _catalogueService.updateProduct(_userEmail!, index, newProduct);
          } else {
            await _catalogueService.addProduct(_userEmail!, newProduct);
          }
          setState(() {});
        },
      ),
    );
  }

  void _deleteProduct(int index) async {
    await _catalogueService.deleteProduct(_userEmail!, index);
    setState(() {});
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text('Déconnexion', style: TextStyle(color: Color(0xFF424242))),
        content: Text(
          'Voulez-vous vraiment vous déconnecter ?',
          style: TextStyle(color: Color(0xFF757575)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          ElevatedButton(
            onPressed: () async {
              await _authService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) {
      return SignInPage();
    }

    final products = _getProducts();
    final totalValue = _catalogueService.getTotalValue(_userEmail!);

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mon Catalogue',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              '${currentUser.prenom} ${currentUser.nom}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Color(0xFF7986CB),
        elevation: 0,
        leading: currentUser.photoProfil != null
            ? GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  ).then((_) => setState(() {}));
                },
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundImage: MemoryImage(
                      base64Decode(currentUser.photoProfil!),
                    ),
                  ),
                ),
              )
            : IconButton(
                icon: Icon(Icons.account_circle, color: Colors.white, size: 32),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  ).then((_) => setState(() {}));
                },
              ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec statistiques
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF7986CB), Color(0xFF9FA8DA)],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Produits', '${products.length}', Icons.inventory_2),
                    _buildStatCard('Valeur totale', '${totalValue.toStringAsFixed(2)} €', Icons.euro),
                  ],
                ),
                SizedBox(height: 16),
                // Barre de recherche
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit...',
                    hintStyle: TextStyle(color: Colors.white60),
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Boutons de tri
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortChip('Date d\'ajout', 'date'),
                      _buildSortChip('Prix croissant', 'prix_asc'),
                      _buildSortChip('Prix décroissant', 'prix_desc'),
                      _buildSortChip('Alphabétique', 'titre'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des produits
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 100, color: Color(0xFFBDBDBD)),
                        SizedBox(height: 16),
                        Text(
                          'Aucun produit',
                          style: TextStyle(fontSize: 24, color: Color(0xFF757575)),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Appuyez sur + pour ajouter votre premier produit',
                          style: TextStyle(color: Color(0xFF9E9E9E)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final allProducts = _catalogueService.getProducts(_userEmail!);
                      final originalIndex = allProducts.indexWhere((p) =>
                          p.titre == product.titre &&
                          p.description == product.description &&
                          p.prix == product.prix);
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _addOrEditProduct(product: product, index: originalIndex),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: product.image != null
                                      ? Image.memory(
                                          base64Decode(product.image!),
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 90,
                                          height: 90,
                                          color: Color(0xFFE0E0E0),
                                          child: Icon(Icons.image, size: 40, color: Color(0xFF9E9E9E)),
                                        ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.titre,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF424242),
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        product.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Color(0xFF757575), fontSize: 14),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE8EAF6),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${product.prix.toStringAsFixed(2)} €',
                                          style: TextStyle(
                                            color: Color(0xFF5C6BC0),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        backgroundColor: Colors.white,
                                        title: Text('Confirmer', style: TextStyle(color: Color(0xFF424242))),
                                        content: Text(
                                          'Supprimer "${product.titre}" ?',
                                          style: TextStyle(color: Color(0xFF757575)),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('Annuler', style: TextStyle(color: Color(0xFF9E9E9E))),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              _deleteProduct(originalIndex);
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFFFF6B6B),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text('Supprimer'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditProduct(),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Ajouter', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF7986CB),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: Duration(milliseconds: 200),
        child: InkWell(
          onTap: () => setState(() => _sortBy = value),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF7986CB) : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(Icons.check, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// DIALOG POUR AJOUTER/MODIFIER
class ProductDialog extends StatefulWidget {
  final Product? product;
  final Function(Product) onSave;

  ProductDialog({this.product, required this.onSave});

  @override
  _ProductDialogState createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titreController;
  late TextEditingController _descriptionController;
  late TextEditingController _prixController;
  String? _imageBase64;

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.product?.titre ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _prixController = TextEditingController(text: widget.product?.prix.toString() ?? '');
    _imageBase64 = widget.product?.image;
  }

  Future<void> _pickImage() async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();

    input.onChange.listen((e) async {
      final files = input.files;
      if (files!.isEmpty) return;

      final reader = html.FileReader();
      reader.readAsDataUrl(files[0]);
      reader.onLoadEnd.listen((e) {
        setState(() {
          _imageBase64 = reader.result.toString().split(',')[1];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product == null ? 'Nouveau produit' : 'Modifier le produit',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
                SizedBox(height: 24),
                
                // Image preview
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFF7986CB), width: 2),
                      ),
                      child: _imageBase64 != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.memory(
                                base64Decode(_imageBase64!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 60, color: Color(0xFF7986CB)),
                                SizedBox(height: 8),
                                Text('Ajouter une image', style: TextStyle(color: Color(0xFF7986CB))),
                              ],
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                
                TextFormField(
                  controller: _titreController,
                  decoration: InputDecoration(
                    labelText: 'Titre du produit',
                    labelStyle: TextStyle(color: Color(0xFF7986CB)),
                    prefixIcon: Icon(Icons.title, color: Color(0xFF7986CB)),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF7986CB), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Color(0xFF7986CB)),
                    prefixIcon: Icon(Icons.description, color: Color(0xFF7986CB)),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF7986CB), width: 2),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                TextFormField(
                  controller: _prixController,
                  decoration: InputDecoration(
                    labelText: 'Prix (€)',
                    labelStyle: TextStyle(color: Color(0xFF7986CB)),
                    prefixIcon: Icon(Icons.euro, color: Color(0xFF7986CB)),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF7986CB), width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prix';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Prix invalide';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Annuler', style: TextStyle(color: Color(0xFF9E9E9E))),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final product = Product(
                            titre: _titreController.text,
                            description: _descriptionController.text,
                            prix: double.parse(_prixController.text),
                            image: _imageBase64,
                          );
                          widget.onSave(product);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF7986CB),
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Enregistrer', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}