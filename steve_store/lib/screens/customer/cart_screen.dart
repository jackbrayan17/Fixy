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
        title: const Text('Mon Panier', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.midnightBlue)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.midnightBlue),
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
                                Text(item.productTitle ?? 'Produit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.midnightBlue)),
                                const SizedBox(height: 4),
                                Text('${item.productPrice?.toStringAsFixed(0)} FCFA', style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
                            onPressed: () {
                              provider.removeFromCart(item.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.delete_sweep, color: Colors.white),
                                      const SizedBox(width: 12),
                                      Text('Retiré du panier', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
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
                        const Text('Total', style: TextStyle(fontSize: 18, color: AppColors.grey)),
                        Text('${provider.cartTotal.toStringAsFixed(0)} FCFA', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.midnightBlue)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _commanderToutWhatsapp(provider, context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.midnightBlue,
                          foregroundColor: Colors.white,
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

    final message = "Bonjour *Fixy*, je souhaite commander les produits suivants :\n\n"
        "$productsList\n"
        "*Total:* ${provider.cartTotal.toStringAsFixed(0)} FCFA\n"
        "Nom Client: ${provider.currentUser?.fullName ?? 'Client'}";

    final phone = "237694103585";
    final whatsappUrl = Uri.parse("https://api.whatsapp.com/send/?phone=$phone&text=${Uri.encodeComponent(message)}&type=phone_number&app_absent=0");
    
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
      await provider.placeOrder(); // This will clear cart and save to DB
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Commande validée !', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            backgroundColor: AppColors.midnightBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      if (context.mounted) {
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
