// customer_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gashub_flutter/cubit/customers/customers_cubit.dart';
import 'package:gashub_flutter/cubit/customers/customers_state.dart';
import 'package:gashub_flutter/models/customer_entity.dart';
import 'package:gashub_flutter/models/customer_address_entity.dart';

class NewCustomerScreen extends StatefulWidget {
  const NewCustomerScreen({super.key});

  @override
  State<NewCustomerScreen> createState() => _NewCustomerScreenState();
}

class _NewCustomerScreenState extends State<NewCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controladores
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _complementController = TextEditingController();
  final _referencePointController = TextEditingController();

  // Estado do formulário
  bool _allowsCredit = false;
  bool? _hasHisOwnHouse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Cliente'),
        backgroundColor: const Color(0xFF1e40af),
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<CustomerCubit, CustomerState>(
        listener: (context, state) {
          if (state is CustomerSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
          
          if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Seção de Dados Pessoais
                  const Text(
                    'Dados Pessoais',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Nome é obrigatório' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefone *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Telefone é obrigatório' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _cpfController,
                    decoration: const InputDecoration(
                      labelText: 'CPF (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // Seção de Endereço
                  const Text(
                    'Endereço',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _streetController,
                          decoration: const InputDecoration(
                            labelText: 'Rua *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Rua é obrigatória' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _numberController,
                          decoration: const InputDecoration(
                            labelText: 'Nº *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Número é obrigatório' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _neighborhoodController,
                    decoration: const InputDecoration(
                      labelText: 'Bairro *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Bairro é obrigatório' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'Cidade (opcional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _stateController,
                          decoration: const InputDecoration(
                            labelText: 'UF (opcional)',
                            border: OutlineInputBorder(),
                          ),
                          maxLength: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _zipCodeController,
                    decoration: const InputDecoration(
                      labelText: 'CEP (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _complementController,
                    decoration: const InputDecoration(
                      labelText: 'Complemento (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _referencePointController,
                    decoration: const InputDecoration(
                      labelText: 'Ponto de referência (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Seção de Informações Adicionais
                  const Text(
                    'Informações Adicionais',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Permitir fiado'),
                    value: _allowsCredit,
                    onChanged: (value) => setState(() => _allowsCredit = value),
                  ),

                  SwitchListTile(
                    title: const Text('Tem casa própria'),
                    subtitle: const Text('(opcional)'),
                    value: _hasHisOwnHouse ?? false,
                    onChanged: (value) => setState(() => _hasHisOwnHouse = value),
                  ),
                  const SizedBox(height: 24),

                  // Botão Salvar
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _saveCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1e40af),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Salvar Cliente',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final customer = CustomerEntity(
        id: null,
        name: _nameController.text,
        phone: _phoneController.text,
        address: Address(
          street: _streetController.text,
          number: _numberController.text,
          neighborhood: _neighborhoodController.text,
          city: _cityController.text.isNotEmpty ? _cityController.text : null,
          state: _stateController.text.isNotEmpty ? _stateController.text : null,
          zipCode: _zipCodeController.text.isNotEmpty ? _zipCodeController.text : null,
          complement: _complementController.text.isNotEmpty ? _complementController.text : null,
          referencePoint: _referencePointController.text.isNotEmpty ? _referencePointController.text : null,
        ),
        cpf: _cpfController.text.isNotEmpty ? _cpfController.text : null,
        hasHisOwnHouse: _hasHisOwnHouse,
        allowsCredit: _allowsCredit,
        registrationDate: DateTime.now(),
      );

      context.read<CustomerCubit>().saveCustomer(customer);
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _complementController.dispose();
    _referencePointController.dispose();
    super.dispose();
  }
}