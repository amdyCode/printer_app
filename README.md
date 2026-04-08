# Printer App - POS & Bluetooth Thermal Printer App

Une application Flutter complète de point de vente (POS) pour un supermarché, intégrant des fonctionnalités d'impression thermique via Bluetooth.

## Demonstration


https://github.com/user-attachments/assets/be138eeb-ed7e-477a-953e-06c8e8952626



## 📱 Fonctionnalités

- **Interface Moderne et Intuitive** : Design épuré présentant un panier d'articles de supermarché avec quantités, prix en euros (EUR), et un calcul dynamique du total.
- **Gestion Intelligente du Bluetooth** : Vérification stricte des permissions Android (`BLUETOOTH_CONNECT`, `BLUETOOTH_SCAN`). L'application redirige intelligemment l'utilisateur vers les paramètres de l'application ou les paramètres Bluetooth si nécessaire, garantissant une expérience fluide.
- **Génération de Tickets ESC/POS** : Utilisation du standard d'impression ESC/POS pour formater des reçus professionnels (En-tête du magasin, Date/Heure, Détail des articles, Total TTC, Message de fin).
- **Connexion et Impression Fluide** : Recherche des imprimantes Bluetooth appairées, connexion sécurisée et envoi direct des commandes d'impression en bytes.

## 🛠️ Stack Technique

- **Framework** : Flutter / Dart
- **Intégration Matérielle** : `print_bluetooth_thermal` (Connexion SPP Bluetooth)
- **Formatage d'impression** : `esc_pos_utils_plus` (Génération des commandes ESC/POS)
- **Permissions & Routage** : `permission_handler`, `app_settings`
- **Formatage des Données** : `intl` (Devises, Dates)

## 🚀 Installation & Lancement

### Prérequis
- Flutter SDK
- Un appareil Android physique (Requis pour l'utilisation du matériel Bluetooth).
- Une imprimante thermique Bluetooth.

### Configuration Android (`AndroidManifest.xml`)
Pour que la détection et l'impression Bluetooth fonctionnent, les autorisations suivantes doivent être présentes dans le fichier `android/app/src/main/AndroidManifest.xml` (avant la balise `<application>`) :

```xml
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
    <uses-feature android:name="android.hardware.bluetooth" android:required="false" />
```

### Démarrage
1. Clonez ce dépôt.
2. Exécutez `flutter pub get` pour installer les dépendances.
3. Branchez votre appareil Android.
4. Lancez `flutter run`.

> **Note :** Pensez à appairer préalablement votre imprimante thermique avec votre téléphone via les paramètres Bluetooth d'Android avant d'utiliser l'application.
