// address.dart

class Address {
  final String street;
  final String number;
  final String neighborhood;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? complement; // Opcional
  final String? referencePoint; // "Ponto de referência"
  final String? coordinates;

  Address({
    required this.street,
    required this.number,
    required this.neighborhood,
    this.city,
    this.state,
    this.zipCode,
    this.complement,
    this.referencePoint,
    this.coordinates,
  });

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      if (complement != null && complement!.isNotEmpty) 'complement': complement,
      if (referencePoint != null && referencePoint!.isNotEmpty)
        'referencePoint': referencePoint,
      if (coordinates != null && coordinates!.isNotEmpty) 'coordinates': coordinates,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      street: map['street'] ?? '',
      number: map['number'] ?? '',
      neighborhood: map['neighborhood'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      complement: map['complement'],
      referencePoint: map['referencePoint'],
      coordinates: map['coordinates'],
    );
  }

  // Método útil para exibir o endereço formatado
  String get formattedAddress {
    return '$street, $number - $neighborhood';
  }
}