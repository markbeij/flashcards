import '../domain/card_content.dart';
import '../domain/deck.dart';

/// Router locations. Library pages are nested (library → map → deck) so a
/// deck opened at startup still has its map and the library behind it.
const libraryLocation = '/';

String mapLocation(String map) => '/map/${Uri.encodeComponent(map)}';

String deckLocation(Deck deck) => '${mapLocation(deck.map)}/deck/${deck.id}';

/// "Add cards", optionally in [type] or starting from a copy of the card
/// [likeCardId] ("New card like this").
String addCardsLocation(String deckId, {CardType? type, String? likeCardId}) {
  final query = {'type': ?type?.name, 'like': ?likeCardId};
  return Uri(
    path: '/add/$deckId',
    queryParameters: query.isEmpty ? null : query,
  ).toString();
}

String cardLocation(String deckId, String cardId) => '/edit/$deckId/$cardId';

String printLocation({String? deckId}) => Uri(
  path: '/print',
  queryParameters: deckId == null ? null : {'deck': deckId},
).toString();

const printPreviewLocation = '/print/preview';
const settingsLocation = '/settings';

/// The map and deck in a library location, e.g. `/map/VWO%204/deck/x`.
({String? map, String? deckId}) parseLibraryLocation(Uri uri) {
  final segments = uri.pathSegments;
  String? after(String key) {
    final i = segments.indexOf(key);
    return i >= 0 && i + 1 < segments.length ? segments[i + 1] : null;
  }

  return (map: after('map'), deckId: after('deck'));
}
