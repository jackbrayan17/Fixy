# Rapport de Projet : Fixy - Boutique E-Commerce Premium

## 1. Description de l'Application

### Énoncé du Problème
Dans le paysage actuel du commerce de détail, les boutiques spécialisées ont souvent du mal à offrir une expérience mobile simple et élégante qui ne surcharge pas l'utilisateur avec des options inutiles. Le projet initial, "Steve Store", était un magasin généraliste manquant d'identité visuelle forte et de segmentation. Le problème était de transformer cette base en une application de niche, **Fixy**, dédiée exclusivement à la mode féminine premium, avec un processus de commande fluide via WhatsApp, très populaire en Afrique.

### Utilisateurs Cibles
- **Clientes (Customer)** : Femmes modernes recherchant des vêtements de haute qualité (robes, blazers, combinaisons), privilégiant une interface épurée et une communication directe avec le vendeur.
- **Administrateurs (Admin)** : Gestionnaires de la boutique ayant besoin d'un outil mobile pour gérer le catalogue de produits, suivre les commandes et valider les transactions.

### Fonctionnalités Principales
- **Catalogue Thématique** : Affichage filtré par catégories (Robes, Hauts, Blazers, etc.) avec imagerie de haute qualité.
- **Authentification Sécurisée** : Inscription et connexion avec gestion de session persistante.
- **Panier Intelligent** : Ajout/Suppression rapide (système de toggle) avec calcul du total en temps réel.
- **Commande WhatsApp** : Génération automatique de messages formatés pour commander un article ou l'ensemble du panier.
- **Tableau de Bord Admin** : Création, modification et suppression de produits ; gestion du statut des commandes (Pending, Validated).
- **Notifications Locales** : Confirmation visuelle des actions marketing et administratives.

---

## 2. Processus de Conception

### Architecture du Système
L'application suit une architecture **MVVM (Model-View-ViewModel)** simplifiée grâce au package **Provider**.

- **Models** : Objets de données (`Product`, `User`, `CartItem`, `Order`) mappés depuis SQLite.
- **Views (Screens)** : Widgets Flutter gérant l'UI (Ex: `HomeScreen`, `ManageProductsScreen`).
- **ViewModel (AppProvider)** : Le cerveau de l'application. Il contient l'état global et fait l'interface entre la base de données et l'interface utilisateur.

### Organigramme de Navigation
1. **Démarrage** : Vérification de la session (Auto-login).
2. **Auth** : Login/Signup si non connecté.
3. **Flux Client** : Home -> Détails Produit -> Panier -> WhatsApp checkout.
4. **Flux Admin** : Dashboard -> Gestion Produits / Gestion Commandes.

### Choix Visuels (Branding)
Le processus de rebranding vers **Fixy** a imposé une palette **Midnight Blue (#0A192F)** et **Grey**. L'accent est mis sur la typographie et le vide (whitespace) pour évoquer le luxe et la clarté.

---

## 3. Points Saillants de la Mise en Œuvre

### Choix Techniques et Justifications
- **Flutter** : Choisi pour sa capacité à créer une UI premium de manière agile sur Android et iOS avec un seul codebase.
- **SQLite (sqflite)** : Préféré pour le stockage local car il permet une gestion structurée des données sans dépendre obligatoirement d'une connexion internet constante pour la consultation du catalogue.
- **Provider** : Utilisé pour la gestion d'état car il est léger et parfaitement adapté à une application de cette taille, facilitant la mise à jour en temps réel du panier et du thème.

### Satisfaction des Exigences
- **Rebranding Précis** : Chaque écran a été audité pour remplacer les anciennes couleurs et logos par la nouvelle identité Fixy.
- **Catalog Cleanup** : Implémentation d'une logique de "Seeding" au démarrage qui purge les données obsolètes et injecte uniquement la collection féminine premium.
- **WhatsApp Integration** : Utilisation de `url_launcher` avec encodage URI pour garantir que les détails de la commande (titre, prix, total) parviennent correctement à l'administrateur.

---

## 4. Tests et Débogage

### Processus de Test Manuel
- **Tests de Parcours** : Simulation d'un parcours utilisateur complet, de l'inscription à la commande finale sur WhatsApp.
- **Vérification de la Persistance** : Fermeture forcée de l'application pour vérifier que le panier et la session utilisateur sont conservés.
- **Tests de Rôles** : Validation que les fonctionnalités Admin ne sont pas accessibles aux comptes clients standards.

### Débogage et Résolution
- **Analyse Statique** : Utilisation intensive de `dart analyze` pour identifier les fuites de contextes (`BuildContext` async) et les types dépréciés.
- **Hot Reload/Restart** : Exploité pour ajuster les micro-animations des notifications et l'alignement des catégories.
- **Correction Syntaxique** : Résolution de bugs critiques de nesting (parenthèses mal fermées) apparus lors du rebranding rapide.

---

## 5. Réflexion

### Défis Rencontrés
- **Corruption de Fichiers** : Lors de l'édition massive des dépendances, le fichier `pubspec.yaml` a subi une corruption de clé, provoquant des crashs au build. Cela a été résolu par une réécriture manuelle et une sanitisation complète.
- **Compatibilité des Thèmes** : Le passage à une version récente de Flutter a révélé des incompatibilités entre `CardTheme` et `CardThemeData`, nécessitant une migration du code de base.

### Leçons Apprises
- **Importance du Nettoyage** : Laisser du vieux code ou des vieilles données de test ("Steve Store") nuit à l'image de marque. Un nettoyage radical (purge de DB) est souvent plus efficace qu'une simple modification.
- **State Management** : La simplicité de Provider a permis d'implémenter la logique de "Toggle" du panier en quelques lignes, prouvant que l'architecture influence directement la vitesse de développement.

### Travaux Futurs
- **Backend Cloud** : Migration vers Firebase pour permettre une synchronisation multi-appareils et des paiements intégrés.
- **Recherche Avancée** : Ajout d'une barre de recherche avec auto-complétion et filtres de prix.
- **Analyse de Données** : Intégration d'un tableau de bord de statistiques de vente pour l'administrateur.

---
*Fin du rapport - Fixy 2026*
