import 'dart:async';

import 'package:flutter/material.dart';
import 'package:getx_instance/getx_instance.dart';

class ThemeService extends GetxService {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = Locale('en');
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _saveThemePreference();
    print('Theme toggled to: ${_isDarkMode ? "Dark" : "Light"}');
  }

  void setLocale(String languageCode) {
    _locale = Locale(languageCode);
    _saveLocalePreference();
    print('Locale changed to: $languageCode');
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    _saveThemePreference();
    print('Theme set to system default');
  }

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    print('ThemeService initialized / تم تهيئة ThemeService');
  }

  void _loadPreferences() {
    // Simulate loading from SharedPreferences
    // محاكاة التحميل من SharedPreferences
    print('Loading theme preferences / تحميل تفضيلات المظهر');
  }

  void _saveThemePreference() {
    // Simulate saving to SharedPreferences
    // محاكاة الحفظ في SharedPreferences
    print('Saving theme preference / حفظ تفضيل المظهر');
  }

  void _saveLocalePreference() {
    // Simulate saving to SharedPreferences
    // محاكاة الحفظ في SharedPreferences
    print('Saving locale preference / حفظ تفضيل اللغة');
  }
}

class NetworkService extends GetxService {
  final Map<String, dynamic> _cache = {};
  final Duration _cacheTimeout = Duration(minutes: 5);
  final Map<String, DateTime> _cacheTimestamps = {};

  Future<Map<String, dynamic>> get(String endpoint) async {
    // Check cache first
    if (_isCacheValid(endpoint)) {
      print('Returning cached data for: $endpoint');
      return _cache[endpoint];
    }

    // Simulate network request
    print('Fetching data from network: $endpoint');
    await Future.delayed(Duration(milliseconds: 500));

    final data = {
      'endpoint': endpoint,
      'timestamp': DateTime.now().toIso8601String(),
      'data': 'Sample data for $endpoint',
    };

    // Cache the result
    _cache[endpoint] = data;
    _cacheTimestamps[endpoint] = DateTime.now();

    return data;
  }

  Future<void> post(String endpoint, Map<String, dynamic> body) async {
    print('Posting to: $endpoint with body: $body');
    await Future.delayed(Duration(milliseconds: 300));

    // Invalidate related cache
    _invalidateCache(endpoint);
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    print('Cache cleared');
  }

  bool _isCacheValid(String endpoint) {
    if (!_cache.containsKey(endpoint)) return false;

    final timestamp = _cacheTimestamps[endpoint];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheTimeout;
  }

  void _invalidateCache(String endpoint) {
    _cache.remove(endpoint);
    _cacheTimestamps.remove(endpoint);
    print('Cache invalidated for: $endpoint');
  }

  @override
  void onInit() {
    super.onInit();
    print('NetworkService initialized');
  }

  @override
  void onClose() {
    clearCache();
    print('NetworkService disposed');
    super.onClose();
  }
}

enum LoadingState { idle, loading, success, error }

class ProductController with GetLifeCycleMixin {
  final NetworkService _networkService;

  ProductController(this._networkService);

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;
  String _searchQuery = '';
  ProductCategory? _selectedCategory;

  // Getters
  List<Product> get products => List.unmodifiable(_filteredProducts);
  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  ProductCategory? get selectedCategory => _selectedCategory;

  bool get isLoading => _loadingState == LoadingState.loading;
  bool get hasError => _loadingState == LoadingState.error;
  bool get hasData => _products.isNotEmpty;

  Future<void> loadProducts() async {
    _setLoadingState(LoadingState.loading);

    try {
      _products = _generateSampleProducts();
      _applyFilters();

      _setLoadingState(LoadingState.success);
    } catch (e) {
      _errorMessage = 'Failed to load products: $e';
      _setLoadingState(LoadingState.error);
    }
  }

  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    print('Search applied: $query');
  }

  void filterByCategory(ProductCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    print('Category filter applied: ${category?.name ?? "All"}');
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _applyFilters();
    print('Filters cleared');
  }

  Future<void> refreshProducts() async {
    _networkService.clearCache();
    await loadProducts();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  void _setLoadingState(LoadingState state) {
    _loadingState = state;
    if (state != LoadingState.error) {
      _errorMessage = null;
    }
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery) ||
          product.description.toLowerCase().contains(_searchQuery);

      final matchesCategory =
          _selectedCategory == null || product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    print(
      'Filters applied. Showing ${_filteredProducts.length} of ${_products.length} products',
    );
  }

  List<Product> _generateSampleProducts() {
    return [
      Product(
        id: '1',
        name: 'iPhone 15 Pro',
        description: 'Latest iPhone with advanced features',
        price: 999.99,
        category: ProductCategory.electronics,
        imageUrl: 'https://example.com/iphone.jpg',
      ),
      Product(
        id: '2',
        name: 'Nike Air Max',
        description: 'Comfortable running shoes',
        price: 129.99,
        category: ProductCategory.clothing,
        imageUrl: 'https://example.com/nike.jpg',
      ),
      Product(
        id: '3',
        name: 'The Great Gatsby',
        description: 'Classic American novel',
        price: 12.99,
        category: ProductCategory.books,
        imageUrl: 'https://example.com/gatsby.jpg',
      ),
      Product(
        id: '4',
        name: 'MacBook Pro',
        description: 'Powerful laptop for professionals',
        price: 1999.99,
        category: ProductCategory.electronics,
        imageUrl: 'https://example.com/macbook.jpg',
      ),
      Product(
        id: '5',
        name: 'Levi\'s Jeans',
        description: 'Classic denim jeans',
        price: 79.99,
        category: ProductCategory.clothing,
        imageUrl: 'https://example.com/jeans.jpg',
      ),
    ];
  }

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }
}

class CartService extends GetxService {
  final Map<String, CartItem> _items = {};
  final StreamController<List<CartItem>> _cartStreamController =
      StreamController<List<CartItem>>.broadcast();

  Stream<List<CartItem>> get cartStream => _cartStreamController.stream;
  List<CartItem> get items => _items.values.toList();
  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  void addItem(Product product, {int quantity = 1}) {
    final existingItem = _items[product.id];

    if (existingItem != null) {
      _items[product.id] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }

    _notifyCartChanged();
    print('Added ${product.name} to cart (quantity: $quantity)');
  }

  void removeItem(String productId) {
    final item = _items.remove(productId);
    if (item != null) {
      _notifyCartChanged();
      print('Removed ${item.product.name} from cart');
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final existingItem = _items[productId];
    if (existingItem != null) {
      _items[productId] = existingItem.copyWith(quantity: quantity);
      _notifyCartChanged();
      print('Updated ${existingItem.product.name} quantity to $quantity');
    }
  }

  void clearCart() {
    _items.clear();
    _notifyCartChanged();
    print('Cart cleared');
  }

  CartItem? getItem(String productId) {
    return _items[productId];
  }

  bool containsProduct(String productId) {
    return _items.containsKey(productId);
  }

  Future<bool> checkout() async {
    if (isEmpty) {
      return false;
    }

    print('Processing checkout for $itemCount items...');
    print('Total amount: \$${totalPrice.toStringAsFixed(2)}');

    await Future.delayed(Duration(seconds: 2));

    clearCart();
    return true;
  }

  void _notifyCartChanged() {
    _cartStreamController.add(items);
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    _cartStreamController.close();
    super.onClose();
  }
}

class AppBinding extends BindingsInterface {
  @override
  void dependencies() {
    // Core Services (Permanent)
    // Get.put(ThemeService(), permanent: true);
    // Get.put(NetworkService(), permanent: true);
  }
}

class ShopBinding extends BindingsInterface {
  @override
  void dependencies() {
    // Shop-specific dependencies
    // Get.lazyPut(() => ProductController(Get.find<NetworkService>()));
  }
}

// Data Models
enum ProductCategory { electronics, clothing, books, home, sports }

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final ProductCategory category;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
  });

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: \$${price.toStringAsFixed(2)})';
  }
}

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  double get totalPrice => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'CartItem(product: ${product.name}, quantity: $quantity, total: \$${totalPrice.toStringAsFixed(2)})';
  }
}

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late ProductController productController;
  late CartService cartService;
  late ThemeService themeService;
  late StreamSubscription<List<CartItem>> cartSubscription;

  @override
  void initState() {
    super.initState();

    final networkService = NetworkService();
    networkService.onInit();

    cartService = CartService();
    cartService.onInit();

    themeService = ThemeService();
    themeService.onInit();

    productController = ProductController(networkService);
    productController.onInit();

    cartSubscription = cartService.cartStream.listen((items) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    cartSubscription.cancel();
    productController.onClose();
    cartService.onClose();
    themeService.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop / المتجر'),
        actions: [
          // Cart icon with badge / أيقونة السلة مع شارة
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () => _showCartDialog(),
              ),
              if (cartService.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cartService.itemCount}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Theme toggle / تبديل المظهر
          IconButton(
            icon: Icon(
              themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              setState(() {
                themeService.toggleTheme();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section / قسم البحث والتصفية
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products / البحث عن المنتجات',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (query) {
                    setState(() {
                      productController.searchProducts(query);
                    });
                  },
                ),
                SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('All / الكل', null),
                      ...ProductCategory.values.map(
                        (category) => _buildCategoryChip(
                          _getCategoryName(category),
                          category,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Products list / قائمة المنتجات
          Expanded(child: _buildProductsList()),
        ],
      ),
      floatingActionButton: cartService.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _checkout(),
              icon: Icon(Icons.payment),
              label: Text(
                'Checkout \$${cartService.totalPrice.toStringAsFixed(2)}',
              ),
            )
          : null,
    );
  }

  Widget _buildCategoryChip(String label, ProductCategory? category) {
    final isSelected = productController.selectedCategory == category;

    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            productController.filterByCategory(selected ? category : null);
          });
        },
      ),
    );
  }

  Widget _buildProductsList() {
    if (productController.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (productController.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(productController.errorMessage ?? 'Unknown error'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => productController.refreshProducts(),
              child: Text('Retry / إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (productController.products.isEmpty) {
      return Center(
        child: Text('No products found / لم يتم العثور على منتجات'),
      );
    }

    return ListView.builder(
      itemCount: productController.products.length,
      itemBuilder: (context, index) {
        final product = productController.products[index];
        final cartItem = cartService.getItem(product.id);

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text(product.name[0])),
            title: Text(product.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.description),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            trailing: cartItem != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            cartService.updateQuantity(
                              product.id,
                              cartItem.quantity - 1,
                            );
                          });
                        },
                      ),
                      Text('${cartItem.quantity}'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            cartService.addItem(product);
                          });
                        },
                      ),
                    ],
                  )
                : IconButton(
                    icon: Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      setState(() {
                        cartService.addItem(product);
                      });
                    },
                  ),
          ),
        );
      },
    );
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Shopping Cart / سلة التسوق'),
        content: cartService.isEmpty
            ? Text('Cart is empty / السلة فارغة')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...cartService.items.map(
                    (item) => ListTile(
                      title: Text(item.product.name),
                      subtitle: Text('Quantity: ${item.quantity}'),
                      trailing: Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Total / المجموع'),
                    trailing: Text(
                      '\$${cartService.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close / إغلاق'),
          ),
          if (cartService.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _checkout();
              },
              child: Text('Checkout / الدفع'),
            ),
        ],
      ),
    );
  }

  Future<void> _checkout() async {
    final success = await cartService.checkout();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed successfully! / تم تقديم الطلب بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getCategoryName(ProductCategory category) {
    switch (category) {
      case ProductCategory.electronics:
        return 'Electronics / إلكترونيات';
      case ProductCategory.clothing:
        return 'Clothing / ملابس';
      case ProductCategory.books:
        return 'Books / كتب';
      case ProductCategory.home:
        return 'Home / منزل';
      case ProductCategory.sports:
        return 'Sports / رياضة';
    }
  }
}

// Advanced Example 7: Main Function with Complete Setup
// مثال متقدم 7: الدالة الرئيسية مع الإعداد الكامل
void demonstrateAdvancedUsage() {
  print('=== Advanced GetX Instance Usage Examples ===');
  print('=== أمثلة الاستخدام المتقدم لـ GetX Instance ===\n');

  // Initialize core services / تهيئة الخدمات الأساسية
  final themeService = ThemeService();
  themeService.onInit();

  final networkService = NetworkService();
  networkService.onInit();

  final cartService = CartService();
  cartService.onInit();

  // Initialize controllers / تهيئة المتحكمات
  final productController = ProductController(networkService);
  productController.onInit();

  // Demonstrate theme service / عرض خدمة المظهر
  print('1. Theme Service Demo:');
  themeService.toggleTheme();
  themeService.setLocale('ar');
  themeService.setSystemTheme();
  print('');

  // Demonstrate network service / عرض خدمة الشبكة
  print('2. Network Service Demo:');
  networkService.get('/products').then((data) {
    print('Network response: $data');
  });
  print('');

  // Demonstrate cart service / عرض خدمة السلة
  print('3. Cart Service Demo:');
  final sampleProduct = Product(
    id: 'demo1',
    name: 'Demo Product',
    description: 'A sample product for demonstration',
    price: 29.99,
    category: ProductCategory.electronics,
    imageUrl: 'https://example.com/demo.jpg',
  );

  cartService.addItem(sampleProduct, quantity: 2);
  cartService.addItem(sampleProduct, quantity: 1); // Should update quantity

  print('Cart items: ${cartService.itemCount}');
  print('Cart total: \$${cartService.totalPrice.toStringAsFixed(2)}');
  print('');

  // Demonstrate product controller / عرض متحكم المنتجات
  print('4. Product Controller Demo:');
  Future.delayed(Duration(seconds: 1), () {
    productController.searchProducts('iPhone');
    productController.filterByCategory(ProductCategory.electronics);

    print('Filtered products: ${productController.products.length}');

    // Cleanup / تنظيف
    productController.onClose();
    cartService.onClose();
    themeService.onClose();
    networkService.onClose();
  });

  print('=== End of Advanced Examples / نهاية الأمثلة المتقدمة ===');
}

void main() {
  print(
    'Starting Advanced GetX Instance Examples / بدء الأمثلة المتقدمة لـ GetX Instance\n',
  );

  demonstrateAdvancedUsage();

  // In a Flutter app, you would run:
  // في تطبيق Flutter، ستقوم بتشغيل:
  // runApp(AdvancedShopApp());
}

class AdvancedShopApp extends StatelessWidget {
  const AdvancedShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced GetX Instance Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      home: ShopPage(),
      // In real GetX implementation:
      // في تطبيق GetX حقيقي:
      // initialBinding: AppBinding(),
    );
  }
}
