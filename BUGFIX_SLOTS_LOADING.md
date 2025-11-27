# إصلاح مشكلة: عدم ظهور فتحات الوقت عند اختيار التاريخ

## المشكلة
عند اختيار التاريخ في معالج الحجز، لم تظهر فتحات الوقت المتاحة.

## السبب
كانت المشكلة في كيفية إنشاء وإدارة `BookingCubit`:

**الكود القديم:**
```dart
@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (context) => booking_di.sl<BookingCubit>(),
    child: BlocConsumer<BookingCubit, BookingState>(
      // ...
    ),
  );
}

void _fetchSlotsForDate() {
  // ...
  context.read<BookingCubit>().fetchHallSlots(...);
}
```

**المشكلة:**
- عند استدعاء `context.read<BookingCubit>()` داخل الدوال مثل `_fetchSlotsForDate()`، كان الـ context لا يمكنه الوصول إلى الـ Cubit لأنه يتم إنشاؤه في نفس مستوى البناء
- هذا يسبب عدم إرسال طلب تحميل الـ slots إلى الـ API

## الحل

### 1. إنشاء instance من BookingCubit في initState
```dart
class _HallBookingWizardPageState extends State<HallBookingWizardPage> {
  late BookingCubit _bookingCubit;

  @override
  void initState() {
    super.initState();
    _bookingCubit = booking_di.sl<BookingCubit>();
    // ...
  }
  
  @override
  void dispose() {
    _bookingCubit.close();
    super.dispose();
  }
}
```

### 2. استخدام BlocProvider.value بدلاً من BlocProvider
```dart
@override
Widget build(BuildContext context) {
  return BlocProvider.value(
    value: _bookingCubit,
    child: BlocConsumer<BookingCubit, BookingState>(
      // ...
    ),
  );
}
```

### 3. استخدام instance مباشرة بدلاً من context.read
```dart
void _fetchSlotsForDate() {
  // ...
  _bookingCubit.fetchHallSlots(
    hallId: widget.hallId,
    date: normalizedDate,
    durationHours: durationHours,
    persons: personsCount,
  );
}

void _requestQuote() {
  // ...
  _bookingCubit.getQuote(...);
}

void _confirmBooking() {
  // ...
  _bookingCubit.createBooking(...);
}
```

### 4. إضافة Debug Prints للمتابعة
```dart
void _fetchSlotsForDate() {
  print('🔍 Fetching slots for date: $normalizedDate, hallId: ${widget.hallId}');
  _bookingCubit.fetchHallSlots(...);
}

// في BlocListener
else if (state is SlotsLoading) {
  print('⏳ Slots loading...');
  // ...
}
else if (state is SlotsLoaded) {
  print('✅ Slots loaded: ${state.hallSlots.slots.length} slots');
  // ...
}
else if (state is SlotsError) {
  print('❌ Slots error: ${state.message}');
  // ...
}
```

## الفوائد

1. **إدارة أفضل للحالة**: الـ Cubit يتم إنشاؤه مرة واحدة في initState وتتم إدارته بشكل صحيح
2. **الوصول المباشر**: استخدام instance مباشرة يضمن عدم حدوث مشاكل في الوصول
3. **Lifecycle صحيح**: يتم إغلاق الـ Cubit في dispose لتجنب تسرب الذاكرة
4. **Debug أسهل**: طباعة الحالات تساعد في تتبع المشكلات

## التحقق من الإصلاح

### الخطوات للاختبار:
1. افتح التطبيق واذهب إلى تفاصيل أي صالة
2. اضغط على "احجز الآن" لفتح معالج الحجز
3. اختر تاريخ من التقويم
4. يجب أن تظهر رسالة في Console: `🔍 Fetching slots for date: ...`
5. ثم: `⏳ Slots loading...`
6. ثم: `✅ Slots loaded: X slots`
7. يجب أن تظهر فتحات الوقت المتاحة في الواجهة

### في حالة وجود مشكلة:
- تحقق من الـ Console للرسائل
- إذا ظهرت `❌ Slots error:` تحقق من:
  - اتصال الإنترنت
  - صحة الـ hallId
  - استجابة الـ API
  - صلاحيات المستخدم

## الملفات المعدلة

- `lib/features/booking/presentation/pages/hall_booking_wizard_page.dart`
  - إضافة `late BookingCubit _bookingCubit`
  - تعديل `initState()` و `dispose()`
  - تغيير `BlocProvider` إلى `BlocProvider.value`
  - استبدال `context.read<BookingCubit>()` بـ `_bookingCubit`
  - إضافة debug prints

## الحالة الآن
✅ تم الإصلاح والاختبار
✅ لا توجد أخطاء Linter
✅ يعمل تحميل الفتحات بشكل صحيح
✅ تظهر الفتحات المتاحة عند اختيار التاريخ

## ملاحظات إضافية

### لماذا BlocProvider.value؟
- `BlocProvider` ينشئ instance جديد ويديره
- `BlocProvider.value` يستخدم instance موجود مسبقاً
- في حالتنا، نحتاج للوصول إلى نفس الـ instance من خارج build method

### متى نستخدم context.read؟
- استخدم `context.read<Cubit>()` عندما يكون الـ Cubit يتم إنشاؤه في widget أعلى في الشجرة
- في حالتنا، نحتاج الوصول للـ Cubit قبل بناء الـ widget tree، لذلك نستخدم instance مباشرة

### أفضل الممارسات
```dart
// ✅ جيد - إنشاء في initState واستخدام مباشر
late MyCubit _cubit;
void initState() {
  _cubit = sl<MyCubit>();
}
void someMethod() {
  _cubit.doSomething();
}

// ✅ جيد أيضاً - context.read من داخل build أو event handlers
onPressed: () {
  context.read<MyCubit>().doSomething();
}

// ❌ سيء - إنشاء في build واستخدام من خارجه
Widget build(context) {
  return BlocProvider(
    create: (_) => MyCubit(),
    child: ...
  );
}
void someMethod() {
  context.read<MyCubit>(); // قد لا يعمل!
}
```

