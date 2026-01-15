class ProductAiService {

  static final Map<String, Map<String, dynamic>> _dictionary = {

    'Coca Cola 390ml': {'category': 'Minuman', 'price': 6000},
    'Coca Cola 1.5L': {'category': 'Minuman', 'price': 18000},
    'Sprite 390ml': {'category': 'Minuman', 'price': 6000},
    'Fanta Strawberry': {'category': 'Minuman', 'price': 6000},
    'Aqua Botol 600ml': {'category': 'Minuman', 'price': 4000},
    'Aqua Galon': {'category': 'Minuman', 'price': 22000},
    'Teh Pucuk Harum': {'category': 'Minuman', 'price': 4000},
    'Good Day Cappuccino': {'category': 'Minuman', 'price': 7000},
    'Kopi Kapal Api (Renteng)': {'category': 'Minuman', 'price': 15000},
  
    'Indomie Goreng': {'category': 'Makanan', 'price': 3500},
    'Indomie Soto': {'category': 'Makanan', 'price': 3500},
    'Sedaap Goreng': {'category': 'Makanan', 'price': 3500},
    'Chitato Sapi Panggang': {'category': 'Makanan', 'price': 12000},
    'Lays Rumput Laut': {'category': 'Makanan', 'price': 12000},
    'Beng Beng': {'category': 'Makanan', 'price': 2500},
    'Silverqueen': {'category': 'Makanan', 'price': 18000},
    'Beras 5kg Premium': {'category': 'Sembako', 'price': 75000},
    'Minyak Goreng 1L': {'category': 'Sembako', 'price': 16000},
    'Gula Pasir 1kg': {'category': 'Sembako', 'price': 14000},
    'Telur Ayam (1kg)': {'category': 'Sembako', 'price': 28000},

    'Sampoerna Mild 16': {'category': 'Rokok', 'price': 32000},
    'Gudang Garam Filter': {'category': 'Rokok', 'price': 25000},
    'Djarum Super 12': {'category': 'Rokok', 'price': 24000},
    'Marlboro Merah': {'category': 'Rokok', 'price': 42000},
    'Surya 16': {'category': 'Rokok', 'price': 30000},

    'Lifebuoy Sabun Cair': {'category': 'Perlengkapan', 'price': 25000},
    'Pepsodent 190g': {'category': 'Perlengkapan', 'price': 18000},
    'Sunlight 755ml': {'category': 'Perlengkapan', 'price': 15000},
    'Rinso Bubuk 800g': {'category': 'Perlengkapan', 'price': 22000},
  };

  static List<String> getSuggestions(String query) {
    if (query.isEmpty) return [];
    return _dictionary.keys
        .where((key) => key.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static Map<String, dynamic>? getProductDetails(String productName) {
    return _dictionary[productName];
  }
}