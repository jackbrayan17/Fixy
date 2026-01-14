import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/app_provider.dart';
import '../../utils/colors.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits Fixy', style: TextStyle(color: AppColors.midnightBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.midnightBlue),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.midnightBlue),
            onPressed: () => _showAddEditProductModal(context),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.images.isNotEmpty
                      ? (product.images[0].startsWith('assets/')
                          ? Image.asset(product.images[0], width: 50, height: 50, fit: BoxFit.cover)
                          : Image.file(File(product.images[0]), width: 50, height: 50, fit: BoxFit.cover))
                      : Container(width: 50, height: 50, color: Colors.grey[200]),
                ),
                title: Text(product.title, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                subtitle: Text('${product.price.toStringAsFixed(0)} FCFA - ${product.category}', style: const TextStyle(color: AppColors.textDim)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddEditProductModal(context, product: product)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => provider.deleteProduct(product.id!)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddEditProductModal(BuildContext context, {Product? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormModal(product: product),
    );
  }
}

class ProductFormModal extends StatefulWidget {
  final Product? product;
  const ProductFormModal({super.key, this.product});

  @override
  State<ProductFormModal> createState() => _ProductFormModalState();
}

class _ProductFormModalState extends State<ProductFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  String _category = 'Electroniques';
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title);
    _descController = TextEditingController(text: widget.product?.description);
    _priceController = TextEditingController(text: widget.product?.price.toString());
    if (widget.product != null) {
      _category = widget.product!.category;
      _images = List.from(widget.product!.images);
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _images.addAll(images.map((e) => e.path));
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final p = Product(
        id: widget.product?.id,
        title: _titleController.text,
        description: _descController.text,
        price: double.parse(_priceController.text),
        category: _category,
        images: _images,
      );

      final provider = context.read<AppProvider>();
      if (widget.product == null) {
        await provider.addProduct(p);
      } else {
        await provider.editProduct(p);
      }
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.product == null ? 'Ajouter un Produit' : 'Modifier le Produit', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 20),
              _buildField(_titleController, 'Titre'),
              const SizedBox(height: 15),
              _buildField(_descController, 'Description', maxLines: 3),
              const SizedBox(height: 15),
              _buildField(_priceController, 'Prix (FCFA)', keyboardType: TextInputType.number),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: Colors.white,
                decoration: _inputDecoration('Catégorie'),
                items: ['Robes', 'Hauts', 'Combinaisons', 'Blazers', 'Casual'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: AppColors.midnightBlue)))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 20),
              const Text('Photos', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ..._images.map((path) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(File(path), width: 80, height: 80, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                              onPressed: () => setState(() => _images.remove(path)),
                            ),
                          ),
                        ],
                      )),
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                      child: const Icon(Icons.add_a_photo, color: AppColors.midnightBlue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.midnightBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(widget.product == null ? 'Ajouter' : 'Enregistrer', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.grey),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textDark),
      decoration: _inputDecoration(label),
      validator: (v) => v!.isEmpty ? 'Requis' : null,
    );
  }
}
