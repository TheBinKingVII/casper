# GoScale – Smart Vehicle Weighing Controller

GoScale adalah aplikasi Flutter untuk memonitor dan mengendalikan sistem timbang kendaraan berbasis IoT. Aplikasi ini terhubung ke perangkat melalui REST API, menampilkan data berat secara real-time, mengirim perintah kontrol, serta menyimpan log berat untuk audit.

## Fitur Utama

- **Registrasi & manajemen perangkat**: simpan `device_id` secara lokal agar sesi tetap tersambung (`DevicePrefs`).
- **Controller real-time** (`lib/screens/controller_screen.dart`): menampilkan berat terkini, status overload, progress bar, dan tombol kendali (forward, reverse, stop, dll). Data diperbarui setiap detik.
- **History/Log berat** (`lib/screens/history_screen.dart`): menampilkan daftar log telemetry dengan auto-refresh setiap 1 detik, lengkap dengan status overload & timestamp.
- **Pengaturan berat maksimal** (`SettingsProvider` + `HomeScreen`): ambil & perbarui batas berat lewat endpoint `/settings`.
- **Notifikasi lokal** (`NotificationService`): otomatis mengirimkan notifikasi saat overload terdeteksi atau pulih.
- **Arsitektur Provider**: `DeviceProvider`, `SettingsProvider`, dan `ControlProvider` mengelola state dan request API.

## Teknologi

- Flutter 3.9+, Dart 3
- State management: [provider](https://pub.dev/packages/provider)
- Networking: [dio](https://pub.dev/packages/dio)
- Penyimpanan lokal: [shared_preferences](https://pub.dev/packages/shared_preferences)
- Notifikasi: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- Format/utility: `intl`, `google_fonts`

## Struktur Proyek (ringkas)

```
lib/
├── core/
│   └── constants.dart         # Konfigurasi global (base URL, timeout, dsb)
├── models/                    # Model data (device status, telemetry, dsb)
├── providers/                 # State management menggunakan Provider
├── screens/
│   ├── home_screen.dart       # Registrasi perangkat & pengaturan
│   ├── controller_screen.dart # Monitoring & kontrol real-time
│   └── history_screen.dart    # Log/riwayat berat
├── services/
│   ├── api_service.dart       # Wrapper Dio untuk endpoint backend
│   └── notification_service.dart
└── shared/
    └── device_prefs.dart      # Helper SharedPreferences
```

## Persiapan & Prasyarat

1. **Install Flutter SDK** 3.9.2 atau lebih baru dan pastikan `flutter doctor` bersih.
2. **Android/iOS toolchain** sesuai kebutuhan target build.
3. **Backend API** berjalan & dapat diakses; URL dasar berada di `lib/core/constants.dart` (`AppConstants.baseUrl`).
4. **Ikon Android**: pastikan semua file di `android/app/src/main/res/mipmap-*/` mengikuti format nama huruf kecil tanpa spasi (mis. `ic_launcher.png`).

## Menjalankan Aplikasi (Development)

```bash
flutter pub get
flutter run
```

## Build Rilis

```bash
# Android APK
flutter build apk --release

# (Opsional) iOS
flutter build ios --release
```

> **Catatan ikon Android**: jika mengganti ikon, ubah seluruh referensi `@mipmap/ic_launcher` di `AndroidManifest.xml`, `notification_service.dart`, dan pastikan nama file memenuhi aturan resource Android.

## Konfigurasi Penting

- **Base URL API**: ubah `AppConstants.baseUrl` di `lib/core/constants.dart` sesuai environment (dev/staging/prod).
- **Interval refresh**: controller & history memakai interval 1 detik (`Timer.periodic`). Sesuaikan jika beban jaringan terlalu besar.
- **Notifikasi**: `NotificationService` meminta izin notifikasi di Android 13+. Pastikan ikon notifikasi tersedia (`@mipmap/ic_launcher`).

## Alur Data Singkat

1. Pengguna mendaftarkan atau memilih `device_id`.
2. `DeviceProvider` memanggil `ApiServices.getDeviceStatus()` untuk berat real-time.
3. `SettingsProvider` memuat batas berat maksimal dari endpoint `/settings`.
4. `ControlProvider` mengirim perintah motor/alarm ke endpoint `/control`.
5. `HistoryScreen` menampilkan data `/telemetry` dengan pagination & auto-refresh.

## Troubleshooting

- **Build gagal karena nama ikon**: ganti nama file ikon agar huruf kecil + underscore (contoh: `casper_logo_mobil.png`) dan update referensinya.
- **APK macet di splash screen**: biasanya akibat resource ikon hilang atau exception saat `NotificationService.initialize`. Periksa `adb logcat` untuk detail.
- **API error**: cek log backend dan pastikan `baseUrl` benar; aplikasi menampilkan pesan error dari server melalui provider masing-masing.

## Kontribusi

1. Fork repo & buat branch fitur: `git checkout -b feature/fitur-baru`.
2. Tambahkan perubahan + tes terkait.
3. Buat PR dengan deskripsi jelas.

## Lisensi

Lisensi belum ditentukan. Tambahkan ketentuan lisensi sesuai kebutuhan proyek sebelum distribusi publik.
