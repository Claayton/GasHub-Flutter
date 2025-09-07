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

  // Produtos disponíveis (hardcoded por enquanto)
  final List<ProductEntity> _availableProducts = [
    ProductEntity(
      id: '1',
      name: 'Gás P13',
      price: 120.0,
      description: 'Botijão de Gás P13',
      stockQuantity: 100,
    ),
    ProductEntity(
      id: '2',
      name: 'Água Mineral 20L',
      price: 18.0,
      description: 'Garrafão de Água 20L',
      stockQuantity: 50,
    ),
  ];

  // Estado do formulário
  PaymentMethods _selectedPaymentMethod = PaymentMethods.dinheiro;
  ProductEntity? _selectedProduct;
  int _quantity = 1;
  final List<Map<String, dynamic>> _selectedProducts = []; // {product, quantity, price}
  double _totalValue = 0.0;

  // Campos específicos para fiado
  DateTime? _dueDate;
  double _pendingValue = 0.0;

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

              // Seleção de Produto
              DropdownButtonFormField<ProductEntity>(
                value: _selectedProduct,
                decoration: const InputDecoration(
                  labelText: 'Selecionar Produto *',
                  border: OutlineInputBorder(),
                ),
                items: _availableProducts.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Text('${product.name} - R\$${product.price.toStringAsFixed(2)}'),
                  );
                }).toList(),
                onChanged: (product) {
                  setState(() {
                    _selectedProduct = product;
                  });
                },
                validator: (value) {
                  if (value == null && _selectedProducts.isEmpty) {
                    return 'Selecione um produto';
                  }
                  return null;
                },
              ),

              if (_selectedProduct != null) ...[
                const SizedBox(height: 16),
                // Quantidade do produto
                Row(
                  children: [
                    const Text('Quantidade:'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() => _quantity--);
                        }
                      },
                    ),
                    Text(_quantity.toString()),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() => _quantity++);
                      },
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _addProduct,
                      child: const Text('Adicionar'),
                    ),
                  ],
                ),
              ],

              // Lista de produtos selecionados
              if (_selectedProducts.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Produtos no pedido:', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._selectedProducts.map((item) {
                  final product = item['product'] as ProductEntity;
                  final quantity = item['quantity'] as int;
                  final price = item['price'] as double;
                  return ListTile(
                    title: Text('${product.name} x$quantity'),
                    subtitle: Text('R\$${(price * quantity).toStringAsFixed(2)} (R\$${price.toStringAsFixed(2)} un.)'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editProduct(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeProduct(item),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                Text(
                  'Total: R\$${_totalValue.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],

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
                    if (_selectedPaymentMethod != PaymentMethods.fiado) {
                      _dueDate = null;
                      _pendingValue = 0.0;
                    } else {
                      _pendingValue = _totalValue;
                    }
                  });
                },
              ),

              if (_selectedPaymentMethod == PaymentMethods.fiado) ...[
                const SizedBox(height: 16),
                ListTile(
                  title: Text(_dueDate == null
                      ? 'Selecionar data de vencimento'
                      : 'Vencimento: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (selectedDate != null) {
                      setState(() => _dueDate = selectedDate);
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Valor pendente: R\$${_pendingValue.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Botão para criar pedido
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

  void _addProduct() {
    if (_selectedProduct != null && _quantity > 0) {
      setState(() {
        _selectedProducts.add({
          'product': _selectedProduct!,
          'quantity': _quantity,
          'price': _selectedProduct!.price,
        });
        _totalValue += _selectedProduct!.price * _quantity;
        _selectedProduct = null;
        _quantity = 1;
        if (_selectedPaymentMethod == PaymentMethods.fiado) {
          _pendingValue = _totalValue;
        }
      });
    }
  }

  void _editProduct(Map<String, dynamic> item) {
    final product = item['product'] as ProductEntity;
    final quantity = item['quantity'] as int;
    final price = item['price'] as double;

    final quantityController = TextEditingController(text: quantity.toString());
    final priceController = TextEditingController(text: price.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Editar ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantidade'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Preço Unitário'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final newQuantity = int.tryParse(quantityController.text) ?? quantity;
              final newPrice = double.tryParse(priceController.text) ?? price;

              setState(() {
                _totalValue -= price * quantity;
                item['quantity'] = newQuantity;
                item['price'] = newPrice;
                _totalValue += newPrice * newQuantity;
                if (_selectedPaymentMethod == PaymentMethods.fiado) {
                  _pendingValue = _totalValue;
                }
              });

              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _removeProduct(Map<String, dynamic> item) {
    setState(() {
      final product = item['product'] as ProductEntity;
      final quantity = item['quantity'] as int;
      final price = item['price'] as double;
      _totalValue -= price * quantity;
      _selectedProducts.remove(item);
      if (_selectedPaymentMethod == PaymentMethods.fiado) {
        _pendingValue = _totalValue;
      }
    });
  }

  void _createOrder() async {
    if (_formKey.currentState!.validate() && _selectedProducts.isNotEmpty) {
      try {
        final products = _selectedProducts.expand((item) {
          final product = item['product'] as ProductEntity;
          final quantity = item['quantity'] as int;
          final price = item['price'] as double;
          final customProduct = ProductEntity(
            id: product.id,
            name: product.name,
            description: product.description,
            stockQuantity: product.stockQuantity,
            price: price,
          );
          return List.generate(quantity, (_) => customProduct);
        }).toList();

        final newOrder = OrderEntity(
          id: '',
          customerName: _customerNameController.text,
          customerAddress: _customerAddressController.text,
          products: products,
          orderDateTime: DateTime.now(),
          paymentMethod: _selectedPaymentMethod,
          dueDate: _selectedPaymentMethod == PaymentMethods.fiado
              ? _dueDate ?? DateTime.now().add(const Duration(days: 30))
              : DateTime.now(),
          status: OrderStatus.pending,
          pendingValue: _selectedPaymentMethod == PaymentMethods.fiado ? _pendingValue : 0,
          totalValue: _totalValue,
          userId: 'user-id-temporario',
        );

        await context.read<OrdersCubit>().createOrder(newOrder);

        final mainState = context.findAncestorStateOfType<MainNavigationScreenState>();
        mainState?.changeTab(0);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar pedido: ${e.toString()}')),
        );
      }
    } else if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um produto ao pedido')),
      );
    }
  }

  String _getPaymentMethodText(PaymentMethods method) {
    switch (method) {
      case PaymentMethods.pix:
        return 'PIX';
      case PaymentMethods.debito:
        return 'Débito';
      case PaymentMethods.credito:
        return 'Crédito';
      case PaymentMethods.dinheiro:
        return 'Dinheiro';
      case PaymentMethods.fiado:
        return 'Fiado';
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerAddressController.dispose();
    super.dispose();
  }
}
