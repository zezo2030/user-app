# Booking Wizard Flow Diagram

## Visual Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    إتمام الحجز (Booking Wizard)              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Progress Indicator                                          │
│  ●────────○────────○────────○                               │
│  ✓        2        3        4                                │
│  التاريخ   الإضافات  الأشخاص  المراجعة                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Step 1: التاريخ والوقت (Date & Time)                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  📅 اختر التاريخ                                             │
│  ┌──────────────────┐                                        │
│  │  [Date Picker]   │                                        │
│  └──────────────────┘                                        │
│                                                              │
│  🕐 اختر موعد الحجز                                          │
│  ┌──────────────────────────────────────┐                   │
│  │  [Slot Selector - Available Times]   │                   │
│  │  • 09:00 - 10:00  [Selected ✓]      │                   │
│  │  • 10:00 - 11:00  [Available]        │                   │
│  │  • 11:00 - 12:00  [Booked]          │                   │
│  └──────────────────────────────────────┘                   │
│                                                              │
│  ⏱️ المدة: [2 ساعات] [▼]                                    │
│                                                              │
│  Validation: ✅ Date selected, ✅ Slot selected              │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼ [متابعة]
                           
┌─────────────────────────────────────────────────────────────┐
│  Step 2: الإضافات (Add-ons)                                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  اختر الإضافات (اختياري)                                    │
│                                                              │
│  ☐ Decoration Package        150 ريال                       │
│  ☑ Sound System              100 ريال  ✓                    │
│  ☐ Lighting Package           80 ريال                       │
│  ☐ Catering Service          200 ريال                       │
│                                                              │
│  💰 Quote updates in real-time                              │
│                                                              │
│  Validation: ✅ Always can proceed (optional)                │
└─────────────────────────────────────────────────────────────┘
                           │
           [السابق] ◄─────────────► [متابعة]
                           │
                           ▼
                           
┌─────────────────────────────────────────────────────────────┐
│  Step 3: عدد الأشخاص (Number of Persons)                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  أدخل عدد الأشخاص                                           │
│  ┌──────────────────┐                                        │
│  │  [-]  10  [+]    │                                        │
│  └──────────────────┘                                        │
│  الحد الأدنى: شخص واحد                                       │
│                                                              │
│  📱 رقم الهاتف (اختياري)                                     │
│  ┌──────────────────┐                                        │
│  │  05XXXXXXXX      │                                        │
│  └──────────────────┘                                        │
│                                                              │
│  Validation: ✅ Persons >= 1                                 │
└─────────────────────────────────────────────────────────────┘
                           │
           [السابق] ◄─────────────► [متابعة]
                           │
                           ▼
                           
┌─────────────────────────────────────────────────────────────┐
│  Step 4: المراجعة والتأكيد (Review & Confirm)                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  📋 ملخص الحجز                                               │
│  ┌──────────────────────────────────────┐                   │
│  │  الصالة: Test Hall                  │                   │
│  │  التاريخ: 2025-11-15                │                   │
│  │  الوقت: 09:00 - 11:00 (2 ساعات)    │                   │
│  │  الأشخاص: 10                        │                   │
│  │  الإضافات: Sound System             │                   │
│  └──────────────────────────────────────┘                   │
│                                                              │
│  💰 تفاصيل السعر                                             │
│  ┌──────────────────────────────────────┐                   │
│  │  السعر الأساسي:      500 ريال        │                   │
│  │  الإضافات:          100 ريال        │                   │
│  │  الخصم:            -50 ريال         │                   │
│  │  ─────────────────────────────        │                   │
│  │  الإجمالي:          550 ريال        │                   │
│  └──────────────────────────────────────┘                   │
│                                                              │
│  🎫 كود الخصم                                                │
│  ┌──────────────────┬────────┐                              │
│  │  SUMMER2025      │ [تطبيق] │                              │
│  └──────────────────┴────────┘                              │
│                                                              │
│  📝 الطلبات الخاصة (اختياري)                                │
│  ┌──────────────────────────────────────┐                   │
│  │  أي طلبات خاصة أو ملاحظات...         │                   │
│  └──────────────────────────────────────┘                   │
│                                                              │
│  Validation: ✅ All steps completed                          │
└─────────────────────────────────────────────────────────────┘
                           │
           [السابق] ◄─────────────► [تأكيد الحجز] 🎉
                           │
                           ▼
                           
┌─────────────────────────────────────────────────────────────┐
│  ✅ Success: Navigate to Booking Details Page                │
│                                                              │
│  📱 Booking Confirmation                                     │
│  🎫 QR Code                                                  │
│  📧 Email/SMS Notification                                   │
└─────────────────────────────────────────────────────────────┘
```

## State Transitions

```
Initial State
    │
    ├─ selectedDate: null
    ├─ selectedSlot: null
    ├─ selectedAddOns: []
    ├─ personsCount: 10
    └─ currentStep: 0

Step 0 (Date & Time)
    │
    ├─ User selects date
    │  └─> fetchHallSlots() called
    │      └─> Slots loaded/displayed
    │
    ├─ User selects slot
    │  ├─> selectedSlot updated
    │  ├─> maxDuration calculated
    │  └─> requestQuote() called
    │
    ├─ User adjusts duration
    │  └─> requestQuote() called
    │
    └─ Validation: date && slot
       └─> Next button enabled

Step 1 (Add-ons)
    │
    ├─ Add-ons loaded on init
    ├─ User toggles selections
    │  └─> requestQuote() called
    │
    └─ Validation: always true
       └─> Next button enabled

Step 2 (Persons)
    │
    ├─ User adjusts count
    │  └─> requestQuote() called
    │
    ├─ User enters phone (optional)
    │
    └─ Validation: persons >= 1
       └─> Next button enabled

Step 3 (Review)
    │
    ├─ All data displayed
    ├─ Quote refreshed
    │
    ├─ User enters coupon
    │  └─> requestQuote() called
    │
    ├─ User enters special requests
    │
    └─ User confirms
       └─> createBooking() called
           └─> Navigate to BookingDetailsPage

Error Handling
    │
    ├─ SlotsError: Display error message
    ├─ QuoteError: Show snackbar, continue
    ├─ BookingError: Show snackbar, stay on review
    └─ Past time check: Prevent booking with validation
```

## Component Architecture

```
HallBookingWizardPage (StatefulWidget)
├── BlocProvider<BookingCubit>
│   └── BlocConsumer<BookingCubit, BookingState>
│       ├── Scaffold
│       │   ├── AppBar (title)
│       │   ├── Body Column
│       │   │   ├── _buildProgressIndicator()
│       │   │   │   ├── Step circles (1-4)
│       │   │   │   ├── Step titles
│       │   │   │   └── Progress bars
│       │   │   │
│       │   │   └── _buildStepContent()
│       │   │       ├── Step 0: _buildStep1DateTimeSlot()
│       │   │       │   ├── DateTimeSelector
│       │   │       │   ├── SlotSelector
│       │   │       │   └── DurationSelector
│       │   │       │
│       │   │       ├── Step 1: _buildStep2AddOns()
│       │   │       │   └── AddOnsSelector
│       │   │       │
│       │   │       ├── Step 2: _buildStep3Persons()
│       │   │       │   ├── PersonsInput
│       │   │       │   └── ContactPhoneInput
│       │   │       │
│       │   │       └── Step 3: _buildStep4Review()
│       │   │           ├── BookingSummaryCard
│       │   │           ├── PriceBreakdownCard
│       │   │           ├── CouponInputWidget
│       │   │           └── SpecialRequestsInput
│       │   │
│       │   └── bottomNavigationBar: _buildBottomBar()
│       │       ├── Back button (if step > 0)
│       │       └── Next/Confirm button
│       │
│       └── BlocListener handlers
│           ├── BookingSuccessWithData → Navigate
│           ├── BookingError → Show error
│           ├── QuoteLoaded → Update state
│           ├── SlotsLoaded → Update state
│           └── Error states → Show snackbar
```

## Button State Logic

```
Next Button Enabled When:
├── Step 0: selectedDate != null && selectedSlot != null
├── Step 1: always true (add-ons optional)
├── Step 2: personsCount >= 1
└── Step 3: always true (reached final step)

Button Text:
├── Steps 0-2: "متابعة" (Continue)
└── Step 3: "تأكيد الحجز" (Confirm Booking)

Button Loading State:
└── Shows spinner when state is BookingLoading
```

## Color Scheme

```
Primary Gradient: #FF5CAB → #FF6A00
├── Active step indicator
├── Completed step indicator  
├── Progress bar (completed)
└── Enabled buttons

Secondary Colors:
├── Inactive steps: grey.shade300
├── Disabled text: grey.shade600
└── Background: white with shadows
```

## Responsive Behavior

```
Layout:
├── Header: Fixed (AppBar + Progress)
├── Content: Scrollable (SingleChildScrollView)
└── Footer: Fixed (BottomNavigationBar)

Padding:
├── Horizontal: 16px
├── Vertical sections: 16px
└── Card padding: 16px

Touch Targets:
├── Buttons: 48px minimum height
├── Step circles: 32px
└── Form inputs: Standard Material sizes
```

## Accessibility Considerations

```
✅ Semantic labels for screen readers
✅ Color contrast meets WCAG standards
✅ Touch targets meet 48dp minimum
✅ Clear focus indicators
✅ Descriptive error messages
✅ Progress announced to screen readers
✅ RTL support for Arabic
```

