# Folder Assets Images

## Cara Menambahkan Logo Kampus

1. **Siapkan file logo kampus** dalam format PNG atau JPG
2. **Rename file logo** menjadi `logo_polindra.png` (atau sesuaikan dengan nama yang ada di kode)
3. **Letakkan file logo** di folder ini: `assets/images/`
4. **Jalankan perintah** `flutter pub get` untuk memastikan assets ter-load
5. **Restart aplikasi** untuk melihat logo yang baru

## Struktur Folder
```
assets/
└── images/
    └── logo_polindra.png  <- Logo kampus di sini
```

## Format Logo yang Disarankan
- **Format**: PNG (transparan) atau JPG
- **Ukuran**: 200x200 px atau lebih besar
- **Background**: Transparan atau putih
- **Nama file**: `logo_polindra.png`

## Jika Logo Tidak Muncul
- Pastikan nama file sesuai dengan yang ada di kode
- Pastikan file ada di folder `assets/images/`
- Jalankan `flutter clean` dan `flutter pub get`
- Restart aplikasi
