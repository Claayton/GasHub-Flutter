import 'package:equatable/equatable.dart';
import 'package:google_maps_webservice/places.dart';

abstract class PlaceState extends Equatable {
  const PlaceState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial, nada carregado ainda
class PlaceInitial extends PlaceState {}

/// Estado de carregamento
class PlaceLoading extends PlaceState {}

/// Estado com sugestões carregadas
class PlaceSuggestionsLoaded extends PlaceState {
  final List<Prediction> suggestions;

  const PlaceSuggestionsLoaded(this.suggestions);

  @override
  List<Object?> get props => [suggestions];
}

/// Estado com detalhes de um place carregados
class PlaceDetailsLoaded extends PlaceState {
  final PlaceDetails placeDetails;

  const PlaceDetailsLoaded(this.placeDetails);

  @override
  List<Object?> get props => [placeDetails];
}

/// Estado de erro
class PlaceError extends PlaceState {
  final String message;

  const PlaceError(this.message);

  @override
  List<Object?> get props => [message];
}
