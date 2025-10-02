import 'package:google_maps_webservice/places.dart';

/// Lê a chave de API do Google Maps via `--dart-define`
final apiKey = const String.fromEnvironment('GOOGLE_MAPS_API_KEY');

/// Verifica se a variável de ambiente foi passada
void checkEnvironmentVariables() {
  final missingVars = <String>[];

  if (apiKey.isEmpty) {
    missingVars.add('GOOGLE_MAPS_API_KEY');
  }

  if (missingVars.isNotEmpty) {
    throw Exception(
      'Variáveis de ambiente Google Maps não definidas: ${missingVars.join(', ')}\n'
      'Execute com: flutter run --dart-define=GOOGLE_MAPS_API_KEY=sua_chave ...'
    );
  }
}

class PlaceService {
  final GoogleMapsPlaces _places;

  PlaceService() : _places = GoogleMapsPlaces(apiKey: apiKey);

  /// Busca sugestões de endereços pelo texto digitado
  Future<List<Prediction>> getAutocomplete(String input) async {

    final response = await _places.autocomplete(
      input,
      language: 'pt',
      types: ['geocode'], // só endereços
    );

    if (response.isOkay) {
      return response.predictions;
    } else {
      throw Exception('Erro no autocomplete: ${response.errorMessage}');
    }
  }

  /// Busca detalhes de um lugar pelo placeId
  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    final response = await _places.getDetailsByPlaceId(placeId);

    if (response.isOkay) {
      return response.result;
    } else {
      throw Exception('Erro ao buscar detalhes: ${response.errorMessage}');
    }
  }
}
