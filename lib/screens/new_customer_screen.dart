// customer_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gashub_flutter/cubit/customers/customers_cubit.dart';
import 'package:gashub_flutter/cubit/customers/customers_state.dart';
import 'package:gashub_flutter/cubit/place/place_cubit.dart';
import 'package:gashub_flutter/cubit/place/place_state.dart';
import 'package:gashub_flutter/models/customer_entity.dart';
import 'package:gashub_flutter/models/customer_address_entity.dart';
import 'package:google_maps_webservice/places.dart';


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

  // FocusNode para o campo de rua (autocomplete)
  final _streetFocusNode = FocusNode();
  bool _showAddressSuggestions = false;

  // Estado do formulário
  bool _allowsCredit = false;
  bool? _hasHisOwnHouse;

  @override
  void initState() {
    super.initState();
    _streetFocusNode.addListener(_onStreetFocusChanged);
  }

  void _onStreetFocusChanged() {
    setState(() {
      _showAddressSuggestions = _streetFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Cliente'),
        backgroundColor: const Color(0xFF1e40af),
        foregroundColor: Colors.white,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CustomerCubit, CustomerState>(
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
                setState(() => _isSubmitting = false);
              }
            },
          ),
          BlocListener<PlaceCubit, PlaceState>(
            listener: (context, state) {
              if (state is PlaceDetailsLoaded) {
                _fillAddressFromPlaceDetails(state.placeDetails);
              }
            },
          ),
        ],
        child: Padding(
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

                // Campo de Rua com Autocomplete
                Column(
                  children: [
                    TextFormField(
                      controller: _streetController,
                      focusNode: _streetFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Rua *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        if (value.length > 2) {
                          context.read<PlaceCubit>().fetchSuggestions(value);
                        }
                      },
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Rua é obrigatória' : null,
                    ),
                    
                    // Sugestões de endereço
                    BlocBuilder<PlaceCubit, PlaceState>(
                      builder: (context, state) {
                        if (!_showAddressSuggestions || _streetController.text.isEmpty) {
                          return const SizedBox();
                        }
                        
                        if (state is PlaceLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          );
                        }
                        
                        if (state is PlaceSuggestionsLoaded) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.1), // r,g,b,opacity
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.only(top: 4),
                            child: Column(
                              children: state.suggestions.map((suggestion) {
                                return ListTile(
                                  title: Text(
                                    suggestion.description ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  dense: true,
                                  onTap: () {
                                    final placeId = suggestion.placeId ?? '';
                                    if (placeId.isNotEmpty) {
                                      context.read<PlaceCubit>().fetchPlaceDetails(placeId);
                                    }
                                    _streetController.text = suggestion.description ?? '';
                                    setState(() => _showAddressSuggestions = false);
                                    _streetFocusNode.unfocus();
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        }
                        
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Número
                TextFormField(
                  controller: _numberController,
                  decoration: const InputDecoration(
                    labelText: 'Nº *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Número é obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // Bairro
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

                // Cidade e Estado
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'Cidade *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Cidade é obrigatória' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                          labelText: 'UF *',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 2,
                        validator: (value) => value == null || value.isEmpty ? 'UF é obrigatória' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // CEP
                TextFormField(
                  controller: _zipCodeController,
                  decoration: const InputDecoration(
                    labelText: 'CEP (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Complemento
                TextFormField(
                  controller: _complementController,
                  decoration: const InputDecoration(
                    labelText: 'Complemento (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Ponto de referência
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
        ),
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
          city: _cityController.text,
          state: _stateController.text,
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
    }
  }

  void _fillAddressFromPlaceDetails(PlaceDetails details) {
    try {
      final addressComponents = details.addressComponents;

      // Função auxiliar para extrair componentes
      String extractComponent(String type) {
        final component = addressComponents.firstWhere(
          (comp) => comp.types.contains(type),
          orElse: () => AddressComponent(longName: '', shortName: '', types: []),
        );
        return component.longName;
      }

      String extractStateComponent(String type) {
        final component = addressComponents.firstWhere(
          (comp) => comp.types.contains(type),
          orElse: () => AddressComponent(longName: '', shortName: '', types: []),
        );
        return component.shortName;
      }

      // Preencher os campos automaticamente
      _streetController.text = extractComponent('route');
      _numberController.text = extractComponent('street_number');
      _neighborhoodController.text = [
        extractComponent('sublocality'),
        extractComponent('sublocality_level_1'),
        extractComponent('neighborhood'),
      ].firstWhere((value) => value.isNotEmpty, orElse: () => '');
      _cityController.text = extractComponent('administrative_area_level_2');
      _stateController.text = extractStateComponent('administrative_area_level_1');
      _zipCodeController.text = extractComponent('postal_code');

      // Forçar validação dos campos obrigatórios
      _formKey.currentState?.validate();
    } catch (e) {
      print('Erro ao preencher endereço: $e');
    }
  }

  @override
  void dispose() {
    _streetFocusNode.removeListener(_onStreetFocusChanged);
    _streetFocusNode.dispose();
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