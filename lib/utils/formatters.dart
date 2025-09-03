String formatarValor(double valor) {
  return valor.toStringAsFixed(2).replaceAll('.', ',');
}

String formatarData(DateTime data) {
  return '${data.day}/${data.month}/${data.year}';
}