# PANDUAN LENGKAP: Build APK dengan Codemagic (Cloud CI/CD)
## Tanpa Install Android SDK di Laptop!

---

## APA ITU CODEMAGIC?

Codemagic adalah **Cloud CI/CD** (Continuous Integration/Continuous Deployment) yang khusus dibuat untuk Flutter, React Native, iOS, dan Android.

**Keuntungan:**
- ✅ Tidak perlu install Android Studio/SDK
- ✅ Tidak perlu setup Gradle/Keystore
- ✅ Build di cloud (Mac Mini M2), download APK-nya
- ✅ GRATIS 500 build minutes/bulan
- ✅ Auto-build setiap push ke GitHub

---

## STEP 1: DAFTAR & LOGIN

### 1.1 Buat Akun Codemagic
1. Buka https://codemagic.io/
2. Klik **"Sign Up"**
3. Pilih **Sign up with GitHub** (paling mudah)
4. Authorize Codemagic untuk akses repo GitHub

### 1.2 Verifikasi Email
- Cek email, klik link verifikasi
- Setup profile (nama, company, dll)

---

## STEP 2: UPLOAD PROJECT KE GITHUB

### 2.1 Buat Repository GitHub
1. Buka https://github.com/new
2. Repository name: `pos-gideon`
3. Description: `POS App for Toko Gideon`
4. Pilih **Public** (atau Private kalau mau)
5. Klik **Create repository**

### 2.2 Upload Code ke GitHub
```bash
# Buka terminal/command prompt
# Masuk ke folder project:
cd pos_gideon

# Inisialisasi Git:
git init

# Tambah semua file:
git add .

# Commit:
git commit -m "Initial commit - POS Gideon"

# Connect ke GitHub:
git branch -M main
git remote add origin https://github.com/USERNAME_KAMU/pos-gideon.git

# Push:
git push -u origin main
```

**Catatan:** Ganti `USERNAME_KAMU` dengan username GitHub kamu.

---

## STEP 3: CONNECT REPO KE CODEMAGIC

### 3.1 Add Application
1. Di dashboard Codemagic, klik **"Add application"**
2. Pilih **GitHub** sebagai Git provider
3. Cari dan pilih repo `pos-gideon`
4. Klik **"Add"**

### 3.2 Setup Workflow

Codemagic akan otomatis scan project Flutter kamu. Ada 2 cara:

#### CARA A: Workflow Editor (GUI) - Paling Mudah
1. Di app settings, pilih tab **"Workflow Editor"**
2. Pilih **Flutter** sebagai framework
3. Under **Build for platforms**, centang **Android**
4. Under **Build mode**, pilih **Release**
5. Scroll ke **Build** section:
   - Flutter version: `Stable`
   - Build command: `flutter build apk --release`
6. Scroll ke **Artifacts**:
   - Centang **APK**
7. Klik **Save** di atas

#### CARA B: codemagic.yaml (File Config)
1. File `codemagic.yaml` sudah ada di project kamu
2. Codemagic akan otomatis detect dan pakai file ini
3. Kalau mau pakai config simple, rename `codemagic-simple.yaml` jadi `codemagic.yaml`

---

## STEP 4: BUILD PERTAMA (Unsigned/Debug)

### 4.1 Start Build
1. Di dashboard Codemagic, klik **"Start new build"**
2. Pilih branch: `main`
3. Pilih workflow: `pos-gideon-build` (atau default)
4. Klik **"Start new build"**

### 4.2 Tunggu Build
- Build akan berjalan di Mac Mini M2 cloud
- Waktu: ~5-10 menit untuk project Flutter baru
- Bisa lihat log real-time

### 4.3 Download APK
1. Setelah build sukses (green checkmark), klik build tersebut
2. Scroll ke **Artifacts** section
3. Klik **Download** pada file `app-release.apk`
4. APK akan download ke laptop

### 4.4 Install ke HP
```bash
# Via ADB (kalau HP sudah connect USB)
adb install app-release.apk

# Atau copy file APK ke HP, lalu install manual
# (Aktifkan "Install from unknown sources" di Settings > Security)
```

---

## STEP 5: BUILD RELEASE (Signed APK)

Untuk APK yang bisa diinstall di semua HP tanpa warning, perlu **signing**.

### 5.1 Upload Keystore (Sekali saja)
1. Di Codemagic, masuk ke **App Settings**
2. Tab **Code signing identities**
3. Klik **Android keystore** → **Add keystore**
4. Pilih **Generate new keystore**
5. Isi:
   - Keystore password: `gideon123` (atau password kamu)
   - Key alias: `upload`
   - Key password: `gideon123`
6. Klik **Add keystore**
7. **Simpan password dengan aman!** Kalau hilang, tidak bisa update app di Play Store.

### 5.2 Update Workflow untuk Signed Build
1. Edit workflow (Workflow Editor)
2. Under **Code signing**, pilih keystore yang baru dibuat
3. Save

### 5.3 Build Lagi
1. Start new build
2. APK yang dihasilkan sekarang sudah **signed**
3. Download dan install

---

## STEP 6: SETUP FIREBASE (WAJIB)

### 6.1 Buat Project Firebase
1. Buka https://console.firebase.google.com/
2. Klik **"Add project"**
3. Nama: `pos-gideon`
4. Matikan Google Analytics (atau aktifkan)
5. Klik **Create project**

### 6.2 Tambah Android App
1. Di Firebase dashboard, klik icon **Android** (</>)
2. Android package name: `com.gideon.pos`
3. App nickname: `POS Gideon`
4. Klik **Register app**
5. Download `google-services.json`
6. **Jangan klik Next dulu!**

### 6.3 Upload google-services.json ke GitHub
```bash
# Copy file ke project:
cp ~/Downloads/google-services.json pos_gideon/android/app/

# Commit dan push:
cd pos_gideon
git add android/app/google-services.json
git commit -m "Add Firebase config"
git push
```

### 6.4 Enable Firebase Services
1. Di Firebase Console, sidebar kiri:
2. **Authentication** → Sign-in method → **Email/Password** → Enable → Save
3. **Firestore Database** → Create database → **Start in test mode** → Enable
4. **Storage** → Get started → Enable (opsional untuk gambar)

### 6.5 Setup Firestore Rules (Sementara)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
Klik **Publish**.

### 6.6 Generate firebase_options.dart
```bash
# Install FlutterFire CLI:
dart pub global activate flutterfire_cli

# Configure:
flutterfire configure --project=pos-gideon

# Commit hasilnya:
git add lib/firebase_options.dart
git commit -m "Add Firebase options"
git push
```

---

## STEP 7: BUILD ULANG SETELAH FIREBASE SETUP

1. Push semua perubahan ke GitHub
2. Di Codemagic, klik **"Start new build"**
3. Build akan otomatis include Firebase config
4. Download APK baru
5. Test login dan fitur Firebase

---

## STEP 8: AUTO-BUILD (Opsional)

### 8.1 Setup Trigger
1. Di Codemagic app settings, tab **Triggers**
2. Enable **"Trigger on push"**
3. Branch pattern: `main`
4. Save

Sekarang setiap kali kamu push code ke GitHub, Codemagic akan otomatis build APK baru!

### 8.2 Setup Email Notification
1. Tab **Notifications**
2. Add email: `gideon@emailkamu.com`
3. Enable notify on success/failure

---

## TROUBLESHOOTING

### Error: "Could not find com.google.gms:google-services"
**Solusi:**
- Pastikan `google-services.json` sudah di folder `android/app/`
- Pastikan sudah di-push ke GitHub
- Pastikan `android/app/build.gradle` punya baris:
  ```
  id "com.google.gms.google-services"
  ```

### Error: "Firebase App not initialized"
**Solusi:**
- Pastikan `main.dart` sudah include `Firebase.initializeApp()`
- Pastikan `firebase_options.dart` sudah di-generate
- Jalankan `flutterfire configure` lagi

### Error: "Build failed - gradle"
**Solusi:**
- Di Codemagic workflow, tambah script:
  ```
  flutter clean
  flutter pub get
  ```
- Sebelum build command

### Error: "Bluetooth package not found"
**Solusi:**
- Package `bluetooth_print` hanya work di Android/iOS native
- Di Codemagic build untuk Android, ini akan work
- Kalau build untuk Web, akan error (jangan build web)

### APK tidak bisa install di HP
**Solusi:**
- Debug APK: Aktifkan "Unknown sources" di Settings > Security
- Release APK: Pastikan sudah signed (Step 5)
- Cek minimum SDK: HP Android harus API 21+ (Android 5.0+)

---

## RINGKASAN PERINTAH GIT

```bash
# Setiap kali ada perubahan code:
git add .
git commit -m "Deskripsi perubahan"
git push

# Lalu tunggu Codemagic auto-build, atau manual start build
```

---

## STRUKTUR FILE YANG PENTING

```
pos_gideon/
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── google-services.json    ← WAJIB ADA (Firebase)
│   └── build.gradle
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart       ← Auto-generated
│   ├── models/
│   ├── providers/
│   ├── services/
│   └── screens/
├── pubspec.yaml
├── codemagic.yaml                  ← Config Codemagic
└── .gitignore
```

---

## ESTIMASI WAKTU

| Step | Waktu |
|------|-------|
| Daftar Codemagic | 5 menit |
| Upload ke GitHub | 10 menit |
| Connect ke Codemagic | 5 menit |
| Build pertama | 5-10 menit |
| Setup Firebase | 15 menit |
| Build final | 5-10 menit |
| **TOTAL** | **~45-60 menit** |

---

## BIAYA

- **Codemagic**: GRATIS 500 build minutes/bulan (cukup untuk ~50-100 build)
- **GitHub**: GRATIS untuk public repo
- **Firebase**: GRATIS tier (Spark Plan) - cukup untuk startup
- **Total**: **Rp 0** untuk mulai!

---

## KONTAK SUPPORT

- Codemagic Docs: https://docs.codemagic.io/
- Flutter Docs: https://docs.flutter.dev/
- Firebase Docs: https://firebase.google.com/docs/flutter/setup

Selamat build, Gideon! 🚀
