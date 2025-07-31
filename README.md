# GetX Instance Management

[![pub package](https://img.shields.io/pub/v/getx_instance.svg)](https://pub.dev/packages/getx_instance)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful and lightweight dependency injection and state management solution for Flutter applications, built on top of GetX Core. This package provides a simple yet robust way to manage your application's dependencies and their lifecycles.

## GetX Instance

A powerful and lightweight dependency injection and state management solution for Flutter applications, built on top of GetX Core. This package provides a simple yet robust way to manage your application's dependencies and their lifecycles.

## Features

- 🚀 **Dependency Injection / Dependency Injection**: Register and retrieve dependencies with ease
- 🔄 **Lifecycle Management / Lifecycle Management**: Automatic management of controller lifecycles
- 🏗️ **Lazy Loading / Lazy Loading**: Load dependencies only when needed
- 🔒 **Singleton & Factory Patterns / Singleton & Factory Patterns**: Support for both singleton and factory patterns
- 🔄 **Dependency Replacement / Dependency Replacement**: Replace dependencies at runtime
- 🧪 **Test-Friendly / Test-Friendly**: Easy to mock and test your dependencies
- 🔄 **Reactive State Management / Reactive State Management**: Built-in support for reactive programming

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  getx_instance: ^0.0.1
```

## Getting Started

### Basic Usage

#### 1. Register a dependency

```dart
import 'package:getx_instance/getx_instance.dart';

// Register a singleton
Get.put(MyController());

// Register a lazy singleton (created only when first used)
Get.lazyPut(() => MyLazyController());

// Register a factory (new instance every time)
Get.spawn(() => MyFactoryController(), tag: 'factory');
```

#### 2. Retrieve a dependency

```dart
// Get the instance
final controller = Get.find<MyController>();

// Or use the call syntax
final controller = Get<MyController>();

// Safe retrieval (returns null if not found)
final controller = Get.findOrNull<MyController>();
```

#### 3. Bindings (for route-based dependency injection)

```dart
class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.put(HomeService());
  }
}

// Use with GetPage
GetPage(
  name: '/home',
  page: () => HomeView(),
  binding: HomeBinding(),
);
```

## Advanced Usage

### Lifecycle Management

```dart
class MyController extends GetxController with GetLifeCycleMixin {
  @override
  void onInit() {
    super.onInit();
    // Called when the controller is created
    print('Controller initialized');
  }
  
  @override
  void onReady() {
    super.onReady();
    // Called after the widget is rendered
    print('Controller ready');
  }
  
  @override
  void onClose() {
    // Clean up resources
    print('Controller disposed');
    super.onClose();
  }
}
```

### Working with Services

```dart
// Define a service
class ApiService extends GetxService {
  final String baseUrl = 'https://api.example.com';
  
  Future<Map<String, dynamic>> fetchData() async {
    // Your API call here
    await Future.delayed(Duration(seconds: 1));
    return {'data': 'example'};
  }
  
  @override
  void onInit() {
    super.onInit();
    print('ApiService initialized');
  }
}

// Register the service
Get.put(ApiService());

// Use the service
final api = Get.find<ApiService>();
final response = await api.fetchData();
```

### Dependency Replacement

```dart
// Replace an existing dependency
Get.replace<MyController>(NewController());

// Lazy replace
Get.lazyReplace<MyController>(() => NewController());
```

### Instance Information

```dart
// Get detailed information about an instance
final info = Get.getInstanceInfo<MyController>();
print('Is Permanent: ${info.isPermanent}');
print('Is Singleton: ${info.isSingleton}');
print('Is Registered: ${info.isRegistered}');
print('Is Prepared: ${info.isPrepared}');
print('Is Initialized: ${info.isInit}');
```

### Memory Management

```dart
// Delete a specific instance
Get.delete<MyController>();

// Delete with force (even permanent instances)
Get.delete<MyController>(force: true);

// Delete all instances
Get.deleteAll();

// Reset all instances (including permanent ones)
Get.resetInstance();

// Reload an instance
Get.reload<MyController>();

// Reload all instances
Get.reloadAll();
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:getx_instance/getx_instance.dart';

// Model
class User {
  final String name;
  final String email;
  
  User({required this.name, required this.email});
}

// Service
class UserService extends GetxService {
  Future<User> getCurrentUser() async {
    await Future.delayed(Duration(seconds: 1));
    return User(name: 'John Doe', email: 'john@example.com');
  }
  
  @override
  void onInit() {
    super.onInit();
    print('UserService initialized');
  }
}

// Controller
class UserController extends GetxController with GetLifeCycleMixin {
  final UserService _userService = Get.find<UserService>();
  
  User? _currentUser;
  User? get currentUser => _currentUser;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  @override
  void onInit() {
    super.onInit();
    loadUser();
  }
  
  Future<void> loadUser() async {
    _isLoading = true;
    update();
    
    try {
      _currentUser = await _userService.getCurrentUser();
    } catch (e) {
      print('Error loading user: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }
  
  @override
  void onClose() {
    print('UserController disposed');
    super.onClose();
  }
}

// Binding
class UserBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(UserService());
    Get.lazyPut(() => UserController());
  }
}

// Widget
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: GetBuilder<UserController>(
        builder: (controller) {
          if (controller.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          final user = controller.currentUser;
          if (user == null) {
            return Center(child: Text('No user data'));
          }
          
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${user.name}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Email: ${user.email}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.loadUser,
                  child: Text('Refresh'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

## Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_instance/getx_instance.dart';

void main() {
  group('GetX Instance Tests', () {
    setUp(() {
      // Reset instances before each test
      Get.resetInstance();
    });
    
    test('should register and find instance', () {
      // Arrange
      final controller = MyController();
      
      // Act
      Get.put(controller);
      final found = Get.find<MyController>();
      
      // Assert
      expect(found, equals(controller));
      expect(Get.isRegistered<MyController>(), isTrue);
    });
    
    test('should create lazy instance only when needed', () {
      // Arrange
      var created = false;
      
      // Act
      Get.lazyPut(() {
        created = true;
        return MyController();
      });
      
      // Assert
      expect(created, isFalse);
      expect(Get.isPrepared<MyController>(), isTrue);
      
      // Now access it
      Get.find<MyController>();
      expect(created, isTrue);
    });
    
    test('should delete instance', () {
      // Arrange
      Get.put(MyController());
      expect(Get.isRegistered<MyController>(), isTrue);
      
      // Act
      final deleted = Get.delete<MyController>();
      
      // Assert
      expect(deleted, isTrue);
      expect(Get.isRegistered<MyController>(), isFalse);
    });
  });
}

class MyController extends GetxController with GetLifeCycleMixin {
  int counter = 0;
  
  void increment() {
    counter++;
    update();
  }
}
```

## API Reference

### Core Methods

| Method | Description |
|--------|-------------|
| `Get.put<S>()` | Registers a singleton instance |
| `Get.lazyPut<S>()` | Registers a lazy singleton |
| `Get.spawn<S>()` | Registers a factory instance |
| `Get.find<S>()` | Retrieves a registered instance |
| `Get.findOrNull<S>()` | Safe retrieval (returns null if not found) |
| `Get.delete<S>()` | Removes a registered instance |
| `Get.isRegistered<S>()` | Checks if an instance is registered |
| `Get.isPrepared<S>()` | Checks if a lazy instance is prepared |
| `Get.reset()` | Clears all registered instances |

### Lifecycle Methods

| Method | Description |
|--------|-------------|
| `onInit()` | Called when the controller is created |
| `onReady()` | Called after the widget is rendered |
| `onClose()` | Called when the controller is deleted |

### Instance Information

``` dart
class InstanceInfo {
  final bool? isPermanent;    // Is the instance permanent?
  final bool? isSingleton;    // Is it a singleton?
  final bool isRegistered;    // Is it registered?
  final bool isPrepared;      // Is it prepared (lazy)?
  final bool? isInit;         // Is it initialized?
}
```

## Best Practices

### 1. Use Services for Global State

```dart
// Good / جيد
class AuthService extends GetxService {
  bool get isLoggedIn => _token != null;
  String? _token;
  
  Future<void> login(String email, String password) async {
    // Login logic
  }

// Register once in main()
void main() {
  Get.put(AuthService());
  runApp(MyApp());
}
```

### 2. Use Controllers for Page-Specific Logic

```dart
// Good / جيد
class HomeController extends GetxController with GetLifeCycleMixin {
  final AuthService _auth = Get.find<AuthService>();
  
  @override
  void onInit() {
    super.onInit();
    if (!_auth.isLoggedIn) {
      // Redirect to login
    }
  }
}
```

### 3. Use Bindings for Route Dependencies

```dart
// Good / جيد
class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => HomeRepository());
  }
}
```

### 4. Clean Up Resources

```dart
// Good / جيد
class StreamController extends GetxController with GetLifeCycleMixin {
  late StreamSubscription _subscription;
  
  @override
  void onInit() {
    super.onInit();
    _subscription = someStream.listen((data) {
      // Handle data
    });
  }
  
  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
```

## Common Patterns

### Repository Pattern

```dart
abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User> getUserById(String id);
}

class ApiUserRepository implements UserRepository {
  final ApiService _api = Get.find<ApiService>();
  
  @override
  Future<List<User>> getUsers() async {
    final response = await _api.get('/users');
    return response.map((json) => User.fromJson(json)).toList();
  }
  
  @override
  Future<User> getUserById(String id) async {
    final response = await _api.get('/users/$id');
    return User.fromJson(response);
  }
}

// Register
Get.put<UserRepository>(ApiUserRepository());
```

### State Management with GetBuilder

```dart
class CounterController extends GetxController with GetLifeCycleMixin {
  int _count = 0;
  int get count => _count;
  
  void increment() {
    _count++;
    update(); // Notify listeners
  }
  
  void decrement() {
    _count--;
    update(['counter']); // Update specific ID
  }
}

// In Widget
GetBuilder<CounterController>(
  id: 'counter',
  builder: (controller) => Text('${controller.count}'),
)
```

## Troubleshooting

### Common Issues

1. **Instance not found**

   ```dart
   // Error
   final controller = Get.find<MyController>(); // Throws exception
   
   // Solution
   if (Get.isRegistered<MyController>()) {
     final controller = Get.find<MyController>();
   } else {
     Get.put(MyController());
   }
   
   // Or use safe method
   final controller = Get.findOrNull<MyController>();
   ```

2. **Memory leaks**

   ```dart
   // Bad
   class BadController extends GetxController {
     Timer? timer;
     
     @override
     void onInit() {
       timer = Timer.periodic(Duration(seconds: 1), (timer) {
         // Some work
       });
     }
     // Timer not cancelled!
   }
   
   // Good
   class GoodController extends GetxController with GetLifeCycleMixin {
     Timer? timer;
     
     @override
     void onInit() {
       super.onInit();
       timer = Timer.periodic(Duration(seconds: 1), (timer) {
         // Some work
       });
     }
     
     @override
     void onClose() {
       timer?.cancel();
       super.onClose();
     }
   }
   ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [GetX](https://github.com/jonataslaw/getx) for the inspiration
- All the amazing contributors
