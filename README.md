# 📦 Smart SME Business Management System

A Flutter-based business management system for small and medium enterprises (SMEs), targeting both Android and Web platforms. Built with Firebase, Riverpod, and Material 3.

---

## 👥 Team

| Name | Role |
|---|---|
| Mwewa Nkandu | Lead Developer |
| Mwape | Developer |
| Moses | Developer |

---

## ✅ Features

- 🔐 Authentication — Sign up / Sign in with email and password, per-user isolated data
- 📦 Inventory Management — Add, edit, delete, restock products with low stock alerts
- 🔍 Search & Category Filter — Search products by name, filter by category
- 🛒 Sales Recording — Cart-based sales with cash, credit, and mobile money support
- 🧾 Receipt Screen — Itemized receipt shown automatically after every sale
- 👥 Customer & Credit Management — Track customers and outstanding balances
- 📋 Credit History — Per-customer itemized credit purchase history
- 💳 Credit Payment Recording — Record partial or full payments against balances
- 📊 Reports & Dashboard — Today's revenue, weekly/monthly summaries
- 🧾 Transactions — Date range filtered transaction history
- 🏆 Best Selling Products — Ranked product performance with progress bars
- 📅 Daily Sales History — Day-by-day sales breakdown with best day highlight
- ⚙️ Business Profile — Set business name, address, owner info, currency symbol
- 🌙 Dark Mode — Persistent light/dark theme toggle
- 🔔 Low Stock Notifications — Push notifications on Android, in-app banner on Web
- 🔒 Per-User Data Isolation — Every account has its own completely separate business data

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter (Dart) | UI framework — Android & Web |
| Firebase Auth | User authentication |
| Cloud Firestore | Real-time NoSQL database |
| Riverpod | State management |
| Google Fonts | Typography (Inter) |
| Shared Preferences | Local storage for settings |
| flutter_local_notifications | Push notifications on Android |
| flutter_launcher_icons | App icon generation |

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

#### VS Code Extensions (install after VS Code):
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



---

### 4. Get the Firebase Configuration File

This project uses Firebase. The configuration file contains credentials and is **not committed to the repo** for security reasons.

Ask Barry to share these two files:
- `lib/firebase_options.dart` → place in `lib/`
- `android/app/google-services.json` → place in `android/app/`

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

First enable USB Debugging on your phone:
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

### 8. Build a Release APK

```bash
flutter build apk --release
```

The APK will be at:
```
build\app\outputs\flutter-apk\app-release.apk
```

You can copy this file to any Android phone and install it directly.

> **NDK Error during build?** Delete the folder at:
> `C:\Users\YourName\AppData\Local\Android\sdk\ndk\[version]`
> Then run the build command again — it re-downloads automatically.

---

## 📱 App Navigation

The app uses a bottom navigation bar with 5 tabs:

| Tab | Screen |
|---|---|
| Dashboard | Revenue overview, best sellers preview, recent transactions |
| Transactions | Date-range filtered full transaction history |
| Sales | Cart-based new sale recording |
| Inventory | Product list with search, category filter, restock |
| Customers | Customer list, credit balances, payment recording |

Settings (business profile, dark mode, sign out) are accessible via the ⚙️ icon in the top right of the app bar.

---

## 📁 Project Structure

```
lib/
├── main.dart
├── firebase_options.dart            ← not in repo, get from Barry
│
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   ├── theme/
│   │   └── app_theme.dart           ← light and dark themes
│   └── services/
│       ├── notification_service.dart
│       └── low_stock_monitor.dart
│
├── models/
│   ├── product.dart
│   ├── customer.dart
│   └── transaction.dart
│
└── features/
    ├── auth/
    │   ├── auth_provider.dart
    │   ├── auth_gate.dart
    │   └── login_screen.dart
    │
    ├── shell/
    │   └── main_shell.dart          ← bottom nav + app bar
    │
    ├── inventory/
    │   ├── inventory_screen.dart
    │   ├── inventory_provider.dart
    │   └── widgets/
    │       ├── product_card.dart
    │       ├── product_form_dialog.dart
    │       └── restock_dialog.dart
    │
    ├── sales/
    │   ├── sales_screen.dart
    │   ├── sales_provider.dart
    │   ├── receipt_screen.dart
    │   └── widgets/
    │       └── cart_item_tile.dart
    │
    ├── customers/
    │   ├── customers_screen.dart
    │   ├── customer_provider.dart
    │   ├── credit_history_screen.dart
    │   └── widgets/
    │       ├── customer_form_dialog.dart
    │       └── record_payment_dialog.dart
    │
    ├── reports/
    │   ├── reports_screen.dart
    │   ├── reports_provider.dart
    │   ├── transactions_screen.dart
    │   ├── best_sellers_screen.dart
    │   ├── daily_sales_screen.dart
    │   └── widgets/
    │       ├── summary_card.dart
    │       └── recent_transactions.dart
    │
    └── settings/
        ├── settings_screen.dart
        └── settings_provider.dart
```

---

## 🔥 Firestore Database Structure

All data is scoped per user — each business account has completely isolated data:

```
firestore/
└── users/
    └── {userId}/
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

Applied in Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
```

Each user can only access their own data.

---

## 📌 Firestore Index Required

Create this composite index in Firebase Console → Firestore → Indexes:

| Collection Group | Field 1 | Field 2 | Field 3 | Scope |
|---|---|---|---|---|
| transactions | customerId (Asc) | paymentMethod (Asc) | createdAt (Desc) | Collection group |

---

## 🌿 Git Workflow

```
main          ← stable, working code only
dev           ← active development branch
feature/xxx   ← individual features
```

### Day-to-day workflow:

```bash
# Pull latest before starting
git pull origin main

# Create a feature branch
git checkout -b feature/your-feature-name

# Commit your work
git add .
git commit -m "Add: description of what you did"

# Push your branch
git push origin feature/your-feature-name

# Open a Pull Request on GitHub for review before merging to main
```

### Commit message format:
```
Add: new feature or file
Fix: bug or error
Update: change to existing feature
Remove: deleted something
```

---

## ⚠️ Common Issues & Fixes

### `flutterfire` not recognized
Add Pub Cache to your system PATH:
```
C:\Users\YourName\AppData\Local\Pub\Cache\bin
```
Then fully restart VS Code.

### NDK build error
Delete the corrupted folder:
```
C:\Users\YourName\AppData\Local\Android\sdk\ndk\[version]
```
Run `flutter build apk --release` again.

### Firestore permission error when switching accounts
This is fixed by the `ValueKey(user.uid)` in `auth_gate.dart` which resets all providers on user change. If it still occurs, do a full hot restart (`R` in terminal).

### Firestore index error on credit history
Open the URL printed in the terminal and click **Create Index** in Firebase Console. Wait ~2 minutes for it to build.

### `firebase_options.dart` missing
This file is not in the repo. Contact Barry for it.

### Multiple heroes error (FloatingActionButton)
Every FAB needs a unique `heroTag`:
```dart
FloatingActionButton(
  heroTag: 'unique_tag_name',
  ...
)
```

### Core library desugaring error (APK build)
Make sure `android/app/build.gradle.kts` has:
```kotlin
compileOptions {
  isCoreLibraryDesugaringEnabled = true
  sourceCompatibility = JavaVersion.VERSION_17
  targetCompatibility = JavaVersion.VERSION_17
}

dependencies {
  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

---

## 📞 Contact

For Firebase config files or repo access, contact **mwewankandu**.
