import '../domain/entities.dart';

/// Cada cuántos elementos se intercala un anuncio -- lo bastante espaciado
/// para que no se sienta invasivo (nunca dos anuncios seguidos).
const adSpacing = 8;

/// Mezcla [items] con [ads] cada [adSpacing] posiciones, rotando entre los
/// anuncios disponibles (con más de [adSpacing] elementos, el mismo anuncio
/// puede repetirse más adelante, pero nunca dos veces seguidas). Sin
/// anuncios activos, devuelve [items] tal cual. Usado tanto por el grid del
/// Shop como por el feed de Home -- misma regla de dispersión en los dos.
List<Object> interleaveAds<T extends Object>(List<T> items, List<AdEntity> ads) {
  if (ads.isEmpty) return items;

  final cells = <Object>[];
  var adCursor = 0;
  for (var i = 0; i < items.length; i++) {
    cells.add(items[i]);
    if ((i + 1) % adSpacing == 0) {
      cells.add(ads[adCursor % ads.length]);
      adCursor++;
    }
  }
  return cells;
}
