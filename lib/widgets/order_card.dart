import 'package:flutter/material.dart';
import 'package:gasbub_flutter/models/order_entity.dart';
import 'package:gasbub_flutter/utils/formatters.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isFiado = order.paymentMethod == PaymentMethods.fiado;
    final valorExibir = order.pendingValue > 0 ? order.pendingValue : order.totalValue;
    final statusColor = isFiado ? const Color(0xFFd9534f) : const Color(0xFF28a745);
    final statusIcon = isFiado ? '⏰' : '✅';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com nome e badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.customerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFiado ? const Color(0xFFf0ad4e) : const Color(0xFF5cb85c),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPaymentMethodText(order.paymentMethod),
                      style: const TextStyle(
                        color: Colors.white,
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
                  '• ${product.name} (1 un.)', // Ajuste conforme seu model
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                )).toList(),
              ),

              const SizedBox(height: 4),

              // Endereço
              Text(
                order.customerAddress,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 6),

              // Valor com ícone de status
              Text(
                '$statusIcon Valor: R\$${formatarValor(valorExibir)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),

              // Se for fiado, mostra data de vencimento
              if (isFiado) ...[
                const SizedBox(height: 4),
                Text(
                  '📅 Vencimento: ${formatarData(order.dueDate)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFb94a48),
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
            ],
          ),
        ),
      ),
    );
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

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}