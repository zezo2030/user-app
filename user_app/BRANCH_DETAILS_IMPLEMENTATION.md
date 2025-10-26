# صفحة تفاصيل الفرع - Branch Details Page

## نظرة عامة
تم إنشاء صفحة تفاصيل الفرع بتصميم فريد وجذاب تعرض جميع المعلومات الخاصة بالفرع مع إضافة ميزات تفاعلية مثل المفضلة، المشاركة، والحجز.

## ✅ المشاكل المحلولة
- **ProviderNotFoundException**: تم حل مشكلة عدم وجود GetBranchDetailsUseCase في context من خلال استخدام `sl<GetBranchDetailsUseCase>()` بدلاً من `context.read()`
- **Dependency Injection**: تم التأكد من تسجيل جميع dependencies بشكل صحيح في home_injection.dart
- **Type Safety**: تم إضافة types صحيحة لجميع المتغيرات والـ parameters
- **404 API Error**: تم إصلاح endpoint من `/branches/{id}` إلى `/content/branches/{id}` ليتطابق مع الـ backend
- **Field Mapping**: تم إصلاح mapping الحقول من `name_ar`, `name_en` إلى `nameAr`, `nameEn` في BranchModel
- **Build Runner**: تم تشغيل build_runner لتحديث generated files

## المكونات المنشأة

### 1. Data Layer
- **HomeRemoteDataSource**: إضافة method `getBranchDetails(String branchId)`
- **HomeRepositoryImpl**: تنفيذ method `getBranchDetails` في Repository
- **API Endpoint**: `/branches/{id}` في ApiConstants

### 2. Domain Layer
- **GetBranchDetailsUseCase**: use case جديد لجلب تفاصيل الفرع
- **HomeRepository**: إضافة abstract method للـ repository

### 3. Presentation Layer

#### الصفحة الرئيسية
- **BranchDetailsPage**: صفحة تفاصيل الفرع الرئيسية مع تصميم عصري

#### Widgets مخصصة
- **BranchHeaderSection**: عرض الصورة والمعلومات الأساسية مع gradient جذاب
- **BranchInfoCard**: كارد لعرض معلومة محددة مع أيقونات
- **WorkingHoursWidget**: عرض ساعات العمل بشكل منظم
- **AmenitiesGrid**: عرض المرافق والخدمات في grid مع أيقونات مناسبة

#### State Management
- **BranchDetailsCubit**: إدارة حالة صفحة التفاصيل (loading, loaded, error)
- **BranchDetailsState**: تعريف states للصفحة

### 4. Navigation
- إضافة route جديد: `/branch-details` في main.dart
- تحديث BranchCard للتنقل عند الضغط على "عرض التفاصيل"

### 5. Translations
- إضافة مفاتيح الترجمة العربية والإنجليزية:
  - `branch_details`, `description`, `working_hours`, `amenities`
  - `contact_info`, `add_to_favorites`, `share`, `call_now`
  - `open_now`, `closed_now`, `opens_at`, `closes_at`
  - أيام الأسبوع بالعربية والإنجليزية

### 6. Dependency Injection
- تسجيل `GetBranchDetailsUseCase` و `BranchDetailsCubit` في home_injection.dart

## التصميم المطبق

### الألوان والأسلوب
- استخدام gradients جذابة للـ header
- Material 3 design مع shadows ناعمة
- أيقونات مناسبة لكل نوع من المعلومات
- Animation عند الانتقال للصفحة

### المكونات البصرية
1. **Hero Header**: صورة كبيرة في الأعلى مع gradient overlay ونمط خلفية
2. **Floating Action Buttons**: أزرار عائمة للمفضلة والمشاركة
3. **Info Cards**: كروت منفصلة لكل قسم من المعلومات
4. **Bottom Action Bar**: شريط ثابت في الأسفل لزر الحجز وعرض الخريطة
5. **Chips**: لعرض المرافق والخدمات مع أيقونات مناسبة
6. **Working Hours**: عرض ساعات العمل بشكل منظم

## الميزات التفاعلية
- زر الرجوع في الـ header
- أزرار المفضلة والمشاركة
- زر الاتصال (جاهز للتطبيق مع url_launcher)
- زر عرض الخريطة
- زر الحجز الرئيسي

## ملاحظات التنفيذ
- استخدام `Hero` widget للانتقال السلس من الكارد للصفحة
- معالجة حالات الخطأ بشكل واضح
- دعم RTL/LTR بشكل كامل
- استخدام بيانات من API الموجود حالياً
- تصميم responsive يتكيف مع أحجام الشاشات المختلفة

## الملفات المنشأة/المحدثة

### ملفات جديدة
- `lib/features/home/domain/usecases/get_branch_details_usecase.dart`
- `lib/features/home/presentation/cubit/branch_details_cubit.dart`
- `lib/features/home/presentation/cubit/branch_details_state.dart`
- `lib/features/home/presentation/pages/branch_details_page.dart`
- `lib/features/home/presentation/widgets/branch_header_section.dart`
- `lib/features/home/presentation/widgets/branch_info_card.dart`
- `lib/features/home/presentation/widgets/working_hours_widget.dart`
- `lib/features/home/presentation/widgets/amenities_grid.dart`

### ملفات محدثة
- `lib/core/constants/api_constants.dart`
- `lib/features/home/data/datasources/home_remote_datasource.dart`
- `lib/features/home/data/repositories/home_repository_impl.dart`
- `lib/features/home/domain/repositories/home_repository.dart`
- `lib/features/home/presentation/widgets/branch_card.dart`
- `lib/main.dart`
- `lib/features/home/di/home_injection.dart`
- `assets/translations/ar.json`
- `assets/translations/en.json`

## الاستخدام
للوصول لصفحة تفاصيل الفرع، اضغط على زر "عرض التفاصيل" في أي كارد فرع في الصفحة الرئيسية.

## التطوير المستقبلي
- إضافة وظيفة الاتصال باستخدام url_launcher
- إضافة وظيفة عرض الخريطة
- إضافة وظيفة الحجز
- إضافة وظيفة المفضلة مع التخزين المحلي
- إضافة وظيفة المشاركة
- إضافة صور حقيقية للفروع
- إضافة تقييمات الفروع
