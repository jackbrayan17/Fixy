import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/app_provider.dart';
import '../../utils/colors.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.cartItems.isEmpty) {
            return Center(child: Text('Votre panier est vide', style: TextStyle(color: provider.isDarkMode ? AppColors.textDim : Colors.grey[600])));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = provider.cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: item.productImage != null
                                ? (item.productImage!.startsWith('assets/')
                                    ? Image.asset(item.productImage!, width: 80, height: 80, fit: BoxFit.cover)
                                    : Image.file(File(item.productImage!), width: 80, height: 80, fit: BoxFit.cover))
                                : Container(width: 80, height: 80, color: Colors.grey[900], child: const Icon(Icons.image, color: Colors.white24)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productTitle ?? 'Produit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                                const SizedBox(height: 4),
                                Text('${item.productPrice?.toStringAsFixed(0)} FCFA', style: const TextStyle(color: AppColors.emeraldGreen, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
                            onPressed: () {
                              provider.removeFromCart(item.id!);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Retiré du panier'), duration: Duration(seconds: 1)));
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 18, color: AppColors.textDim)),
                        Text('${provider.cartTotal.toStringAsFixed(0)} FCFA', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.emeraldGreen)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _commanderToutWhatsapp(provider, context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emeraldGreen,
                          foregroundColor: AppColors.midnightBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Commander Tout sur WhatsApp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _commanderToutWhatsapp(AppProvider provider, BuildContext context) async {
    if (provider.cartItems.isEmpty) return;

    String productsList = "";
    for (var item in provider.cartItems) {
      productsList += "- ${item.productTitle} (${item.productPrice?.toStringAsFixed(0)} FCFA)\n";
    }

    final message = "Bonjour Steve Store, je souhaite commander les produits suivants :\n\n"
        "$productsList\n"
        "*Total:* ${provider.cartTotal.toStringAsFixed(0)} FCFA\n"
        "Nom Client: ${provider.currentUser?.fullName}";

    final whatsappUrl = Uri.parse("https://wa.me/22900000000?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
      await provider.placeOrder(); // This will clear cart and save to DB
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')));
    }
  }
}
