import 'package:bloc/bloc.dart';
import 'package:gashub_flutter/repositories/customer_repository.dart';
import 'package:gashub_flutter/models/customer_entity.dart';
import 'package:gashub_flutter/cubit/customers/customers_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _repository;

  CustomerCubit(this._repository) : super(CustomerInitial());

  Future<void> saveCustomer(CustomerEntity customer) async {
    emit(CustomerLoading());
    
    try {
      if (customer.name.isEmpty) {
        throw Exception('Nome é obrigatório');
      }
      
      if (customer.phone.isEmpty) {
        throw Exception('Telefone é obrigatório');
      }

      await _repository.saveCustomer(customer);
      
      emit(CustomerSuccess('Cliente salvo com sucesso!'));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> loadCustomers() async {
    emit(CustomerLoading());
    try {
      final customers = await _repository.getCustomers();
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> searchCustomers(String query) async {
    try {
      final customers = await _repository.searchCustomersByName(query);
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}