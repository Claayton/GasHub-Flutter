import 'package:bloc/bloc.dart';
import 'place_state.dart';
import 'package:gashub_flutter/services/place_service.dart';

class PlaceCubit extends Cubit<PlaceState> {
  final PlaceService _placeService;

  PlaceCubit(this._placeService) : super(PlaceInitial());

  /// Busca sugestões de endereço pelo input do usuário
  Future<void> fetchSuggestions(String input) async {

    if (input.isEmpty) {
      emit(PlaceInitial());
      return;
    }

    emit(PlaceLoading());
    try {
      final suggestions = await _placeService.getAutocomplete(input);
      emit(PlaceSuggestionsLoaded(suggestions));
    } catch (e) {
      emit(PlaceError(e.toString()));
    }
  }

  /// Busca detalhes de um place selecionado
  Future<void> fetchPlaceDetails(String placeId) async {
    emit(PlaceLoading());
    try {
      final details = await _placeService.getPlaceDetails(placeId); 
      // agora `details` já é um PlaceDetails
      emit(PlaceDetailsLoaded(details));
    } catch (e) {
      emit(PlaceError(e.toString()));
    }
  }

  Future<Map<String, double>?> geocodeAddress(String address) async {
    try {
      final response = await _placeService.searchByText(address);

      if (response.results.isNotEmpty) {
        final location = response.results.first.geometry!.location;
        return {
          'lat': location.lat,
          'lng': location.lng,
        };
      }
    } catch (e) {
      print('Erro no geocoding: $e');
    }
    return null;
  }
}
