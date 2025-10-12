# UPA Kerjasama Mobile

Aplikasi mobile Flutter untuk sistem kerjasama UPA (Unit Pengembangan Alumni) yang terhubung dengan backend Laravel.

## Fitur

- **Login/Logout**: Autentikasi menggunakan Laravel Sanctum
- **Role-based Access**: Mendukung role Alumni, Mitra, dan Admin
- **Job Listings**: Menampilkan daftar lowongan kerja dari database
- **Job Details**: Detail lengkap lowongan kerja
- **User Profile**: Profil pengguna berdasarkan role
- **Search & Filter**: Pencarian dan filter lowongan kerja

## Setup

### 1. Backend (Laravel)

Pastikan Laravel backend sudah berjalan dengan:
- Laravel Sanctum terinstall
- Database sudah di-migrate
- User dengan role sudah ada di database

### 2. Frontend (Flutter)

1. Install dependencies:
```bash
cd upa_kerjasama_mobile
flutter pub get
```

2. Konfigurasi API URL:
Edit file `lib/config/api_config.dart`:
```dart
class ApiConfig {
  // Untuk Android emulator
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Untuk iOS simulator
  // static const String baseUrl = 'http://localhost:8000/api';
  
  // Untuk device fisik (ganti dengan IP komputer Anda)
  // static const String baseUrl = 'http://192.168.1.100:8000/api';
}
```

3. Jalankan aplikasi:
```bash
flutter run
```

## API Endpoints

### Authentication
- `POST /api/login` - Login user
- `POST /api/logout` - Logout user
- `GET /api/profile` - Get user profile

### Jobs
- `GET /api/jobs` - Get jobs list
- `GET /api/jobs/{id}` - Get job detail

## Models

### User
- `id`: String
- `name`: String
- `email`: String
- `roles`: List<String>

### Job
- `id`: String
- `judul`: String
- `deskripsi`: String
- `lokasi`: String
- `gajiMin`: String?
- `gajiMax`: String?
- `jenisPekerjaan`: String?
- `pendidikan`: String?
- `persyaratan`: String?
- `mitraPerusahaan`: MitraCompany?

## Dependencies

- `http`: ^1.1.0 - HTTP requests
- `shared_preferences`: ^2.2.2 - Local storage
- `provider`: ^6.1.1 - State management
- `json_annotation`: ^4.8.1 - JSON serialization

## Struktur Project

```
lib/
├── config/
│   └── api_config.dart
├── models/
│   ├── user_model.dart
│   └── job_model.dart
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── job_service.dart
├── user/
│   ├── components/
│   └── pages/
├── mitra/
│   ├── components/
│   └── pages/
└── main.dart
```

## Troubleshooting

1. **Connection Error**: Pastikan URL API benar dan Laravel server berjalan
2. **Login Failed**: Pastikan user ada di database dengan role yang benar
3. **No Jobs**: Pastikan ada data lowongan di database dengan status 'aktif'

## Testing

Untuk testing, pastikan:
1. Laravel server berjalan di port 8000
2. Database sudah di-migrate dan di-seed
3. Ada user dengan role 'alumni' di database
4. Ada data lowongan kerja di database