// customer_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:gashub_flutter/repositories/customer_repository.dart';
import 'package:gashub_flutter/models/customer_entity.dart';
import 'package:gashub_flutter/cubit/customers/customers_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _repository;

  CustomerCubit(this._repository) : super(CustomerInitial());

  // Método equivalente ao que você faria num Service no RN
  Future<void> saveCustomer(CustomerEntity customer) async {
    emit(CustomerLoading());
    
    try {
      // ✅ Validações (lógica de negócio que ficaria no Service)
      if (customer.name.isEmpty) {
        throw Exception('Nome é obrigatório');
      }
      
      if (customer.phone.isEmpty) {
        throw Exception('Telefone é obrigatório');
      }

      // ✅ Chama o Repository (como você faria com uma API no RN)
      await _repository.saveCustomer(customer);
      
      emit(CustomerSuccess('Cliente salvo com sucesso!'));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  // Outros métodos que você precisaria...
}