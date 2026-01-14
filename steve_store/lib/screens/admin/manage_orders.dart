import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/colors.dart';
import '../../helpers/notification_service.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes Fixy', style: TextStyle(color: AppColors.midnightBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.midnightBlue),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.orders.isEmpty) {
            return const Center(child: Text('Aucune commande', style: TextStyle(color: AppColors.textDim)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.orders.length,
            itemBuilder: (context, index) {
              final order = provider.orders[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: order.status == 'Validated' ? AppColors.emeraldGreen : Colors.orange.withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Client: ${order.userName}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.midnightBlue)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (order.status == 'Validated' ? AppColors.emeraldGreen : Colors.orange).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(color: order.status == 'Validated' ? AppColors.emeraldGreen : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Produit: ${order.productTitle}', style: const TextStyle(color: AppColors.textDim)),
                    Text('Prix: ${order.productPrice?.toStringAsFixed(0)} FCFA x ${order.quantity}', style: const TextStyle(color: AppColors.textDim)),
                    const SizedBox(height: 16),
                    if (order.status != 'Validated')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await provider.updateOrderStatus(order.id!, 'Validated');
                            NotificationService.showNotification(
                              'Commande Validée',
                              'Votre commande pour ${order.productTitle} a été validée !',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commande validée')));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.midnightBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Valider la Commande'),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
