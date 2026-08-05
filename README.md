# 📦 Smart SME Business Management System

A Flutter-based business management system for small and medium enterprises (SMEs), targeting both Android and Web platforms. Built with Firebase, Riverpod, and Material 3.

---

## 👥 Team

| Name | Role |
|---|---|
| Mwewankandu | Lead Developer |
| Moses | Developer |
| Mwape | Developer |

---

## ✅ Features

- 🔐 Authentication — Sign up / Sign in with email and password
- 📦 Inventory Management — Add, edit, delete, restock products with low stock alerts
- 🛒 Sales Recording — Cart-based sales with cash, credit, and mobile money support
- 👥 Customer & Credit Management — Track customers and outstanding balances
- 📋 Credit History — Per-customer itemized credit purchase history
- 📊 Reports & Dashboard — Today's revenue, weekly/monthly summaries
- 🧾 Transactions — Date range filtered transaction history
- 🏆 Best Selling Products — Ranked product performance
- 📅 Daily Sales History — Day-by-day sales breakdown
- ⚙️ Business Profile — Set business name, address, owner info, currency
- 🌙 Dark Mode — Persistent light/dark theme toggle
- 🔍 Search & Filter — Search products and customers, filter by category

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter (Dart) | UI framework — Android & Web |
| Firebase Auth | User authentication |
| Cloud Firestore | Real-time database |
| Riverpod | State management |
| Google Fonts | Typography |
| Shared Preferences | Local storage (settings) |

---

## 🚀 Getting Started (New Team Members)

Follow these steps carefully in order.

### 1. Prerequisites

Make sure you have the following installed on your PC:

| Tool | Download Link |
|---|---|
| Flutter SDK | https://docs.flutter.dev/get-started/install/windows |
| Git | https://git-scm.com/downloads |
| VS Code | https://code.visualstudio.com |
| Android Studio | https://developer.android.com/studio |

#### VS Code Extensions (install these after VS Code):
- **Flutter** (by Dart Code)
- **Dart** (auto-installed with Flutter)

---

### 2. Verify Flutter Installation

Open a terminal and run:

```bash
flutter doctor
```

You need these to be green before continuing:

```
[✓] Flutter
[✓] Android toolchain
[✓] Chrome
[✓] VS Code
```

If Android toolchain shows an error:
1. Open Android Studio → More Actions → SDK Manager
2. Go to SDK Tools tab and check:
   - ✅ Android SDK Command-line Tools (latest)
   - ✅ Android SDK Build-Tools
   - ✅ Android SDK Platform-Tools
3. Click Apply and let it download
4. Then run: `flutter doctor --android-licenses` and press `y` for all prompts

---

### 3. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/sme-system.git
cd sme-system
```

> Ask Barry for the exact repository URL.

---

### 4. Get the Firebase Configuration File

This project uses Firebase. The configuration file (`google-services.json` for Android and `firebase_options.dart`) contains credentials and is **not committed to the repo** for security reasons.

Ask Barry to share:
- `lib/firebase_options.dart`
- `android/app/google-services.json`

Place them in the exact paths shown above.

---

### 5. Install Dependencies

```bash
flutter pub get
```

---

### 6. Run on Chrome (Web)

```bash
flutter run -d chrome
```

---

### 7. Run on Android

First, enable USB Debugging on your phone:
1. Go to **Settings → About Phone**
2. Tap **Build Number** 7 times
3. Go back to **Settings → Developer Options**
4. Enable **USB Debugging**
5. Plug your phone in via USB and tap **Allow** when prompted

Then run:
```bash
flutter devices      # confirm your phone is listed
flutter run          # runs on your connected phone
```

---

### 8. Build an APK (for sharing/installing without USB)

```bash
flutter build apk --release
```

The APK will be at:
```
build\app\outputs\flutter-apk\app-release.apk
```

You can copy this file to any Android phone and install it directly.

> **Note:** If you get an NDK error during build, delete the folder at:
> `C:\Users\YourName\AppData\Local\Android\sdk\ndk\[version]`
> Then run the build command again — it will re-download automatically.

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry point
├── firebase_options.dart            # Firebase config (not in repo)
│
├── core/
│   ├── constants/
│   │   └── app_colors.dart          # App color palette
│   └── theme/
│       └── app_theme.dart           # Light and dark themes
│
├── models/
│   ├── product.dart                 # Product data model
│   ├── customer.dart                # Customer data model
│   └── transaction.dart            # Transaction data model
│
└── features/
    ├── auth/
    │   ├── auth_provider.dart       # Firebase Auth logic
    │   ├── auth_gate.dart           # Auth state router
    │   └── login_screen.dart        # Sign in / Sign up screen
    │
    ├── shell/
    │   └── main_shell.dart          # Bottom navigation shell
    │
    ├── inventory/
    │   ├── inventory_screen.dart    # Product list with search & filter
    │   ├── inventory_provider.dart  # Inventory Riverpod providers
    │   └── widgets/
    │       ├── product_card.dart
    │       ├── product_form_dialog.dart
    │       └── restock_dialog.dart
    │
    ├── sales/
    │   ├── sales_screen.dart        # Cart-based sales screen
    │   ├── sales_provider.dart      # Cart & sales providers
    │   └── widgets/
    │       └── cart_item_tile.dart
    │
    ├── customers/
    │   ├── customers_screen.dart    # Customer list
    │   ├── customer_provider.dart   # Customer providers
    │   ├── credit_history_screen.dart
    │   └── widgets/
    │       ├── customer_form_dialog.dart
    │       └── record_payment_dialog.dart
    │
    ├── reports/
    │   ├── reports_screen.dart      # Main dashboard
    │   ├── reports_provider.dart    # All report providers
    │   ├── transactions_screen.dart # Date-filtered transactions
    │   ├── best_sellers_screen.dart # Best selling products
    │   ├── daily_sales_screen.dart  # Daily sales history
    │   └── widgets/
    │       ├── summary_card.dart
    │       └── recent_transactions.dart
    │
    └── settings/
        ├── settings_screen.dart     # Business profile & dark mode
        └── settings_provider.dart  # Settings providers
```

---

## 🔥 Firestore Database Structure

```
firestore/
├── products/
│   └── {productId}
│       ├── name: string
│       ├── category: string
│       ├── price: number
│       ├── stockQuantity: number
│       ├── lowStockThreshold: number
│       └── createdAt: timestamp
│
├── customers/
│   └── {customerId}
│       ├── name: string
│       ├── phone: string
│       ├── creditBalance: number
│       └── createdAt: timestamp
│
└── transactions/
    └── {transactionId}
        ├── items: array
        │   ├── productId: string
        │   ├── productName: string
        │   ├── quantity: number
        │   └── unitPrice: number
        ├── totalAmount: number
        ├── paymentMethod: string (cash | credit | mobileMoney)
        ├── customerId: string (nullable)
        └── createdAt: timestamp
```

---

## 🔒 Firestore Security Rules

The following rules are applied in Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Only authenticated users can read or write data.

---

## 📌 Firestore Indexes Required

This project uses one composite index. Create it manually in Firebase Console → Firestore → Indexes:

| Collection | Field 1 | Field 2 | Field 3 | Scope |
|---|---|---|---|---|
| transactions | customerId (Asc) | paymentMethod (Asc) | createdAt (Desc) | Collection |

---

## 🌿 Git Workflow

We use a simple branching strategy:

```
main          ← stable, working code only
dev           ← active development branch
feature/xxx   ← individual features
```

### Day-to-day workflow:

```bash
# Before starting work, pull latest changes
git pull origin main

# Create a feature branch
git checkout -b feature/your-feature-name

# Work on your feature, then commit
git add .
git commit -m "Add: description of what you did"

# Push your branch
git push origin feature/your-feature-name

# Open a Pull Request on GitHub for Barry to review before merging
```

### Commit message format:
```
Add: new feature
Fix: bug description
Update: what was changed
Remove: what was removed
```

---

## ⚠️ Common Issues & Fixes

### `flutterfire` not recognized
Add Pub Cache to your PATH:
```
C:\Users\YourName\AppData\Local\Pub\Cache\bin
```
Then restart VS Code.

### NDK build error
Delete the corrupted NDK folder:
```
C:\Users\YourName\AppData\Local\Android\sdk\ndk\[version number]
```
Then run `flutter build apk --release` again.

### Firestore index error
Open the URL printed in the terminal and click **Create Index** in Firebase Console. Wait ~2 minutes.

### `firebase_options.dart` missing
Ask Barry for this file — it contains Firebase credentials and is not stored in the repo.

### Multiple heroes error
Every `FloatingActionButton` needs a unique `heroTag`:
```dart
FloatingActionButton(
  heroTag: 'unique_tag_name',
  ...
)
```

---

## 📞 Contact

For access to the Firebase project or the `firebase_options.dart` file, contact **mwewankandu**.
