import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gashub_flutter/cubit/customers/customers_cubit.dart';
import 'package:gashub_flutter/cubit/customers/customers_state.dart';
import 'package:gashub_flutter/models/customer_entity.dart';
import 'package:gashub_flutter/widgets/customer_card.dart';
import 'package:gashub_flutter/screens/new_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showCreditOnly = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Carrega os clientes ao iniciar a tela
    context.read<CustomerCubit>().loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: const Color(0xFF1e40af),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra de busca e filtros
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Barra de busca
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome ou telefone...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              context.read<CustomerCubit>().loadCustomers();
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    if (value.length >= 2) {
                      context.read<CustomerCubit>().searchCustomers(value);
                    } else if (value.isEmpty) {
                      context.read<CustomerCubit>().loadCustomers();
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Filtro de fiado
                Row(
                  children: [
                    Switch(
                      value: _showCreditOnly,
                      onChanged: (value) => setState(() => _showCreditOnly = value),
                      thumbColor: const WidgetStatePropertyAll(Color(0xFF10B981)),
                      // se quiser track sem opacity:
                      trackColor: const WidgetStatePropertyAll(Color(0xFF10B981)),
                    ),
                    const SizedBox(width: 8),
                    const Text('Mostrar só clientes que permitem fiado'),
                  ],
                )
              ],
            ),
          ),

          // Lista de clientes
          Expanded(
            child: BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CustomerError) {
                  return Center(
                    child: Text('Erro: ${state.error}'),
                  );
                }

                if (state is CustomersLoaded) {
                  final customers = _filterCustomers(state.customers);
                  
                  if (customers.isEmpty) {
                    return const Center(
                      child: Text('Nenhum cliente encontrado'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return CustomerCard(
                        customer: customer,
                        onTap: () => _showCustomerDetails(context, customer),
                        onWhatsApp: () => _openWhatsApp(customer),
                        onEdit: () => _editCustomer(context, customer),
                      );
                    },
                  );
                }

                return const Center(child: Text('Nenhum cliente cadastrado'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCustomerForm(context),
        backgroundColor: const Color(0xFF1e40af),
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  List<CustomerEntity> _filterCustomers(List<CustomerEntity> customers) {
    var filtered = customers;

    // Filtro por busca
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((customer) {
        return customer.name.toLowerCase().contains(query) ||
            customer.phone.contains(query);
      }).toList();
    }

    // Filtro por fiado
    if (_showCreditOnly) {
      filtered = filtered.where((customer) => customer.allowsCredit).toList();
    }

    return filtered;
  }

  void _navigateToCustomerForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewCustomerScreen(),
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, CustomerEntity customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📞 ${customer.phone}'),
              const SizedBox(height: 8),
              Text('📍 ${customer.address.street}, ${customer.address.number}'),
              Text('🏠 ${customer.address.neighborhood}'),
              if (customer.address.city != null) Text('🏙️ ${customer.address.city!}'),
              if (customer.address.state != null) Text('🏛️ ${customer.address.state!}'),
              if (customer.cpf != null) Text('📋 CPF: ${customer.cpf!}'),
              const SizedBox(height: 12),
              Text('💰 ${customer.allowsCredit ? 'Permite fiado' : 'Não permite fiado'}'),
              if (customer.hasHisOwnHouse != null)
                Text('🏠 ${customer.hasHisOwnHouse! ? 'Casa própria' : 'Alugada'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _openWhatsApp(CustomerEntity customer) {
    // Implementar abertura do WhatsApp
    final phone = customer.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = 'https://wa.me/55$phone';
    // Usar url_launcher para abrir o link
    print('Abrir WhatsApp: $url');
  }

  void _editCustomer(BuildContext context, CustomerEntity customer) {
    // Navegar para tela de edição
    print('Editar cliente: ${customer.name}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}