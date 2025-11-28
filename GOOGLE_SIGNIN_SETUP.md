# Setup Google Sign-In untuk Mobile App

Dokumen ini menjelaskan cara mengkonfigurasi Google Sign-In untuk aplikasi mobile.

## Prerequisites

1. Flutter SDK terinstall
2. Android Studio / Xcode terinstall
3. Akun Google Developer Console

## Langkah-langkah Setup

### 1. Setup Google Cloud Console

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Buat project baru atau pilih project yang sudah ada
3. Enable **Google Sign-In API**:
   - Pergi ke "APIs & Services" > "Library"
   - Cari "Google Sign-In API"
   - Klik "Enable"

### 2. Setup OAuth 2.0 Credentials

#### Untuk Android:

1. Di Google Cloud Console, pergi ke "APIs & Services" > "Credentials"
2. Klik "Create Credentials" > "OAuth client ID"
3. Pilih "Android" sebagai application type
4. Masukkan informasi berikut:
   - **Name**: UPA Kerjasama Mobile Android
   - **Package name**: `com.example.upa_kerjasama_mobile` (sesuaikan dengan applicationId di build.gradle.kts)
   - **SHA-1 certificate fingerprint**: 
     - Untuk debug: Jalankan `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
     - Copy SHA-1 fingerprint dan paste di sini
5. Klik "Create"
6. **PENTING**: Copy **Client ID** yang dihasilkan

#### Untuk iOS (jika diperlukan):

1. Buat OAuth client ID baru dengan type "iOS"
2. Masukkan **Bundle ID** dari Xcode project
3. Copy **Client ID** yang dihasilkan

### 3. Konfigurasi Android

#### 3.1. Tambahkan SHA-1 ke Google Cloud Console

Jika belum menambahkan SHA-1:
1. Jalankan command berikut untuk mendapatkan SHA-1:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
2. Copy SHA-1 fingerprint
3. Tambahkan ke OAuth client ID di Google Cloud Console

#### 3.2. Verifikasi build.gradle.kts

Pastikan `minSdk` minimal 21 (sudah dikonfigurasi di `android/app/build.gradle.kts`):
```kotlin
minSdk = maxOf(flutter.minSdkVersion, 21)
```

### 4. Konfigurasi Backend (Laravel)

#### 4.1. Update .env

Tambahkan konfigurasi Google OAuth di file `.env`:
```env
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_REDIRECT_URI=http://localhost:8000/auth/google/callback
GOOGLE_MOBILE_CLIENT_IDS=com.your.app.id1,com.your.app.id2
```

Khusus `GOOGLE_MOBILE_CLIENT_IDS`, isi dengan daftar Client ID OAuth yang dipakai mobile (Android/iOS), pisahkan dengan koma. Contoh:
```
GOOGLE_MOBILE_CLIENT_IDS=1234567890-androidclientid.apps.googleusercontent.com,1234567890-iosclientid.apps.googleusercontent.com
```

#### 4.2. Install Dependencies (jika belum)

```bash
composer require laravel/socialite
```

#### 4.3. Verifikasi Konfigurasi

Pastikan file `config/services.php` sudah memiliki konfigurasi Google:
```php
'google' => [
    'client_id' => env('GOOGLE_CLIENT_ID'),
    'client_secret' => env('GOOGLE_CLIENT_SECRET'),
    'redirect' => env('GOOGLE_REDIRECT_URI'),
],
```

### 5. Install Flutter Dependencies

Jalankan command berikut di folder `upa_kerjasama_mobile`:
```bash
flutter pub get
```

### 6. Testing

1. **Test di Emulator/Device**:
   ```bash
   flutter run
   ```

2. **Test Google Sign-In**:
   - Buka aplikasi
   - Klik tombol "Masuk menggunakan Google"
   - Pilih akun Google
   - Verifikasi bahwa login berhasil dan profile tersinkronisasi

### 7. Troubleshooting

#### Error: "Sign in failed"
- Pastikan SHA-1 fingerprint sudah ditambahkan di Google Cloud Console
- Pastikan package name sesuai dengan applicationId di build.gradle.kts
- Pastikan Google Sign-In API sudah di-enable

#### Error: "Network error"
- Pastikan koneksi internet aktif
- Pastikan backend API dapat diakses
- Check log di Android Studio / Xcode untuk detail error

#### Profile tidak tersinkronisasi
- Check log backend untuk melihat apakah data Google diterima
- Pastikan endpoint `/api/auth/google` berfungsi dengan baik
- Check database untuk memastikan data tersimpan

### 8. Production Setup

Untuk production:
1. Generate release keystore:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Dapatkan SHA-1 dari release keystore:
   ```bash
   keytool -list -v -keystore ~/upload-keystore.jks -alias upload
   ```
3. Tambahkan SHA-1 release ke Google Cloud Console
4. Update `android/app/build.gradle.kts` dengan signing config untuk release

## Catatan Penting

1. **Client ID**: Jangan commit Client ID ke repository public
2. **SHA-1**: Setiap developer perlu menambahkan SHA-1 mereka sendiri
3. **Package Name**: Pastikan package name konsisten di semua tempat
4. **Backend**: Pastikan backend dapat menerima dan memproses data Google dengan benar

## Support

Jika mengalami masalah, check:
- [Google Sign-In Flutter Documentation](https://pub.dev/packages/google_sign_in)
- [Laravel Socialite Documentation](https://laravel.com/docs/socialite)
- Log aplikasi untuk detail error

