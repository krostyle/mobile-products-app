class Supplier {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final List<String> productIds;

  Supplier({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    List<String>? productIds,
  }) : productIds = productIds ?? [];

  factory Supplier.fromFirestore(Map<String, dynamic> data, String id) {
    final rawList = data['productIds'];
    final List<String> ids = rawList is List
        ? rawList
              .map((e) => e?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList()
        : <String>[];
    return Supplier(
      id: id,
      name: data['name'] ?? '',
      email: data['email'],
      phone: data['phone'],
      address: data['address'],
      productIds: ids,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'productIds': productIds,
    };
  }
}
