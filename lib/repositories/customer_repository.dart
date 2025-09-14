// customers_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gashub_flutter/models/customer_entity.dart';

class CustomerRepository {
  final CollectionReference _customersCollection =
      FirebaseFirestore.instance.collection('customers');

  // Criar ou atualizar um cliente
  Future<void> saveCustomer(CustomerEntity customer) async {
    try {
      if (customer.id == null) {
        // Cliente novo - adiciona (não precisa capturar o docRef se não for usar)
        await _customersCollection.add(customer.toMap());
      } else {
        // Cliente existente - atualiza
        await _customersCollection.doc(customer.id).set(customer.toMap());
      }
    } catch (e) {
      throw Exception('Erro ao salvar cliente: $e');
    }
  }

  // Buscar cliente por ID
  Future<CustomerEntity?> getCustomerById(String id) async {
    try {
      final doc = await _customersCollection.doc(id).get();
      if (doc.exists) {
        return CustomerEntity.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar cliente: $e');
    }
  }

  // Buscar cliente por telefone (evitar duplicatas)
  Future<CustomerEntity?> getCustomerByPhone(String phone) async {
    try {
      final query = await _customersCollection
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return CustomerEntity.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar cliente por telefone: $e');
    }
  }

  // Buscar cliente por CPF (evitar duplicatas)
  Future<CustomerEntity?> getCustomerByCpf(String cpf) async {
    try {
      final query = await _customersCollection
          .where('cpf', isEqualTo: cpf)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return CustomerEntity.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar cliente por CPF: $e');
    }
  }

  // Stream de todos os clientes (para listagem em tempo real)
  Stream<List<CustomerEntity>> watchAllCustomers() {
    return _customersCollection
        .orderBy('name') // Ordena por nome
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomerEntity.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  // Stream de clientes que permitem fiado
  Stream<List<CustomerEntity>> watchCustomersWithCredit() {
    return _customersCollection
        .where('allowsCredit', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomerEntity.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  // Buscar clientes por nome (para auto-complete)
  Future<List<CustomerEntity>> searchCustomersByName(String query) async {
    try {
      // Para buscas por prefixo (mais eficiente)
      final snapshot = await _customersCollection
          .orderBy('name')
          .startAt([query]).endAt(['$query\uf8ff']).get();

      return snapshot.docs
          .map((doc) => CustomerEntity.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar clientes: $e');
    }
  }

  // Deletar cliente
  Future<void> deleteCustomer(String id) async {
    try {
      await _customersCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar cliente: $e');
    }
  }

  // Atualizar apenas o status de fiado
  Future<void> updateCreditStatus(String customerId, bool allowsCredit) async {
    try {
      await _customersCollection
          .doc(customerId)
          .update({'allowsCredit': allowsCredit});
    } catch (e) {
      throw Exception('Erro ao atualizar status de fiado: $e');
    }
  }
}