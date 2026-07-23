import 'models.dart';

/// Los banners promocionales no tienen equivalente en el backend (no existe
/// un endpoint de promociones) -- se quedan como datos de prueba fijos, a
/// diferencia de los items del catálogo, que ya vienen de GET /assets real
/// (ver [MarketplaceRemoteDataSourceImpl]).
abstract class MarketplaceFixtures {
  static List<PromoBannerModel> get mockBanners => const [
    PromoBannerModel(
      id: 'b1',
      sellerName: 'Sr.Sneakers',
      title: 'Solid RED NE',
      price: 1500,
      oldPrice: 1800,
      imageUrl: 'assets/images/mock/jordan_red.jpg',
    ),
    PromoBannerModel(
      id: 'b2',
      sellerName: 'Sr.Rolex',
      title: 'Rolex Gemini',
      price: 2500,
      oldPrice: 3000,
      imageUrl: 'assets/images/mock/reloj1.jpg',
    ),
    PromoBannerModel(
      id: 'b3',
      sellerName: 'Sr.Sneakers',
      title: 'ColorFull A9',
      price: 1200,
      oldPrice: 1500,
      imageUrl: 'assets/images/mock/sneaker1.jpg',
    ),
  ];
}