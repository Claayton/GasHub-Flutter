import 'package:flutter/material.dart';
import 'package:gashub_flutter/cubit/dashboard/dashboard_cubit.dart';

@immutable
abstract class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardMetrics metrics;

  const DashboardLoaded({
    required this.metrics,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardLoaded &&
        other.metrics == metrics;
  }

  @override
  int get hashCode => metrics.hashCode;
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

