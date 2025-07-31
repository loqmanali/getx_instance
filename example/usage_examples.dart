import 'package:flutter/material.dart';
import 'package:getx_instance/getx_instance.dart';

class CounterController with GetLifeCycleMixin {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
  }

  void decrement() {
    _count--;
  }

  void reset() {
    _count = 0;
  }

  @override
  void onInit() {
    super.onInit();
    print('CounterController initialized');
  }

  @override
  void onReady() {
    super.onReady();
    print('CounterController ready');
  }

  @override
  void onClose() {
    print('CounterController disposed');
    super.onClose();
  }
}

// Example 2: Service with Persistent Data
// مثال 2: خدمة مع بيانات دائمة
class UserService extends GetxService {
  String? _currentUser;
  final List<String> _userHistory = [];

  String? get currentUser => _currentUser;
  List<String> get userHistory => List.unmodifiable(_userHistory);

  Future<void> login(String username) async {
    await Future.delayed(Duration(seconds: 1));

    _currentUser = username;
    _userHistory.add(username);
    print('User logged in: $username');
  }

  void logout() {
    _currentUser = null;
    print('User logged out');
  }

  bool get isLoggedIn => _currentUser != null;

  @override
  void onInit() {
    super.onInit();
    print('UserService initialized');
    _loadUserData();
  }

  @override
  void onClose() {
    print('UserService disposed');
    super.onClose();
  }

  void _loadUserData() {
    // Simulate loading from storage
    print('Loading user data');
  }
}

// Example 3: Repository with Dependency Injection
class ApiService extends GetxService {
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 500));

    return [
      {'id': 1, 'name': 'Ahmed', 'email': 'ahmed@example.com'},
      {'id': 2, 'name': 'Fatima', 'email': 'fatima@example.com'},
      {'id': 3, 'name': 'Omar', 'email': 'omar@example.com'},
    ];
  }

  Future<Map<String, dynamic>> fetchUserById(int id) async {
    await Future.delayed(Duration(milliseconds: 300));

    final users = await fetchUsers();
    return users.firstWhere(
      (user) => user['id'] == id,
      orElse: () => {'error': 'User not found'},
    );
  }

  @override
  void onInit() {
    super.onInit();
    print('ApiService initialized');
  }
}

class UserRepository {
  final ApiService _apiService;

  UserRepository(this._apiService);

  Future<List<User>> getAllUsers() async {
    final data = await _apiService.fetchUsers();
    return data.map((json) => User.fromJson(json)).toList();
  }

  Future<User?> getUserById(int id) async {
    final data = await _apiService.fetchUserById(id);
    if (data.containsKey('error')) {
      return null;
    }
    return User.fromJson(data);
  }
}

// Example 4: Data Model
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], email: json['email']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}

// Example 5: Complex Controller with Multiple Dependencies
class UserListController with GetLifeCycleMixin {
  final UserRepository _userRepository;

  UserListController(this._userRepository);

  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;

    try {
      _users = await _userRepository.getAllUsers();
      print('Loaded ${_users.length} users');
    } catch (e) {
      _error = 'Failed to load users: $e';
      print(_error);
    } finally {
      _isLoading = false;
      // In real GetX, you would call update() here
    }
  }

  Future<void> refreshUsers() async {
    await loadUsers();
  }

  User? findUserById(int id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    print('UserListController initialized');
    loadUsers();
  }

  @override
  void onReady() {
    super.onReady();
    print('UserListController ready');
  }

  @override
  void onClose() {
    print('UserListController disposed');
    super.onClose();
  }
}

// Example 6: Bindings for Dependency Management
class HomeBinding implements BindingsInterface {
  @override
  void dependencies() {
    // Register services (permanent by default)

    // Note: In a real GetX implementation, you would use:
    // Get.put(ApiService(), permanent: true);
    // Get.put(UserService(), permanent: true);

    // Register repositories

    // Get.lazyPut(() => UserRepository(Get.find<ApiService>()));

    // Register controllers
    // Get.lazyPut(() => CounterController());
    // Get.lazyPut(() => UserListController(
    //   Get.find<UserRepository>(),
    //   Get.find<UserService>(),
    // ));

    print('HomeBinding dependencies registered');
  }
}

// Example 7: Feature-specific Binding
class UserFeatureBinding implements BindingsInterface {
  @override
  void dependencies() {
    // Register only user-related dependencies

    // Note: In a real GetX implementation:

    // Get.lazyPut(() => UserListController(
    //   Get.find<UserRepository>(),
    //   Get.find<UserService>(),
    // ), tag: 'userList');

    // Get.lazyPut(() => CounterController(), tag: 'userCounter');

    print('UserFeatureBinding dependencies registered');
  }
}

// Example 8: Usage Examples Function
void demonstrateUsage() {
  print('=== GetX Instance Usage Examples ===');
  print('=== أمثلة استخدام GetX Instance ===\n');

  // Example 1: Basic Controller Usage
  print('1. Basic Controller Usage:');
  final counterController = CounterController();
  counterController.onInit();

  counterController.increment();
  counterController.increment();
  print('Counter value: ${counterController.count}');

  counterController.decrement();
  print('Counter after decrement: ${counterController.count}');

  counterController.reset();
  print('Counter after reset: ${counterController.count}');

  counterController.onClose();
  print('');

  // Example 2: Service Usage
  print('2. Service Usage:');
  final userService = UserService();
  userService.onInit();

  print('Is logged in: ${userService.isLoggedIn}');

  // Simulate login (in real app, this would be async)
  userService.login('ahmed_user').then((_) {
    print('Current user: ${userService.currentUser}');
    print('User history: ${userService.userHistory}');

    userService.logout();
    print('Is logged in after logout: ${userService.isLoggedIn}');
  });
  print('');

  // Example 3: Repository with Dependencies
  print('3. Repository Usage:');
  final apiService = ApiService();
  apiService.onInit();

  final userRepository = UserRepository(apiService);

  // Simulate fetching users
  userRepository.getAllUsers().then((users) {
    print('Fetched ${users.length} users:');
    for (final user in users) {
      print('  - $user');
    }
  });
  print('');

  // Example 4: Complex Controller
  print('4. Complex Controller Usage:');
  final userListController = UserListController(userRepository);
  userListController.onInit();

  // Wait for data to load
  Future.delayed(Duration(seconds: 1), () {
    print('Users loaded: ${userListController.users.length}');
    print('Is loading: ${userListController.isLoading}');
    print('Has error: ${userListController.hasError}');

    final user = userListController.findUserById(1);
    if (user != null) {
      print('Found user: $user');
    }

    userListController.onClose();
  });
  print('');

  // Example 5: Bindings Usage
  print('5. Bindings Usage:');
  final homeBinding = HomeBinding();
  homeBinding.dependencies();

  final userBinding = UserFeatureBinding();
  userBinding.dependencies();
  print('');

  print('=== End of Examples ===');
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  late CounterController controller;

  @override
  void initState() {
    super.initState();
    controller = CounterController();
    controller.onInit();
  }

  @override
  void dispose() {
    controller.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Counter Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Counter Value:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Text(
              '${controller.count}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      controller.decrement();
                    });
                  },
                  child: Text('-'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      controller.reset();
                    });
                  },
                  child: Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      controller.increment();
                    });
                  },
                  child: Text('+'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  print('Starting GetX Instance Examples');

  demonstrateUsage();

  // In a Flutter app, you would also run:
  // runApp(MyApp());
}

// Example Flutter App Structure (Conceptual)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GetX Instance Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CounterPage(),
      // In real GetX implementation, you would set up initial bindings:
      // initialBinding: HomeBinding(),
    );
  }
}
