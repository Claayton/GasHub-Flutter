import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gashub_flutter/cubit/orders/orders_cubit.dart';
import 'package:gashub_flutter/cubit/orders/orders_state.dart';
import 'package:gashub_flutter/models/order_entity.dart';
import 'package:gashub_flutter/utils/formatters.dart';
import 'package:gashub_flutter/widgets/order_card.dart';

class PendingScreen extends StatefulWidget {
  const PendingScreen({super.key});

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  String? _processandoPagamentoId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  void _loadOrders() {
    if (mounted) {
      context.read<OrdersCubit>().loadPendingOrders();
    }
  }

  void _handleMarkAsPaid(OrderEntity pedido) {
    setState(() {
      _processandoPagamentoId = pedido.id;
    });

    // Captura o context atual antes do async gap
    final currentContext = context;
    
    showDialog(
      context: currentContext,
      builder: (context) => AlertDialog(
        title: const Text('Marcar como Pago'),
        content: Text(
          'Tem certeza que deseja marcar o pedido de ${pedido.customerName} como pago?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) {
                setState(() {
                  _processandoPagamentoId = null;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => _confirmMarkAsPaid(pedido, currentContext),
            child: const Text('Marcar como Pago'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmMarkAsPaid(OrderEntity pedido, BuildContext dialogContext) async {
    Navigator.pop(dialogContext);
    
    try {
      await context.read<OrdersCubit>().marcarComoPago(pedido.id);
      
      // Usar WidgetsBinding para garantir que executa no frame certo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pedido de ${pedido.customerName} marcado como pago!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _processandoPagamentoId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f7fa),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return _buildLoadingState();
          }

          if (state is OrdersError) {
            return _buildErrorState(state.message);
          }

          if (state is OrdersLoaded) {
            return _buildContentState(state.orders);
          }

          if (state is OrdersEmpty) {
            return _buildEmptyState();
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF007bff))),
          SizedBox(height: 16),
          Text(
            'Carregando fiados...',
            style: TextStyle(color: Color(0xFF333333)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Erro ao carregar pedidos',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFFb94a48),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFeeeeee), width: 1)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0 pedidos fiados',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                'Total: R\$0,00',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Nenhum pedido fiado encontrado',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentState(List<OrderEntity> fiadoPedidos) {
    final total = fiadoPedidos.fold(0.0, (sum, order) => sum + order.pendingValue);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFeeeeee), width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${fiadoPedidos.length} pedidos fiados',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                'Total: R\$${formatarValor(total)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: fiadoPedidos.length,
              itemBuilder: (context, index) {
                final pedido = fiadoPedidos[index];
                final isProcessing = _processandoPagamentoId == pedido.id;
                
                return OrderCard(
                  order: pedido,
                  showActions: true,
                  onPay: isProcessing ? null : () => _handleMarkAsPaid(pedido),
                  onEdit: null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}