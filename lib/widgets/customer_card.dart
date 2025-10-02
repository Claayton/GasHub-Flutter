import 'package:flutter/material.dart';
import 'package:gashub_flutter/models/customer_entity.dart';

class CustomerCard extends StatelessWidget {
  final CustomerEntity customer;
  final VoidCallback? onTap;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onEdit;

  const CustomerCard({
    super.key, 
    required this.customer, 
    this.onTap,
    this.onWhatsApp,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Cor base baseada no status de fiado
    Color statusColor = customer.allowsCredit
        ? const Color(0xFF10B981) // Verde para "Permite fiado"
        : const Color(0xFF6B7280); // Cinza para "Não permite fiado"

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06), 
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header com status de fiado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Color.lerp(null, statusColor, 0.08)!,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status de fiado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    customer.allowsCredit ? 'PERMITE FIADO' : 'SEM FIADO',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Avatar com inicial do nome
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getAvatarColor(customer.name),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(customer.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                    _capitalizeFirstLetter(customer.name),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Telefone
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          customer.phone,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Endereço
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${customer.address.street}, ${customer.address.number} - ${customer.address.neighborhood}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Informações adicionais em linha
                  Row(
                    children: [
                      // CPF (se existir)
                      if (customer.cpf != null && customer.cpf!.isNotEmpty) ...[
                        _InfoChip(
                          icon: Icons.badge,
                          text: 'CPF: ${customer.cpf}',
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 6),
                      ],
                      
                      // Casa própria (se informado)
                      if (customer.hasHisOwnHouse != null) ...[
                        _InfoChip(
                          icon: Icons.home,
                          text: customer.hasHisOwnHouse! ? 'Casa Própria' : 'Alugada',
                          color: customer.hasHisOwnHouse! ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Botões de ação
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botão WhatsApp
                OutlinedButton(
                  onPressed: onWhatsApp,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF25D366),
                    side: const BorderSide(color: Color(0xFF25D366)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat, size: 14),
                      SizedBox(width: 4),
                      Text('WhatsApp', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                
                // Botão Editar
                ElevatedButton(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 14),
                      SizedBox(width: 4),
                      Text('Editar', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final names = name.split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFFEF4444), // Vermelho
      const Color(0xFF10B981), // Verde
      const Color(0xFF3B82F6), // Azul
      const Color(0xFFF59E0B), // Laranja
      const Color(0xFF8B5CF6), // Roxo
    ];
    final index = name.length % colors.length;
    return colors[index];
  }
}

// Widget auxiliar para os chips de informação (MANTIDO do OrderCard)
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
        color: Color.fromRGBO(0, 0, 0, 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.2),),
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