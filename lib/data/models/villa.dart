class VillaModel {
  final int? id;
  final String namaVilla;
  final String deskripsi;
  final int price;
  final String notelpVilla;
  final String image;
  final String statusAvailable;
  final String maps;
  final String alamat;
  final DateTime? createdAt;
  final double? latitude;
  final double? longitude;

  VillaModel({
    this.id,
    required this.namaVilla,
    required this.deskripsi,
    required this.price,
    required this.notelpVilla,
    required this.image,
    required this.statusAvailable,
    required this.maps,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    this.createdAt,
  });

  factory VillaModel.fromJson(Map<String, dynamic> json) {
    return VillaModel(
      id: json['id'],
      namaVilla: json['nama_villa'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      price: json['price'] ?? 0,
      notelpVilla: json['notelp_villa'] ?? '',
      image: json['image'] ?? '',
      statusAvailable: json['status_available'] ?? 'available',
      maps: json['maps'] ?? '',
      alamat: json['alamat'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_villa': namaVilla,
      'deskripsi': deskripsi,
      'price': price,
      'notelp_villa': notelpVilla,
      'image': image,
      'status_available': statusAvailable,
      'maps': maps,
      'alamat': alamat,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
