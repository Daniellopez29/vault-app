import 'models.dart';

/// Datos de prueba temporales mientras el backend no está disponible.
/// Reemplazar por llamadas reales en [MarketplaceRemoteDataSourceImpl].
abstract class MarketplaceFixtures {
  static List<MarketplaceItemModel> get mockItems => const [
    MarketplaceItemModel(
      id: 'm1',
      brand: 'Nike',
      title: 'Tenis ColorFull A9',
      imageUrl: 'assets/images/mock/sneaker1.jpg',
      origin: 'Nike Online',
      size: '27 MX',
      price: 12,
      rating: 8.9,
      isVerified: true,
    ),
    MarketplaceItemModel(
      id: 'm2',
      brand: 'Nike',
      title: 'Tenis ColorFull A9',
      imageUrl: 'assets/images/mock/sneaker2.jpg',
      origin: 'Nike Online',
      size: '27 MX',
      price: 12,
      rating: 8.9,
      isVerified: true,
    ),
    MarketplaceItemModel(
      id: 'm3',
      brand: 'Rolex',
      title: 'Reloj Rolex Gemini',
      imageUrl: 'assets/images/mock/reloj1.jpg',
      origin: 'Distribuidor Oficial',
      size: '42 mm',
      price: 25,
      rating: 9.1,
      isVerified: true,
    ),
    MarketplaceItemModel(
      id: 'm4',
      brand: 'Nike',
      title: 'Gorra LA Edition',
      imageUrl: 'assets/images/mock/gorra1.jpg',
      origin: 'Nike Online',
      size: 'Única',
      price: 8,
      rating: 8.5,
      isVerified: false,
    ),
    MarketplaceItemModel(
      id: 'm5',
      brand: 'Jordan',
      title: 'Solid RED NE',
      imageUrl: 'assets/images/mock/jordan_red.jpg',
      origin: 'Sr.Sneakers',
      size: '28 MX',
      price: 15,
      rating: 9.4,
      isVerified: true,
    ),
    MarketplaceItemModel(
      id: 'm6',
      brand: 'Nike',
      title: 'Tenis ColorFull A9',
      imageUrl: 'assets/images/mock/sneaker1.jpg',
      origin: 'Nike Online',
      size: '27 MX',
      price: 12,
      rating: 8.9,
      isVerified: false,
    ),
  ];

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