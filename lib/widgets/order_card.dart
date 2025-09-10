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
    final isFiado = order.paymentMethod == PaymentMethods.fiado;

    // Cores de status
    Color statusColor = order.status == OrderStatus.confirmed
        ? const Color(0xFF10B981) // Verde mais moderno
        : const Color(0xFFF59E0B); // Laranja mais suave

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header com status e valor
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Valor
                Text(
                  'R\$${formatarValor(valorExibir)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo principal
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do cliente
                  Text(
                    order.customerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Endereço
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.customerAddress,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Produtos
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: order.products.map((product) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${product.name}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Informações adicionais
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      // Método de pagamento
                      _InfoChip(
                        icon: Icons.payment,
                        text: _getPaymentMethodText(order.paymentMethod),
                        color: Colors.blue,
                      ),

                      // Data do pedido
                      _InfoChip(
                        icon: Icons.calendar_today,
                        text: formatarData(order.orderDateTime),
                        color: Colors.grey,
                      ),

                      // Vencimento (se for fiado)
                      if (isFiado)
                        _InfoChip(
                          icon: Icons.event,
                          text: 'Vence: ${formatarData(order.dueDate)}',
                          color: const Color(0xFFEF4444),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Botões de ação (se necessário)
          if (showActions) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botão Editar
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Botão Pagar
                  ElevatedButton.icon(
                    onPressed: onPay,
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('Marcar Pago'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'PENDENTE';
      case OrderStatus.confirmed:
        return 'CONFIRMADO';
    }
  }

  String _getPaymentMethodText(PaymentMethods method) {
    switch (method) {
      case PaymentMethods.pix:
        return 'PIX';
      case PaymentMethods.debito:
        return 'DÉBITO';
      case PaymentMethods.credito:
        return 'CRÉDITO';
      case PaymentMethods.dinheiro:
        return 'DINHEIRO';
      case PaymentMethods.fiado:
        return 'FIADO';
    }
  }
}

// Widget auxiliar para os chips de informação
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}