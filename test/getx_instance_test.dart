import 'package:flutter_test/flutter_test.dart';
import 'package:getx_instance/getx_instance.dart';

// Test Models and Controllers / نماذج ومتحكمات الاختبار
class TestController with GetLifeCycleMixin {
  int counter = 0;
  bool isInitialized = false;
  bool isReady = false;
  @override
  bool isClosed = false;

  void increment() {
    counter++;
  }

  void decrement() {
    counter--;
  }

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

class TestService extends GetxService {
  String data = 'initial';
  bool isServiceInitialized = false;

  Future<String> fetchData() async {
    await Future.delayed(Duration(milliseconds: 100));
    return 'fetched_data';
  }

  void updateData(String newData) {
    data = newData;
  }

  @override
  void onInit() {
    super.onInit();
    isServiceInitialized = true;
  }
}

class TestRepository {
  final TestService _service;

  TestRepository(this._service);

  Future<List<String>> getItems() async {
    final data = await _service.fetchData();
    return [data, 'item1', 'item2'];
  }
}

class TestBinding implements Bindings {
  @override
  void dependencies() {
    // Note: These tests are simplified due to GetInterface dependency
    // In a real implementation, you would use:
    // Get.put(TestService());
    // Get.lazyPut(() => TestController());
    // Get.lazyPut(() => TestRepository(Get.find<TestService>()));
  }
}

void main() {
  group('GetX Instance Management Tests', () {
    setUp(() {
      // Reset all instances before each test
      // إعادة تعيين جميع المثيلات قبل كل اختبار
      // Note: Actual reset would be: Get.resetInstance();
    });

    tearDown(() {
      // Clean up after each test
      // تنظيف بعد كل اختبار
      // Note: Actual cleanup would be: Get.resetInstance();
    });

    group('Lifecycle Mixin Tests / اختبارات دورة الحياة', () {
      test(
        'should initialize lifecycle correctly / يجب تهيئة دورة الحياة بشكل صحيح',
        () {
          // Arrange / ترتيب
          final controller = TestController();

          // Act / تنفيذ
          controller.onInit();

          // Assert / تأكيد
          expect(controller.isInitialized, isTrue);
          expect(controller.isClosed, isFalse);
        },
      );

      test(
        'should handle onReady callback / يجب التعامل مع استدعاء onReady',
        () {
          // Arrange / ترتيب
          final controller = TestController();

          // Act / تنفيذ
          controller.onReady();

          // Assert / تأكيد
          expect(controller.isReady, isTrue);
        },
      );

      test(
        'should handle onClose callback / يجب التعامل مع استدعاء onClose',
        () {
          // Arrange / ترتيب
          final controller = TestController();

          // Act / تنفيذ
          controller.onClose();

          // Assert / تأكيد
          expect(controller.isClosed, isTrue);
        },
      );

      test(
        'should handle lifecycle sequence / يجب التعامل مع تسلسل دورة الحياة',
        () async {
          // Arrange / ترتيب
          final controller = TestController();

          // Act / تنفيذ
          controller.onInit();
          await Future.delayed(Duration(milliseconds: 10));
          controller.onReady();

          // Assert / تأكيد
          expect(controller.isInitialized, isTrue);
          expect(controller.isReady, isTrue);
          expect(controller.isClosed, isFalse);

          // Test onClose / اختبار onClose
          controller.onClose();
          expect(controller.isClosed, isTrue);
        },
      );
    });

    group('Service Tests / اختبارات الخدمات', () {
      test(
        'should create service with lifecycle / يجب إنشاء خدمة مع دورة الحياة',
        () {
          // Arrange / ترتيب
          final service = TestService();

          // Act / تنفيذ
          service.onInit();

          // Assert / تأكيد
          expect(service.isServiceInitialized, isTrue);
          expect(service.data, equals('initial'));
        },
      );

      test(
        'should fetch data asynchronously / يجب جلب البيانات بشكل غير متزامن',
        () async {
          // Arrange / ترتيب
          final service = TestService();

          // Act / تنفيذ
          final data = await service.fetchData();

          // Assert / تأكيد
          expect(data, equals('fetched_data'));
        },
      );

      test('should update data correctly / يجب تحديث البيانات بشكل صحيح', () {
        // Arrange / ترتيب
        final service = TestService();
        const newData = 'updated_data';

        // Act / تنفيذ
        service.updateData(newData);

        // Assert / تأكيد
        expect(service.data, equals(newData));
      });
    });

    group('Repository Tests / اختبارات المستودع', () {
      test(
        'should create repository with service dependency / يجب إنشاء مستودع مع تبعية الخدمة',
        () {
          // Arrange / ترتيب
          final service = TestService();
          final repository = TestRepository(service);

          // Act & Assert / تنفيذ وتأكيد
          expect(repository, isA<TestRepository>());
        },
      );

      test(
        'should get items from repository / يجب الحصول على العناصر من المستودع',
        () async {
          // Arrange / ترتيب
          final service = TestService();
          final repository = TestRepository(service);

          // Act / تنفيذ
          final items = await repository.getItems();

          // Assert / تأكيد
          expect(items, isA<List<String>>());
          expect(items.length, equals(3));
          expect(items.first, equals('fetched_data'));
          expect(items, contains('item1'));
          expect(items, contains('item2'));
        },
      );
    });

    group('Controller Tests / اختبارات المتحكم', () {
      test('should increment counter / يجب زيادة العداد', () {
        // Arrange / ترتيب
        final controller = TestController();

        // Act / تنفيذ
        controller.increment();

        // Assert / تأكيد
        expect(controller.counter, equals(1));
      });

      test('should decrement counter / يجب تقليل العداد', () {
        // Arrange / ترتيب
        final controller = TestController();
        controller.counter = 5;

        // Act / تنفيذ
        controller.decrement();

        // Assert / تأكيد
        expect(controller.counter, equals(4));
      });

      test(
        'should handle multiple operations / يجب التعامل مع عمليات متعددة',
        () {
          // Arrange / ترتيب
          final controller = TestController();

          // Act / تنفيذ
          controller.increment();
          controller.increment();
          controller.decrement();

          // Assert / تأكيد
          expect(controller.counter, equals(1));
        },
      );
    });

    group('Bindings Tests / اختبارات الربطات', () {
      test('should create binding instance / يجب إنشاء مثيل الربط', () {
        // Arrange & Act / ترتيب وتنفيذ
        final binding = TestBinding();

        // Assert / تأكيد
        expect(binding, isA<Bindings>());
        expect(binding, isA<BindingsInterface>());
      });

      test('should call dependencies method / يجب استدعاء طريقة التبعيات', () {
        // Arrange / ترتيب
        final binding = TestBinding();

        // Act / تنفيذ
        // This should not throw any exceptions
        // هذا يجب ألا يرمي أي استثناءات
        expect(() => binding.dependencies(), returnsNormally);
      });
    });

    group('Integration Tests / اختبارات التكامل', () {
      test(
        'should work with service and repository together / يجب العمل مع الخدمة والمستودع معاً',
        () async {
          // Arrange / ترتيب
          final service = TestService();
          service.onInit();
          final repository = TestRepository(service);

          // Act / تنفيذ
          service.updateData('custom_data');
          final items = await repository.getItems();

          // Assert / تأكيد
          expect(service.isServiceInitialized, isTrue);
          expect(items, isA<List<String>>());
          expect(items.length, equals(3));
        },
      );

      test(
        'should handle controller with lifecycle / يجب التعامل مع المتحكم مع دورة الحياة',
        () async {
          // Arrange / ترتيب
          final controller = TestController();

          // Act / تنفيذ
          controller.onInit();
          controller.increment();
          controller.increment();
          await Future.delayed(Duration(milliseconds: 10));
          controller.onReady();

          // Assert / تأكيد
          expect(controller.isInitialized, isTrue);
          expect(controller.isReady, isTrue);
          expect(controller.counter, equals(2));
          expect(controller.isClosed, isFalse);

          // Cleanup / تنظيف
          controller.onClose();
          expect(controller.isClosed, isTrue);
        },
      );
    });

    group('Edge Cases / الحالات الحدية', () {
      test(
        'should handle multiple lifecycle calls / يجب التعامل مع استدعاءات دورة الحياة المتعددة',
        () {
          // Arrange / ترتيب
          final controller = TestController();

          // Act / تنفيذ
          controller.onInit();
          controller.onInit(); // Second call should not cause issues

          // Assert / تأكيد
          expect(controller.isInitialized, isTrue);
        },
      );

      test(
        'should handle service operations after initialization / يجب التعامل مع عمليات الخدمة بعد التهيئة',
        () async {
          // Arrange / ترتيب
          final service = TestService();
          service.onInit();

          // Act / تنفيذ
          service.updateData('test_data');
          final fetchedData = await service.fetchData();

          // Assert / تأكيد
          expect(service.data, equals('test_data'));
          expect(fetchedData, equals('fetched_data'));
          expect(service.isServiceInitialized, isTrue);
        },
      );

      test(
        'should handle repository with uninitialized service / يجب التعامل مع المستودع مع خدمة غير مهيأة',
        () async {
          // Arrange / ترتيب
          final service = TestService();
          final repository = TestRepository(service);

          // Act / تنفيذ
          final items = await repository.getItems();

          // Assert / تأكيد
          expect(items, isA<List<String>>());
          expect(
            service.isServiceInitialized,
            isFalse,
          ); // Service not initialized
        },
      );
    });
  });
}
