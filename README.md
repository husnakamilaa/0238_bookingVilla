# booking_villa
Booking Villa adalah aplikasi *mobile* berbasis Flutter yang menyediakan solusi penyewaan dan manajemen villa secara komprehensif. Aplikasi ini terintegrasi dengan backend Supabase dan menggunakan arsitektur BLoC untuk *state management*. Proyek ini dirancang untuk memberikan kemudahan bagi pelanggan (pencarian, pemesanan, pembayaran) serta kemudahan bagi pengelola (manajemen inventaris dan statistik pesanan).

# Dokumentasi
| **Splash Screen** | **Login** | **Register** | 
|:----------------------:|:----------------------:|:----------------------:|
|<img width="300" alt="image" src="https://github.com/user-attachments/assets/f406fd6c-178a-4a0c-a275-3713055c7dd2" />|<img width="300" alt="image" src="https://github.com/user-attachments/assets/09641ac8-cac6-4ec1-bc3d-8bb5575cf08a" />|<img width="300" alt="image" src="https://github.com/user-attachments/assets/b36e2ab5-6b7d-4a52-bb60-11f39b3a766e" />|

# Product Requirements Document (PRD)

## 1. Problem Statement
Saat ini, pencarian dan pemesanan villa masih sering dilakukan secara manual atau melalui platform yang kurang terintegrasi, sehingga menimbulkan beberapa masalah:
- **Pelanggan** kesulitan menemukan villa yang sesuai dengan kebutuhan (lokasi, fasilitas, dan harga) serta sulit melacak riwayat pemesanan dan pembayaran.
- **Pemilik/Pengelola Villa** (Admin) mengalami kesulitan dalam mengelola data villa, melacak ketersediaan, serta memantau statistik pemesanan dan pembayaran secara real-time.
- Tidak adanya sistem terpusat mengakibatkan proses pemesanan yang lambat, rentan kesalahan, dan kurang transparan, baik dari segi ketersediaan maupun riwayat transaksi (invoice).

## 2. Proposed Solution
Membangun sebuah aplikasi **Booking Villa** berbasis *mobile* menggunakan Flutter dengan integrasi *Backend-as-a-Service* (BaaS) Supabase. Aplikasi ini menyediakan solusi dua sisi (Admin dan Customer) yang terintegrasi penuh:
- **Untuk Customer:** Menyediakan platform pencarian katalog villa, detail fasilitas, proses pemesanan, pembayaran yang mulus, serta penerbitan invoice secara otomatis dan pelacakan riwayat pesanan.
- **Untuk Admin:** Menyediakan *dashboard* dengan statistik dinamis untuk memantau performa, fitur manajemen inventaris villa (tambah, edit, list), serta manajemen pemesanan secara komprehensif.
Sistem dibangun dengan *state management* BLoC (Business Logic Component) untuk memastikan performa yang cepat dan responsif.

## 3. Feature List
Aplikasi ini terbagi ke dalam beberapa modul utama yang melayani fungsionalitas berbeda:

### Modul Autentikasi (Auth)
- **Login:** Autentikasi pengguna menggunakan email dan password.
- **Register:** Pendaftaran pengguna baru dengan penanganan error (misalnya, jika email sudah terdaftar).

### Modul Customer
- **Dashboard Customer:** Halaman utama yang menampilkan ringkasan informasi dan rekomendasi.
- **Katalog Villa:** Daftar villa yang tersedia untuk disewa beserta detailnya.
- **Pemesanan (Booking):** Form untuk melakukan pemesanan (tanggal check-in, check-out, dsb).
- **Pembayaran (Payment):** Halaman pemrosesan pembayaran dan konfirmasi.
- **Invoice:** Penerbitan nota/tagihan otomatis setelah pembayaran berhasil (sinkronisasi UI/warna berdasarkan status pembayaran).
- **Riwayat Pesanan:** Melacak status dan riwayat pemesanan yang pernah dilakukan.
- **Cart:** Menyimpan villa yang disukai di halaman ini.

### Modul Admin
- **Dashboard Admin:** Dasbor berisi ringkasan statistik pemesanan (pendapatan, jumlah pesanan) secara dinamis.
- **Manajemen Villa:** Fitur CRUD (Create, Read, Update, Delete) data villa (menambahkan villa baru, mengedit info, dan melihat daftar villa).
- **Manajemen Booking:** Memantau seluruh pemesanan pelanggan, mengubah status pesanan, dan melihat detail spesifik pesanan.

### Fungsionalitas Teknis & Infrastruktur
- **State Management:** Flutter BLoC untuk mengelola *state* Auth, Booking, Payment, Profiles, Stats, dan Villa.
- **Backend:** Repositori terintegrasi dengan Supabase untuk layanan basis data dan autentikasi.

## 4. Progres Mingguan

Berikut adalah rincian progres mingguan untuk pengembangan aplikasi Booking Villa:

* **Minggu 1: Perencanaan**
  - Setup inisialisasi proyek Flutter dan konfigurasi *repository* Git.

* **Minggu 2: Setup Backend & Autentikasi**
  - Konfigurasi Supabase untuk *database* dan *storage*.
  - Pembuatan tabel SQL untuk entitas User, Villa, dan Pemesanan.
  - Mengimplementasikan fitur Login dan Register menggunakan *Supabase Auth*.

* **Minggu 3: Pengembangan Inti Modul Admin**
  - Membuat halaman *Dashboard* Admin dengan ringkasan data.
  - Mengimplementasikan fitur CRUD (Create, Read, Update, Delete) untuk Manajemen Villa.
  - Mengatur *state management* menggunakan BLoC untuk data villa.

* **Minggu 4: Pengembangan Inti Modul Customer**
  - Membangun halaman *Dashboard Customer* dan Katalog Villa.
  - Membuat halaman Detail Villa beserta galeri foto.
  - Mengembangkan sistem pemesanan (*booking flow*) dengan pemilihan tanggal.

* **Minggu 5: Sistem Pembayaran & Invoice**
  - Mengintegrasikan logika pembayaran tiruan (*mock payment*) untuk pesanan.
  - Membuat halaman *checkout* dan konfirmasi pembayaran.
  - Mengembangkan fitur *generate* Invoice otomatis setelah status *paid*.

* **Minggu 6: Integrasi Penuh & Bug Fixing**
  - Menghubungkan seluruh modul Customer dengan *dashboard* Manajemen Booking milik Admin.
  - Melakukan *testing* UI dan perbaikan *bug* (*error handling* pada form).
  - Menambahkan fitur baru *cart* untuk menyimpan villa yang disukai