import 'package:gashub_flutter/models/customer_address_entity.dart';

class CustomerEntity {
  final String? id;
  final String name;
  final String phone;
  final Address address;
  final String? cpf;
  final bool? hasHisOwnHouse;
  final bool allowsCredit;
  final DateTime registrationDate;

  CustomerEntity({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.cpf,
    this.hasHisOwnHouse,
    required this.allowsCredit,
    required this.registrationDate,
  });

  // Converte o objeto para um Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'address': address.toMap(),
      if (cpf != null && cpf!.isNotEmpty) 'cpf': cpf,
      'allowsCredit': allowsCredit,
      'registrationDate': registrationDate.toIso8601String(),
      // Alteração sutil aqui para manter o padrão:
      if (hasHisOwnHouse != null) 'hasHisOwnHouse': hasHisOwnHouse,
    };
  }

  // Cria um objeto a partir de um Map (vindo do Firestore)
  factory CustomerEntity.fromMap(Map<String, dynamic> map, String documentId) {
    return CustomerEntity(
      id: documentId, // Usa o ID do documento do Firestore
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: Address.fromMap(Map<String, dynamic>.from(map['address'] ?? {})),
      cpf: map['cpf'],
      hasHisOwnHouse: map['hasHisOwnHouse'],
      allowsCredit: map['allowsCredit'] ?? false,
      registrationDate: DateTime.parse(map['registrationDate']),
    );
  }

  // Cópia do objeto para edição (útil para forms)
  CustomerEntity copyWith({
    String? id,
    String? name,
    String? phone,
    Address? address,
    String? cpf,
    bool? hasHisOwnHouse,
    bool? allowsCredit,
    DateTime? registrationDate,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      cpf: cpf ?? this.cpf,
      hasHisOwnHouse: hasHisOwnHouse ?? this.hasHisOwnHouse,
      allowsCredit: allowsCredit ?? this.allowsCredit,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }
}