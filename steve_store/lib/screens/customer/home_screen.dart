import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/product_model.dart';
import '../../providers/app_provider.dart';
import '../../utils/colors.dart';
import '../customer/cart_screen.dart';
import '../customer/profile_screen.dart';
import '../admin/admin_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Tout';
  final List<String> _categories = ['Tout', 'Robes', 'Hauts', 'Combinaisons', 'Blazers', 'Casual'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: AppColors.midnightBlue),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.midnightBlue),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          if (provider.currentUser?.username == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.orange),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard())),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                final filteredProducts = _selectedCategory == 'Tout'
                    ? provider.products
                    : provider.products.where((p) => p.category == _selectedCategory).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(child: Text('Aucun produit pour le moment', style: TextStyle(color: AppColors.textDim)));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(filteredProducts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.midnightBlue : AppColors.lightGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.midnightBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: product.images.isNotEmpty
                  ? (product.images[0].startsWith('assets/')
                      ? Image.asset(product.images[0], width: double.infinity, fit: BoxFit.cover)
                      : Image.file(File(product.images[0]), width: double.infinity, fit: BoxFit.cover))
                  : Container(color: Colors.grey[900], child: const Icon(Icons.image, color: Colors.white24)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.midnightBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${product.price.toStringAsFixed(0)} FCFA', style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showProductDetails(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.midnightBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Voir Plus +', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textDim, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Text(product.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.midnightBlue)),
                  const SizedBox(height: 8),
                  Text(product.category, style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  if (product.images.isNotEmpty)
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: product.images.length,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: product.images[i].startsWith('assets/')
                                ? Image.asset(product.images[i], height: 250, width: 250, fit: BoxFit.cover)
                                : Image.file(File(product.images[i]), height: 250, width: 250, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text(product.description, style: const TextStyle(color: AppColors.textDim, fontSize: 16)),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${product.price.toStringAsFixed(0)} FCFA', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.grey)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_shopping_cart, color: AppColors.midnightBlue),
                            tooltip: 'Ajouter au panier',
                            onPressed: () {
                              final provider = context.read<AppProvider>();
                              final isInCart = provider.cartItems.any((item) => item.productId == product.id);
                              provider.addToCart(product);
                              Navigator.pop(context);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(isInCart ? Icons.remove_shopping_cart : Icons.check_circle, color: Colors.white),
                                      const SizedBox(width: 12),
                                      Text(isInCart ? 'Retiré du panier' : 'Ajouté au panier', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  backgroundColor: isInCart ? Colors.redAccent : AppColors.midnightBlue,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _commanderWhatsapp(product),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.midnightBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Commander', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _commanderWhatsapp(Product product) async {
    final message = "Bonjour *Fixy*, je souhaite commander :\n\n"
        "*Titre:* ${product.title}\n"
        "*Prix:* ${product.price.toStringAsFixed(0)} FCFA\n"
        "*Catégorie:* ${product.category}\n"
        "*Description:* ${product.description}";
    
    final phone = "237694103585";
    final whatsappUrl = Uri.parse("https://api.whatsapp.com/send/?phone=$phone&text=${Uri.encodeComponent(message)}&type=phone_number&app_absent=0");
    
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Impossible d\'ouvrir WhatsApp'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
