import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gashub_flutter/cubit/dashboard/dashboard_cubit.dart';
import 'package:gashub_flutter/cubit/dashboard/dashboard_state.dart';
import 'package:gashub_flutter/utils/formatters.dart';
import 'package:gashub_flutter/models/order_entity.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PeriodFilter _selectedFilter = PeriodFilter.semana;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    final cubit = context.read<DashboardCubit>();
    final period = cubit.getPeriodFromFilter(_selectedFilter);
    cubit.loadDashboardMetrics(period);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f7fa),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDashboard();
        },
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            DashboardMetrics? metrics;

            if (state is DashboardLoaded) {
              metrics = state.metrics;
            }

            return CustomScrollView(
              slivers: [
                // Filtros temporais
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 15, left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FilterChip(
                          label: 'Hoje',
                          isSelected: _selectedFilter == PeriodFilter.hoje,
                          onTap: () {
                            setState(() => _selectedFilter = PeriodFilter.hoje);
                            _loadDashboard();
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Semana',
                          isSelected: _selectedFilter == PeriodFilter.semana,
                          onTap: () {
                            setState(() => _selectedFilter = PeriodFilter.semana);
                            _loadDashboard();
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Mês',
                          isSelected: _selectedFilter == PeriodFilter.mes,
                          onTap: () {
                            setState(() => _selectedFilter = PeriodFilter.mes);
                            _loadDashboard();
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Cards de métricas
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: metrics == null
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
                            children: [
                              _MetricCard(
                                icon: Icons.receipt,
                                value: metrics.totalPedidos.toString(),
                                label: 'Total Pedidos',
                                color: const Color(0xFF007bff),
                              ),
                              _MetricCard(
                                icon: Icons.attach_money,
                                value: 'R\$${formatarValor(metrics.totalValor)}',
                                label: 'Valor Total',
                                color: const Color(0xFF28a745),
                              ),
                              _MetricCard(
                                icon: Icons.pending_actions,
                                value: metrics.totalFiados.toString(),
                                label: 'Fiados',
                                color: const Color(0xFFffc107),
                              ),
                              _MetricCard(
                                icon: Icons.check_circle,
                                value: metrics.totalPagos.toString(),
                                label: 'Pagos',
                                color: const Color(0xFF17a2b8),
                              ),
                            ],
                          ),
                  ),
                ),

                // Métricas secundárias
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: metrics == null
                        ? const SizedBox.shrink()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _SecondaryMetric(
                                label: 'Média por Pedido',
                                value: 'R\$${formatarValor(metrics.mediaPedido)}',
                              ),
                              _SecondaryMetric(
                                label: 'Taxa de Conversão',
                                value: '${metrics.taxaConversao.toStringAsFixed(1)}%',
                              ),
                            ],
                          ),
                  ),
                ),

                // Gráficos placeholder
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📈 Visualização Gráfica',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Gráficos serão implementados aqui\n\n📊 Gráfico de vendas\n🥧 Distribuição de pagamentos',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Pedidos recentes
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '📋 Pedidos Recentes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),

                // Lista de pedidos
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (metrics == null) return const SizedBox.shrink();
                      final OrderEntity order = metrics.recentOrders[index];
                      return _OrderItemCard(order: order);
                    },
                    childCount: metrics?.recentOrders.length ?? 0,
                  ),
                ),

                // Espaço final
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Componente para os chips de filtro
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007bff) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF007bff) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Componente para os cards de métrica
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Componente para métricas secundárias
class _SecondaryMetric extends StatelessWidget {
  final String label;
  final String value;

  const _SecondaryMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Componente para itens da lista de pedidos
class _OrderItemCard extends StatelessWidget {
  final OrderEntity order;

  const _OrderItemCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final isFiado = order.paymentMethod == PaymentMethods.fiado;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 2, offset: Offset(0, 1))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isFiado ? const Color.fromRGBO(255, 193, 7, 0.2) : const Color.fromRGBO(40, 167, 69, 0.2),
          child: Icon(isFiado ? Icons.pending_actions : Icons.check_circle,
              size: 20, color: isFiado ? const Color(0xFFffc107) : const Color(0xFF28a745)),
        ),
        title: Text(order.customerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(
          'R\$${formatarValor(order.totalValue)} • ${_formatDate(order.orderDateTime)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          isFiado ? 'Fiado' : order.paymentMethod.name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isFiado ? const Color(0xFFffc107) : const Color(0xFF28a745),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
