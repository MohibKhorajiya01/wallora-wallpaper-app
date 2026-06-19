<div align="center">

# 🌌 Wallora

### Premium 4K Wallpaper Experience — Built with Flutter & Firebase

*A sleek, minimalist, dark-themed wallpaper application with a full-fledged Admin Dashboard, Role-Based Access Control, and a buttery-smooth user experience.*

<br/>

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Firebase Auth](https://img.shields.io/badge/Firebase%20Auth-FFA000?style=for-the-badge&logo=firebase&logoColor=white)
![Cloud Firestore](https://img.shields.io/badge/Cloud%20Firestore-039BE5?style=for-the-badge&logo=firebase&logoColor=white)
![Firebase Storage](https://img.shields.io/badge/Firebase%20Storage-FF8F00?style=for-the-badge&logo=firebase&logoColor=white)

![License](https://img.shields.io/badge/License-MIT-success?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue?style=flat-square)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-orange?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)

</div>

---

## 📖 Overview

**Wallora** is a premium, production-grade 4K wallpaper application built entirely in **Flutter**, powered by **Firebase**. It combines a beautiful, minimalist **dark UI** with enterprise-level engineering — including smart auth routing, role-based access control, and a complete admin panel — to deliver an experience that feels as polished as it is functional.

This project was built to demonstrate real-world mobile app architecture: clean separation of concerns, modular reusable widgets, named routing, and robust error handling throughout.

---

## ✨ Key Features

### 🔐 Smart Authentication System
- Secure **Login & Signup** powered by Firebase Authentication
- **Mandatory Email Link Verification** for all new users
- **Role-Based Access Control (RBAC)** — distinct `Admin` and `Normal User` roles resolved via Firestore
- **Persistent Session Routing** — the Splash Screen automatically detects auth state & role, routing users to the Admin Dashboard, User Home, or Verification Screen with zero manual navigation

### 📱 User Application
- **Home & Explore** — browse a curated feed of high-quality aesthetic wallpapers
- **Smart Search** — find wallpapers instantly by category or name
- **Wallpaper Actions** — download to device, set directly as Home/Lock screen, or save to Wishlist
- **Personalization** — dedicated **Saved (Wishlist)** and **Downloads** sections
- **Profile Management** — edit username, access Help & Support, and secure logout
- **Guest Mode** — browse freely as a guest, with a graceful login prompt for restricted actions

### 🛠️ Admin Panel (Secure Dashboard)
- **Restricted Access** — gated exclusively to users with `isAdmin: true` in Firestore, with no back-button escape loopholes
- **Live Overview Dashboard** — real-time stats for total wallpapers & active users
- **Wallpaper Management** — upload to Firebase Storage, edit names/categories, or delete artworks
- **User Management** — view all registered users, with a **secure 2-Step Verification flow** for permanent account deletion
- **Self-Protection** — admin accounts are automatically hidden from the management list to prevent accidental self-deletion

---

## 🏗️ Architecture & Design Principles

Wallora is built on **Clean Architecture** principles for long-term scalability and maintainability:

- 🧩 **Modular, reusable widgets** shared across features
- 🧭 **Explicit named routing** for predictable, centralized navigation
- 🛡️ **Robust error handling** via centralized utility classes
- 🌑 **Minimalist Dark Theme UI** for a premium, distraction-free feel

---

## 📂 Project Structure

```
lib/
├── Splash/                 # Smart auth-routing splash screen
├── admin/                  # Admin module (Pages, Services, Widgets)
├── auth/                   # Authentication logic (Login, Signup, Verify)
├── home/                   # Main app views (Home, Search, Downloads, Saved)
├── profile/                # User profile management
├── utils/                  # Utility classes (e.g., SnackbarUtils for errors)
├── wallpaper/              # Wallpaper details and system-setting logic
├── widgets/                # Global reusable components (e.g., CustomTextField)
└── main.dart                # Entry point, Theme configuration, and Named Routes
```

---

## 🖼️ UI Showcase

### 👤 User Application

<table>
  <tr>
    <td align="center"><b>Home</b></td>
    <td align="center"><b>Search</b></td>
    <td align="center"><b>Wallpaper Details</b></td>
  </tr>
  <tr>
    <td><img src="Wallora Screenshots/homepage.png" width="260"/></td>
    <td><img src="Wallora Screenshots/Serch.png" width="260"/></td>
    <td><img src="Wallora Screenshots/SetWallpaper.png" width="260"/></td>
  </tr>
  <tr>
    <td align="center"><b>Wishlist</b></td>
    <td align="center"><b>User Profile</b></td>
    <td></td>
  </tr>
  <tr>
    <td><img src="Wallora Screenshots/whishllist.png" width="260"/></td>
    <td><img src="Wallora Screenshots/UserProfile.png" width="260"/></td>
    <td></td>
  </tr>
</table>

### 🔐 Authentication Flow

<table>
  <tr>
    <td align="center"><b>Login</b></td>
    <td align="center"><b>Sign Up</b></td>
    <td align="center"><b>Email Verification</b></td>
  </tr>
  <tr>
    <td><img src="Wallora Screenshots/Login.png" width="260"/></td>
    <td><img src="Wallora Screenshots/Signup.png" width="260"/></td>
    <td><img src="Wallora Screenshots/verification.png" width="260"/></td>
  </tr>
</table>

### 🛠️ Admin Panel

<table>
  <tr>
    <td align="center"><b>Dashboard</b></td>
    <td align="center"><b>Upload Wallpaper</b></td>
    <td align="center"><b>User Management</b></td>
  </tr>
  <tr>
    <td><img src="Wallora Screenshots/AdminDeshboard.png" width="260"/></td>
    <td><img src="Wallora Screenshots/AdminUpload.png" width="260"/></td>
    <td><img src="Wallora Screenshots/AdminUasesList.png" width="260"/></td>
  </tr>
  <tr>
    <td align="center"><b>Admin Profile</b></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><img src="Wallora Screenshots/AdminPrifile.png" width="260"/></td>
    <td></td>
    <td></td>
  </tr>
</table>

> 💡 **Note:** Screenshots are loaded from the `Wallora Screenshots/` folder in this repository. Ensure the folder is committed at the repo root for images to render correctly on GitHub.

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel)
- [Dart SDK](https://dart.dev/get-dart) (bundled with Flutter)
- Android Studio / VS Code with Flutter & Dart plugins
- A [Firebase](https://firebase.google.com/) project with **Authentication**, **Cloud Firestore**, and **Storage** enabled

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/wallora.git
   cd wallora
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new project on the [Firebase Console](https://console.firebase.google.com/)
   - Enable **Email/Password Authentication**
   - Set up **Cloud Firestore** and **Firebase Storage**
   - Run the FlutterFire CLI to generate config:
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
   - This will generate `firebase_options.dart` and download platform config files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS)

4. **Set up Firestore user roles**
   - Create a `users` collection in Firestore
   - Add an `isAdmin` boolean field (`true`/`false`) to each user document to control RBAC routing

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 🧰 Tech Stack Summary

| Layer            | Technology                          |
|-------------------|--------------------------------------|
| Framework         | Flutter (Dart)                      |
| Authentication    | Firebase Authentication             |
| Database          | Cloud Firestore                     |
| File Storage      | Firebase Storage                    |
| Architecture      | Clean Architecture                  |
| State & Routing   | Named Routes, Modular Widgets        |
| UI Theme          | Custom Minimalist Dark Theme        |

---

## 🗺️ Roadmap

- [ ] Wallpaper categories & tag-based filtering
- [ ] Push notifications for new wallpaper drops
- [ ] Offline caching for downloaded wallpapers
- [ ] Light theme toggle

---

<div align="center">
### 💜 Built with passion using Flutter & Firebase

**Wallora** — *Where every screen tells a story.*

</div>
