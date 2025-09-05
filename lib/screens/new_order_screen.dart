import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasbub_flutter/cubit/orders/orders_cubit.dart';
import 'package:gasbub_flutter/models/order_entity.dart';
import 'package:gasbub_flutter/models/product_entity.dart';
import 'package:gasbub_flutter/screens/main_navigation_screen.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  PaymentMethods _selectedPaymentMethod = PaymentMethods.dinheiro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pedido'),
        backgroundColor: const Color(0xFF1e40af),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Campo Nome do Cliente
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Cliente *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o nome do cliente';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Campo Endereço
              TextFormField(
                controller: _customerAddressController,
                decoration: const InputDecoration(
                  labelText: 'Endereço *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o endereço';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Seleção de Método de Pagamento
              DropdownButtonFormField<PaymentMethods>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Método de Pagamento *',
                  border: OutlineInputBorder(),
                ),
                items: PaymentMethods.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(_getPaymentMethodText(method)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Botão para adicionar
              ElevatedButton(
                onPressed: _createOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1e40af),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Criar Pedido',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createOrder() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newOrder = OrderEntity(
          id: '', // Firebase vai gerar
          customerName: _customerNameController.text,
          customerAddress: _customerAddressController.text,
          products: [
            ProductEntity(
              id: '1', 
              name: 'Gás P13', 
              price: 85.0, 
              description: 'Gás P13', 
              stockQuantity: 10
            )
          ],
          orderDateTime: DateTime.now(),
          paymentMethod: _selectedPaymentMethod,
          dueDate: _selectedPaymentMethod == PaymentMethods.fiado 
              ? DateTime.now().add(const Duration(days: 30))
              : DateTime.now(),
          status: OrderStatus.pending,
          pendingValue: _selectedPaymentMethod == PaymentMethods.fiado ? 85.0 : 0,
          totalValue: 85.0,
          userId: 'user-id-temporario', // ← TEMPORÁRIO
        );

        // Usar o OrdersCubit para criar o pedido
        await context.read<OrdersCubit>().createOrder(newOrder);
        
        // Voltar para tela anterior
        final mainState = context.findAncestorStateOfType<MainNavigationScreenState>();
            mainState?.changeTab(0); // 1 = índice do Novo Pedido
        
      } catch (e) {
        // Mostrar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar pedido: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _getPaymentMethodText(PaymentMethods method) {
    switch (method) {
      case PaymentMethods.pix: return 'PIX';
      case PaymentMethods.debito: return 'Débito';
      case PaymentMethods.credito: return 'Crédito';
      case PaymentMethods.dinheiro: return 'Dinheiro';
      case PaymentMethods.fiado: return 'Fiado';
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerAddressController.dispose();
    super.dispose();
  }
}