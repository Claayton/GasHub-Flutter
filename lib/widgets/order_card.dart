import 'package:flutter/material.dart';
import 'package:gasbub_flutter/models/order_entity.dart';
import 'package:gasbub_flutter/utils/formatters.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onTap;
  final bool showActions;
  final VoidCallback? onPay;
  final VoidCallback? onEdit;

  const OrderCard({
    super.key, 
    required this.order, 
    this.onTap,
    this.showActions = false,
    this.onPay,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final valorExibir = order.pendingValue > 0 ? order.pendingValue : order.totalValue;

    // Cores de status
    Color statusColor = order.status == OrderStatus.confirmed
        ? const Color(0xFF28A745) // Verde
        : const Color(0xFFFF6B35); // Laranja

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Conteúdo clicável
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Borda lateral colorida
                  Container(
                    width: 6,
                    height: 112,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        bottomLeft: Radius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Conteúdo do card
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cabeçalho
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.customerName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(0, 0, 0, 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getPaymentMethodText(order.paymentMethod),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Lista de produtos
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: order.products.map((product) => Text(
                            '• ${product.name} (1 un.)',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 6),
                        // Endereço
                        Text(
                          order.customerAddress,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Valor
                        Text(
                          'Valor: R\$${formatarValor(valorExibir)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                        // Se for fiado, mostra vencimento
                        if (order.paymentMethod == PaymentMethods.fiado) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Vencimento: ${formatarData(order.dueDate)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB94A48),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        // Data do pedido
                        Text(
                          'Pedido em: ${_formatDateTime(order.orderDateTime)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        // Botões de ação dentro do card
                        if (showActions) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Botão Editar
                              ElevatedButton(
                                onPressed: onEdit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, size: 16),
                                    SizedBox(width: 4),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Botão Pagar
                              ElevatedButton(
                                onPressed: onPay,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF28A745),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.payment, size: 16),
                                    SizedBox(width: 4),
                                    Text('Pagar'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
        return 'À prazo';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
