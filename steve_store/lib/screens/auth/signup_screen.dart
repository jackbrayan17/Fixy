import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../utils/colors.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _profileImagePath;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _categories = ['Electroniques', 'Chaussures', 'Vetements', 'Parfums'];
  final List<String> _selectedCategories = [];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez choisir au moins une catégorie')),
        );
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
        );
        return;
      }

      final user = User(
        fullName: _fullNameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        profilePhoto: _profileImagePath ?? '',
        categories: _selectedCategories,
      );

      final success = await context.read<AppProvider>().signUp(user);
      if (success) {
        // Navigation handled by Provider in main.dart
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'inscription')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.store,
                    size: 80,
                    color: AppColors.emeraldGreen,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Steve Store',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Créez votre compte professionnel',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textDim),
              ),
              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.midnightBlue,
                    backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                    child: _profileImagePath == null
                        ? const Icon(Icons.add_a_photo, color: AppColors.emeraldGreen, size: 30)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(_fullNameController, 'Nom Complet', Icons.person),
              const SizedBox(height: 15),
              _buildTextField(_usernameController, 'Nom d\'utilisateur', Icons.alternate_email),
              const SizedBox(height: 15),
              _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildPasswordField(_passwordController, 'Mot de passe', _obscurePassword, () {
                setState(() => _obscurePassword = !_obscurePassword);
              }),
              const SizedBox(height: 15),
              _buildPasswordField(_confirmPasswordController, 'Confirmer le mot de passe', _obscureConfirmPassword, () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              }),
              const SizedBox(height: 30),
              const Text(
                'Catégories préférées',
                style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategories.contains(cat);
                  return GestureDetector(
                    onTap: () => _toggleCategory(cat),
                    child: Chip(
                      label: Text(cat),
                      backgroundColor: isSelected ? AppColors.emeraldGreen : AppColors.midnightBlue,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.midnightBlue : AppColors.textDim,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(color: isSelected ? AppColors.emeraldGreen : AppColors.textDim.withOpacity(0.3)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldGreen,
                  foregroundColor: AppColors.midnightBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('S\'inscrire'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Déjà un compte ? "),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(
                        color: AppColors.emeraldDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.emeraldGreen),
        labelStyle: const TextStyle(color: AppColors.textDim),
        filled: true,
        fillColor: AppColors.emeraldLight.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Veuillez remplir ce champ' : null,
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, bool obscure, VoidCallback onToggle) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: AppColors.emeraldGreen),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: AppColors.emeraldGreen),
          onPressed: onToggle,
        ),
        labelStyle: const TextStyle(color: AppColors.textDim),
        filled: true,
        fillColor: AppColors.emeraldLight.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Veuillez remplir ce champ' : null,
    );
  }
}
