import 'package:gashub_flutter/models/customer_entity.dart';
import 'package:flutter/foundation.dart';


@immutable
abstract class CustomerState {}

class CustomerInitial extends CustomerState {}
class CustomerLoading extends CustomerState {}
class CustomerSuccess extends CustomerState {
  final String message;
  CustomerSuccess(this.message);
}
class CustomerError extends CustomerState {
  final String error;
  CustomerError(this.error);
}
class CustomersLoaded extends CustomerState {
  final List<CustomerEntity> customers;
  CustomersLoaded(this.customers);
}