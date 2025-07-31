# Testing Guide for GetX Instance Package

# GetX Instance

This guide provides comprehensive information about testing your GetX Instance implementations.

## Table of Contents

1. [Testing Setup](#testing-setup)
2. [Unit Testing Controllers](#unit-testing-controllers)
3. [Testing Services](#testing-services)
4. [Testing Bindings](#testing-bindings)
5. [Integration Testing](#integration-testing)
6. [Widget Testing](#widget-testing)
7. [Mocking Dependencies](#mocking-dependencies)
8. [Best Practices](#best-practices)

## Testing Setup

### Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.7
  flutter_lints: ^3.0.0
```

### Basic Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_instance/getx_instance.dart';

void main() {
  group('YourController Tests', () {
    setUp(() {
      // Setup before each test
    });

    tearDown(() {
      // Cleanup after each test
    });

    test('should do something', () {
      // Test implementation
    });
  });
}
```

## Unit Testing Controllers

### Testing Lifecycle Methods

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_instance/getx_instance.dart';

class TestController with GetLifeCycleMixin {
  int counter = 0;
  bool isInitialized = false;
  bool isReady = false;
  bool isClosed = false;

  void increment() => counter++;

  @override
  void onInit() {
    super.onInit();
    isInitialized = true;
  }

  @override
  void onReady() {
    super.onReady();
    isReady = true;
  }

  @override
  void onClose() {
    isClosed = true;
    super.onClose();
  }
}

void main() {
  group('Controller Lifecycle Tests', () {
    late TestController controller;

    setUp(() {
      controller = TestController();
    });

    test('should initialize correctly', () {
      // Act
      controller.onInit();

      // Assert
      expect(controller.isInitialized, isTrue);
      expect(controller.isClosed, isFalse);
    });

    test('should handle onReady', () {
      // Act
      controller.onReady();

      // Assert
      expect(controller.isReady, isTrue);
    });

    test('should handle onClose', () {
      // Act
      controller.onClose();

      // Assert
      expect(controller.isClosed, isTrue);
    });

    test('should handle business logic', () {
      // Arrange
      expect(controller.counter, equals(0));

      // Act
      controller.increment();
      controller.increment();

      // Assert
      expect(controller.counter, equals(2));
    });
  });
}
```

### Testing Complex Controllers

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks / إنشاء المحاكيات
@GenerateMocks([ApiService])
import 'controller_test.mocks.dart';

class ApiService {
  Future<List<String>> fetchData() async {
    throw UnimplementedError();
  }
}

class DataController with GetLifeCycleMixin {
  final ApiService _apiService;
  
  DataController(this._apiService);

  List<String> _data = [];
  bool _isLoading = false;
  String? _error;

  List<String> get data => List.unmodifiable(_data);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;

    try {
      _data = await _apiService.fetchData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
    }
  }
}

void main() {
  group('DataController Tests', () {
    late MockApiService mockApiService;
    late DataController controller;

    setUp(() {
      mockApiService = MockApiService();
      controller = DataController(mockApiService);
    });

    test('should load data successfully', () async {
      // Arrange
      final expectedData = ['item1', 'item2', 'item3'];
      when(mockApiService.fetchData()).thenAnswer((_) async => expectedData);

      // Act
      await controller.loadData();

      // Assert / تأكيد
      expect(controller.data, equals(expectedData));
      expect(controller.isLoading, isFalse);
      expect(controller.error, isNull);
      verify(mockApiService.fetchData()).called(1);
    });

    test('should handle loading error', () async {
      // Arrange
      const errorMessage = 'Network error';
      when(mockApiService.fetchData()).thenThrow(Exception(errorMessage));

      // Act
      await controller.loadData();

      // Assert
      expect(controller.data, isEmpty);
      expect(controller.isLoading, isFalse);
      expect(controller.error, contains(errorMessage));
    });

    test('should set loading state correctly', () async {
      // Arrange
      when(mockApiService.fetchData()).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100));
        return ['data'];
      });

      // Act
      final future = controller.loadData();
      
      // Assert loading state
      expect(controller.isLoading, isTrue);
      expect(controller.error, isNull);

      await future;

      // Assert final state
      expect(controller.isLoading, isFalse);
    });
  });
}
```

## Testing Services

### Testing GetxService

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_instance/getx_instance.dart';

class UserService extends GetxService {
  String? _currentUser;
  List<String> _userHistory = [];

  String? get currentUser => _currentUser;
  List<String> get userHistory => List.unmodifiable(_userHistory);

  void login(String username) {
    _currentUser = username;
    _userHistory.add(username);
  }

  void logout() {
    _currentUser = null;
  }

  bool get isLoggedIn => _currentUser != null;

  @override
  void onInit() {
    super.onInit();
  }
}

void main() {
  group('UserService Tests', () {
    late UserService service;

    setUp(() {
      service = UserService();
      service.onInit();
    });

    tearDown(() {
      service.onClose();
    });

    test('should login user', () {
      // Arrange
      const username = 'testuser';

      // Act
      service.login(username);

      // Assert
      expect(service.currentUser, equals(username));
      expect(service.isLoggedIn, isTrue);
      expect(service.userHistory, contains(username));
    });

    test('should logout user', () {
      // Arrange
      service.login('testuser');
      expect(service.isLoggedIn, isTrue);

      // Act
      service.logout();

      // Assert
      expect(service.currentUser, isNull);
      expect(service.isLoggedIn, isFalse);
    });

    test('should maintain user history', () {
      // Act
      service.login('user1');
      service.logout();
      service.login('user2');

      // Assert
      expect(service.userHistory, equals(['user1', 'user2']));
    });
  });
}
```

### Testing Service Dependencies

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([StorageService])
import 'service_test.mocks.dart';

class StorageService {
  Future<String?> getString(String key) async {
    throw UnimplementedError();
  }

  Future<void> setString(String key, String value) async {
    throw UnimplementedError();
  }
}

class PreferencesService extends GetxService {
  final StorageService _storage;

  PreferencesService(this._storage);

  String _theme = 'light';
  String get theme => _theme;

  Future<void> loadPreferences() async {
    _theme = await _storage.getString('theme') ?? 'light';
  }

  Future<void> setTheme(String theme) async {
    _theme = theme;
    await _storage.setString('theme', theme);
  }
}

void main() {
  group('PreferencesService Tests', () {
    late MockStorageService mockStorage;
    late PreferencesService service;

    setUp(() {
      mockStorage = MockStorageService();
      service = PreferencesService(mockStorage);
    });

    test('should load preferences', () async {
      // Arrange
      when(mockStorage.getString('theme')).thenAnswer((_) async => 'dark');

      // Act
      await service.loadPreferences();

      // Assert
      expect(service.theme, equals('dark'));
      verify(mockStorage.getString('theme')).called(1);
    });

    test('should use default when no preference exists', () async {
      // Arrange
      when(mockStorage.getString('theme')).thenAnswer((_) async => null);

      // Act
      await service.loadPreferences();

      // Assert
      expect(service.theme, equals('light'));
    });

    test('should save theme preference', () async {
      // Act
      await service.setTheme('dark');

      // Assert
      expect(service.theme, equals('dark'));
      verify(mockStorage.setString('theme', 'dark')).called(1);
    });
  });
}
```

## Testing Bindings

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_instance/getx_instance.dart';

class TestBinding implements Bindings {
  @override
  void dependencies() {
    // In real implementation, you would register dependencies here
    print('Dependencies registered');
  }
}

void main() {
  group('Bindings Tests', () {
    test('should create binding', () {
      // Act
      final binding = TestBinding();

      // Assert
      expect(binding, isA<Bindings>());
      expect(binding, isA<BindingsInterface>());
    });

    test('should call dependencies method', () {
      // Arrange
      final binding = TestBinding();

      // Act & Assert
      expect(() => binding.dependencies(), returnsNormally);
    });
  });
}
```

## Integration Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_instance/getx_instance.dart';

class IntegrationTestController with GetLifeCycleMixin {
  final UserService _userService;
  final ApiService _apiService;

  IntegrationTestController(this._userService, this._apiService);

  List<String> _userPosts = [];
  bool _isLoading = false;

  List<String> get userPosts => List.unmodifiable(_userPosts);
  bool get isLoading => _isLoading;

  Future<void> loadUserPosts() async {
    if (!_userService.isLoggedIn) {
      throw Exception('User not logged in');
    }

    _isLoading = true;
    try {
      _userPosts = await _apiService.fetchData();
    } finally {
      _isLoading = false;
    }
  }
}

void main() {
  group('Integration Tests', () {
    late UserService userService;
    late ApiService apiService;
    late IntegrationTestController controller;

    setUp(() {
      userService = UserService();
      apiService = ApiService();
      controller = IntegrationTestController(userService, apiService);
      
      userService.onInit();
      controller.onInit();
    });

    tearDown(() {
      controller.onClose();
      userService.onClose();
    });

    test('should load posts for logged in user', () async {
      // Arrange
      userService.login('testuser');

      // Act
      await controller.loadUserPosts();

      // Assert
      expect(controller.userPosts, isNotEmpty);
      expect(controller.isLoading, isFalse);
    });

    test('should throw error for non-logged user', () async {
      // Act & Assert / تنفيذ وتأكيد
      expect(
        () => controller.loadUserPosts(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

## Widget Testing

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_instance/getx_instance.dart';

class CounterWidget extends StatefulWidget {
  final TestController controller;

  CounterWidget({required this.controller});

  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${widget.controller.counter}'),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.controller.increment();
                });
              },
              child: Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('Widget Tests', () {
    testWidgets('should display counter and increment', (tester) async {
      // Arrange
      final controller = TestController();
      controller.onInit();

      // Act / تنفيذ
      await tester.pumpWidget(
        MaterialApp(
          home: CounterWidget(controller: controller),
        ),
      );

      // Assert initial state / تأكيد الحالة الأولية
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Increment'), findsOneWidget);

      // Act - tap increment button / تنفيذ - النقر على زر الزيادة
      await tester.tap(find.text('Increment'));
      await tester.pump();

      // Assert updated state / تأكيد الحالة المحدثة
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsNothing);

      // Cleanup / تنظيف
      controller.onClose();
    });
  });
}
```

## Mocking Dependencies

### Using Mockito

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// 1. Create mock annotations / إنشاء تعليقات المحاكاة
@GenerateMocks([
  ApiService,
  StorageService,
  NetworkService,
])
import 'mocks.mocks.dart';

void main() {
  group('Mocking Examples', () {
    late MockApiService mockApi;

    setUp(() {
      mockApi = MockApiService();
    });

    test('should mock API response', () async {
      // Arrange
      when(mockApi.fetchData()).thenAnswer((_) async => ['mocked', 'data']);

      // Act
      final result = await mockApi.fetchData();

      // Assert
      expect(result, equals(['mocked', 'data']));
      verify(mockApi.fetchData()).called(1);
    });

    test('should mock API error', () async {
      // Arrange
      when(mockApi.fetchData()).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => mockApi.fetchData(), throwsA(isA<Exception>()));
    });
  });
}
```

### Manual Mocking

```dart
class MockUserService extends GetxService {
  bool _isLoggedIn = false;
  String? _currentUser;

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  String? get currentUser => _currentUser;

  void mockLogin(String username) {
    _currentUser = username;
    _isLoggedIn = true;
  }

  void mockLogout() {
    _currentUser = null;
    _isLoggedIn = false;
  }
}

void main() {
  group('Manual Mock Tests', () {
    test('should use manual mock', () {
      // Arrange
      final mockService = MockUserService();

      // Act
      mockService.mockLogin('testuser');

      // Assert
      expect(mockService.isLoggedIn, isTrue);
      expect(mockService.currentUser, equals('testuser'));
    });
  });
}
```

## Best Practices

### 1. Test Organization

```dart
void main() {
  group('FeatureName', () {
    group('Unit Tests', () {
      // Unit tests here
    });

    group('Integration Tests', () {
      // Integration tests here
    });

    group('Edge Cases', () {
      // Edge case tests here
    });
  });
}
```

### 2. Setup and Teardown

```dart
void main() {
  group('Controller Tests', () {
    late TestController controller;
    late MockService mockService;

    setUp(() {
      // Initialize before each test
      mockService = MockService();
      controller = TestController(mockService);
      controller.onInit();
    });

    tearDown(() {
      // Cleanup after each test
      controller.onClose();
    });

    // Tests here
  });
}
```

### 3. Descriptive Test Names

```dart
test('should increment counter when increment method is called', () {
  // Test implementation
});

test('should throw exception when trying to access data without login', () {
  // Test implementation
});
```

### 4. AAA Pattern (Arrange, Act, Assert)

```dart
test('should calculate total price correctly', () {
  // Arrange
  final cart = ShoppingCart();
  cart.addItem(Product(name: 'Item1', price: 10.0));
  cart.addItem(Product(name: 'Item2', price: 20.0));

  // Act
  final total = cart.calculateTotal();

  // Assert
  expect(total, equals(30.0));
});
```

### 5. Testing Async Operations

```dart
test('should handle async operations correctly', () async {
  // Arrange
  final controller = AsyncController();

  // Act
  await controller.loadData();

  // Assert
  expect(controller.isLoading, isFalse);
  expect(controller.data, isNotEmpty);
});
```

### 6. Error Testing

```dart
test('should handle errors gracefully', () async {
  // Arrange
  when(mockService.fetchData()).thenThrow(Exception('Network error'));

  // Act
  await controller.loadData();

  // Assert
  expect(controller.hasError, isTrue);
  expect(controller.errorMessage, contains('Network error'));
});
```

### 7. Test Coverage

Run test coverage to ensure comprehensive testing:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### 8. Continuous Integration

Add to your CI/CD pipeline:

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter test --coverage
```

## Common Testing Patterns

### 1. Testing State Changes

```dart
test('should update state correctly', () {
  expect(controller.isLoading, isFalse);
  expect(controller.data, isEmpty);

  controller.startLoading();

  // Verify intermediate state
  expect(controller.isLoading, isTrue);

  // Complete operation
  controller.completeLoading(['data']);

  // Verify final state
  expect(controller.isLoading, isFalse);
  expect(controller.data, equals(['data']));
});
```

### 2. Testing Lifecycle

```dart
test('should call lifecycle methods in correct order', () {
  final controller = TestController();
  
  controller.onInit();
  expect(controller.isInitialized, isTrue);

  controller.onReady();
  expect(controller.isReady, isTrue);

  controller.onClose();
  expect(controller.isClosed, isTrue);
});
```

This comprehensive testing guide should help you create robust tests for your GetX Instance implementations.

