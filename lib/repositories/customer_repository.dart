import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gashub_flutter/models/customer_entity.dart';

class CustomerRepository {
  final CollectionReference _customersCollection =
      FirebaseFirestore.instance.collection('customers');

  Future<List<CustomerEntity>> getCustomers() async {
    try {
      final querySnapshot = await _customersCollection
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => CustomerEntity.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar clientes: $e');
    }
  }

  Stream<List<CustomerEntity>> watchAllCustomers() {
    return _customersCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomerEntity.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

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

  Future<void> saveCustomer(CustomerEntity customer) async {
    try {
      if (customer.id == null) {
        await _customersCollection.add(customer.toMap());
      } else {
        await _customersCollection.doc(customer.id).set(customer.toMap());
      }
    } catch (e) {
      throw Exception('Erro ao salvar cliente: $e');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _customersCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar cliente: $e');
    }
  }

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