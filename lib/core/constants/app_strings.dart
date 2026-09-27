abstract final class AppStrings {
  static const String appName = 'Thaheen';
  static const String coursesTitle = 'دوراتي';
  static const String retry = 'إعادة المحاولة';
  static const String back = 'رجوع';
  static const String backToCourses = 'العودة إلى الدورات';
  static const String minutes = 'دقيقة';
  static const String loading = 'جارٍ التحميل';
  static const String enableDarkMode = 'تفعيل الوضع الداكن';
  static const String enableLightMode = 'تفعيل الوضع الفاتح';

  static const String continueWatching = 'تابع المشاهدة';
  static const String allCourses = 'كل الدورات';
  static const String searchHint = 'ابحث عن دورة';
  static const String clearSearch = 'مسح البحث';
  static const String searchResults = 'نتائج البحث';
  static const String noResultsTitle = 'لا توجد نتائج';
  static const String noResultsMessage =
      'جرّب البحث باسم الدورة أو المحاضر أو أحد الدروس.';

  static const String emptyLessonsTitle = 'عذرًا، لا توجد دروس متاحة حاليًا';
  static const String emptyLessonsMessage =
      'لم تُضَف دروس إلى هذه الدورة بعد. تفقّدها لاحقًا.';
  static const String emptyCoursesTitle = 'عذرًا، لا توجد دورات متاحة حاليًا';
  static const String emptyCoursesMessage = 'ستظهر الدورات هنا فور إضافتها.';
  static const String coursesErrorTitle = 'تعذّر تحميل الدورات';
  static const String coursesErrorMessage =
      'حدث خطأ أثناء قراءة بيانات الدورات. حاول مرة أخرى.';
  static const String courseNotFoundTitle = 'تعذّر العثور على الدورة';
  static const String courseNotFoundMessage =
      'ربما أُزيلت هذه الدورة. عد إلى قائمة الدورات.';

  static const String statusCompleted = 'مكتمل';
  static const String statusInProgress = 'قيد المشاهدة';
  static const String statusNotStarted = 'لم يبدأ';
  static const String statusLocked = 'مقفل';
  static const String statusUnavailable = 'غير متاح';

  static const String play = 'تشغيل';
  static const String pause = 'إيقاف مؤقت';
  static const String replay = 'إعادة التشغيل';
  static const String enterFullscreen = 'ملء الشاشة';
  static const String exitFullscreen = 'الخروج من ملء الشاشة';
  static const String changeSpeed = 'تغيير سرعة التشغيل';
  static const String playbackSpeed = 'سرعة التشغيل';
  static const String nextLesson = 'الدرس التالي';
  static const String startNextLesson = 'ابدأ الدرس التالي';
  static const String nextLessonLocked = 'يُفتح بعد مشاهدة 90% من هذا الدرس';
  static const String videoErrorTitle = 'تعذّر تشغيل هذا الدرس';
  static const String videoErrorMessage = 'ملف الفيديو غير متوفر أو تالف.';
  static const String lessonNotFoundTitle = 'تعذّر العثور على الدرس';
  static const String lessonNotFoundMessage =
      'ربما أُزيل هذا الدرس. عد إلى تفاصيل الدورة.';
  static const String lessonLockedTitle = 'هذا الدرس مقفل';
  static const String lessonLockedMessage =
      'أكمل الدروس السابقة أولًا لفتح هذا الدرس.';

  static String lessonPosition(String sectionTitle, int index, int total) {
    return '$sectionTitle · الدرس $index من $total';
  }

  static String lockedLesson(String previousLessonTitle) {
    return 'هذا الدرس مقفل. أكمل درس «$previousLessonTitle» أولًا لفتحه.';
  }

  static String watchedPercent(int percent) => 'شاهدت $percent%';

  static String remaining(String time) => 'متبقٍ $time';

  static String completedPercent(int percent) => '$percent% مكتمل';

  static String completedOf(int completed, int total) =>
      '$completed من $total مكتملة';

  static String lessonsCount(int count) {
    if (count == 1) return 'درس واحد';
    if (count == 2) return 'درسان';
    if (count >= 3 && count <= 10) return '$count دروس';
    return '$count درسًا';
  }

  static String coursesCount(int count) {
    if (count == 1) return 'دورة واحدة';
    if (count == 2) return 'دورتان';
    if (count >= 3 && count <= 10) return '$count دورات';
    return '$count دورة';
  }
}
