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
        ? const Color(0xFF10B981) // Verde para "Recebido"
        : const Color(0xFFF59E0B); // Laranja para "À Receber"

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header com status e valor
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    order.status == OrderStatus.confirmed ? 'RECEBIDO' : 'À RECEBER',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Valor
                Text(
                  'R\$${formatarValor(valorExibir)}',
                  style: TextStyle(
                    fontSize: 16,
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do cliente (primeira letra maiúscula)
                  Text(
                    _capitalizeFirstLetter(order.customerName),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Endereço
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.customerAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Produtos (mais compacto)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: order.products.map((product) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '• ${product.name}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 10),

                  // Informações em linha (tags)
                  Row(
                    children: [
                      // Método de pagamento
                      _InfoChip(
                        icon: Icons.payment,
                        text: _getPaymentMethodText(order.paymentMethod),
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 6),
                      
                      // Data do pedido (formato BR)
                      _InfoChip(
                        icon: Icons.calendar_today,
                        text: _formatDateBr(order.orderDateTime),
                        color: Colors.grey,
                      ),
                      
                      // Vencimento (se for fiado)
                      if (isFiado) ...[
                        const SizedBox(width: 6),
                        _InfoChip(
                          icon: Icons.event,
                          text: 'Vence: ${_formatDateBr(order.dueDate)}',
                          color: const Color(0xFFEF4444),
                        ),
                      ],
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
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botão Editar
                  OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Editar', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  
                  // Botão Pagar
                  ElevatedButton(
                    onPressed: onPay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Pagar', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  String _formatDateBr(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}