// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/widgets/season_effect.dart';
import 'package:my_diary/widgets/season_effect_provider.dart';
import 'package:my_diary/widgets/health_condition_dialog.dart';
import 'package:my_diary/widgets/draggable_lightbulb_button.dart';
import 'package:my_diary/widgets/draggable_chat_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ScheduleEvent {
  final String title;
  final String time;
  final IconData icon;
  final Color color;
  final DateTime date;

  ScheduleEvent({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
    required this.date,
  });
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  List<dynamic> _userConditions = [];
  bool _isLoadingConditions = true;
  List<dynamic> _todayMedications = [];
  bool _isLoadingMedications = true;
  Set<DateTime> _medicationDates = {};

  @override
  void initState() {
    super.initState();
    _loadUserConditions();
    _loadTodayMedications();
    // Don't call _loadMedicationDates here - will be called after conditions load
  }

  Future<void> _loadUserConditions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) {
        setState(() => _isLoadingConditions = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health/user/conditions'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Backend trả về {success: true, conditions: [...]}
          final conditions = data['conditions'];
          _userConditions = (conditions is List) ? conditions : [];
          _isLoadingConditions = false;
        });
        // Load medication dates AFTER conditions are loaded
        await _loadMedicationDates();
      } else {
        debugPrint(
          'Failed to load conditions: ${response.statusCode} ${response.body}',
        );
        setState(() => _isLoadingConditions = false);
      }
    } catch (e) {
      debugPrint('Error loading user conditions: $e');
      setState(() => _isLoadingConditions = false);
    }
  }

  Future<void> _loadTodayMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) {
        setState(() => _isLoadingMedications = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/medications/today'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Backend có thể trả về {success: true, medications: [...]} hoặc array trực tiếp
          if (data is Map && data['medications'] != null) {
            _todayMedications = (data['medications'] is List)
                ? data['medications']
                : [];
          } else if (data is List) {
            _todayMedications = data;
          } else {
            _todayMedications = [];
          }
          _isLoadingMedications = false;
        });
      } else {
        debugPrint(
          'Failed to load medications: ${response.statusCode} ${response.body}',
        );
        setState(() => _isLoadingMedications = false);
      }
    } catch (e) {
      debugPrint('Error loading medications: $e');
      setState(() => _isLoadingMedications = false);
    }
  }

  Future<void> _loadMedicationDates() async {
    try {
      Set<DateTime> scheduleDates = {};
      final now = DateTime.now();

      // Duyệt qua tất cả các health conditions của user
      for (var condition in _userConditions) {
        // Chỉ thêm ngày nếu có medication_times
        final medicationTimes = condition['medication_times'];
        if (medicationTimes == null ||
            (medicationTimes is List && medicationTimes.isEmpty)) {
          continue;
        }

        DateTime? startDate;
        DateTime? endDate;

        // Lấy ngày bắt đầu điều trị
        if (condition['treatment_start_date'] != null) {
          try {
            startDate = DateTime.parse(condition['treatment_start_date']);
          } catch (e) {
            // Fallback to created_at
            if (condition['created_at'] != null) {
              try {
                startDate = DateTime.parse(condition['created_at']);
              } catch (e) {
                continue; // Skip if no valid start date
              }
            }
          }
        }

        // Lấy ngày kết thúc điều trị
        if (condition['treatment_end_date'] != null) {
          try {
            endDate = DateTime.parse(condition['treatment_end_date']);
          } catch (e) {
            // No end date - ongoing treatment
          }
        }

        if (startDate == null) continue;

        // Thêm các ngày trong khoảng thời gian điều trị (tối đa 90 ngày từ hôm nay)
        final maxDate = endDate ?? now.add(const Duration(days: 90));
        final minDate =
            startDate.isBefore(now.subtract(const Duration(days: 90)))
            ? now.subtract(const Duration(days: 90))
            : startDate;

        for (
          DateTime date = minDate;
          date.isBefore(maxDate.add(const Duration(days: 1))) &&
              date.isBefore(now.add(const Duration(days: 90)));
          date = date.add(const Duration(days: 1))
        ) {
          scheduleDates.add(DateTime(date.year, date.month, date.day));
        }
      }

      setState(() {
        _medicationDates = scheduleDates;
      });
    } catch (e) {
      debugPrint('Error loading medication dates: $e');
    }
  }

  Future<void> _markMedicationTaken(dynamic medication) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) return;

      // Get condition_id from user_condition
      int? conditionId;
      for (var condition in _userConditions) {
        if (condition['user_condition_id'] == medication['user_condition_id']) {
          conditionId = condition['condition_id'];
          break;
        }
      }

      // Load drugs for this condition first
      List<dynamic> conditionDrugs = [];
      if (conditionId != null) {
        final drugsResponse = await http.get(
          Uri.parse(
            '${ApiConfig.baseUrl}/api/medications/conditions/$conditionId/drugs',
          ),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (drugsResponse.statusCode == 200) {
          final drugsData = json.decode(drugsResponse.body);
          conditionDrugs = drugsData['drugs'] ?? [];
        }
      }

      // Show drug selection dialog with condition drugs and option to see all
      if (!mounted) return;
      final selectedDrug = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _DrugSelectionDialog(
          conditionDrugs: conditionDrugs,
          userConditionIds: _userConditions
              .where((c) => c['status'] == 'active')
              .map((c) => c['condition_id'] as int)
              .toList(),
          medication: medication,
        ),
      );

      if (selectedDrug == null) return;

      // Log medication with selected drug
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/medications/log'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'drug_id': selectedDrug['drug_id'],
          'user_condition_id': medication['user_condition_id'],
          'medication_date': _selectedDate.toIso8601String().split('T')[0],
          'medication_time': medication['medication_time'],
        }),
      );

      if (response.statusCode == 200) {
        _loadTodayMedications();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(
                  '${l10n.medicationMarked}: ${selectedDrug['name_vi']}',
                );
              },
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        final error = json.decode(response.body);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'] ?? 'Lỗi đánh dấu đã uống')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text('${l10n.errorColon} $e');
            },
          ),
        ),
      );
    }
  }

  void _showHealthConditionDialog() {
    showDialog(
      context: context,
      builder: (context) => HealthConditionDialog(
        onConditionAdded: () {
          _loadUserConditions();
          _loadTodayMedications();
          _loadMedicationDates();
        },
      ),
    );
  }

  // Không còn sử dụng _events cũ - chỉ dùng lịch uống thuốc từ API
  List<ScheduleEvent> _getEventsForDate(DateTime date) {
    // Trả về empty list - UI sẽ hiển thị medications thay vì events
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final seasonNotifier = SeasonEffectNotifier.maybeOf(context);

    return SeasonEffect(
      currentDate: _selectedDate,
      enabled: seasonNotifier?.enabled ?? true,
      child: Container(
        color: (seasonNotifier?.hasBackground ?? false)
            ? Colors.transparent
            : FitnessAppTheme.background,
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              // Main page content - put most content inside the scroll view
              Column(
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  appBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom:
                            kBottomNavigationBarHeight +
                            MediaQuery.of(context).padding.bottom +
                            80.0, // Extra space for bottom bar + FAB
                      ),
                      child: Column(
                        children: <Widget>[
                          if (!_isLoadingConditions &&
                              _userConditions.isNotEmpty)
                            _buildUserConditionsCard(),
                          if (!_isLoadingMedications &&
                              _todayMedications.isNotEmpty)
                            _buildTodayMedicationsCard(),
                          calendarView(), // Always show calendar by default
                          const SizedBox(height: 16),
                          _getEventsForDate(_selectedDate).isEmpty
                              ? emptyState()
                              : eventsListContent(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Positioned floating heart button (avoids nested Scaffold FAB)
              Positioned(
                right: 16.0,
                bottom:
                    kBottomNavigationBarHeight +
                    MediaQuery.of(context).padding.bottom +
                    8.0,
                child: FloatingActionButton(
                  onPressed: _showHealthConditionDialog,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.favorite, color: Colors.white),
                ),
              ),

              // Draggable chat button
              const DraggableChatButton(),
              // Draggable lightbulb button for smart suggestions
              const DraggableLightbulbButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.health,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                letterSpacing: 1.2,
                color: FitnessAppTheme.darkerText,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.today, color: FitnessAppTheme.grey, size: 24),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _focusedMonth = DateTime.now();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget calendarView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: FitnessAppTheme.grey.withAlpha((0.2 * 255).round()),
            offset: const Offset(1.1, 1.1),
            blurRadius: 8.0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header với tháng/năm và nút điều hướng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    color: FitnessAppTheme.grey,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month - 1,
                      );
                    });
                  },
                ),
                Builder(
                  builder: (context) {
                    return Text(
                      '${_getMonthName(_focusedMonth.month, context)} ${_focusedMonth.year}',
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: FitnessAppTheme.darkerText,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    color: FitnessAppTheme.grey,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          // Các ngày trong tuần
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              final days = [
                l10n.sunday,
                l10n.monday,
                l10n.tuesday,
                l10n.wednesday,
                l10n.thursday,
                l10n.friday,
                l10n.saturday,
              ];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: days
                      .map(
                        (day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                                color: FitnessAppTheme.grey,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
          // Grid các ngày trong tháng
          _buildCalendarGrid(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final startingWeekday = firstDayOfMonth.weekday % 7; // 0 = CN, 1 = T2, ...

    List<Widget> dayWidgets = [];

    // Thêm các ô trống cho các ngày của tháng trước
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(Container());
    }

    // Thêm các ngày trong tháng
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected =
          _selectedDate.year == date.year &&
          _selectedDate.month == date.month &&
          _selectedDate.day == date.day;
      final hasEvents = _getEventsForDate(date).isNotEmpty;
      final isToday =
          DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;
      final hasMedication = _medicationDates.any(
        (medDate) =>
            medDate.year == date.year &&
            medDate.month == date.month &&
            medDate.day == date.day,
      );

      dayWidgets.add(
        InkWell(
          onTap: () {
            setState(() {
              _selectedDate = date;
              SeasonEffectNotifier.maybeOf(context)?.setDate(date);
            });
          },
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue
                  : isToday
                  ? Colors.blue.withAlpha((0.1 * 255).round())
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: hasEvents && !isSelected
                  ? Border.all(
                      color: Colors.blue.withAlpha((0.3 * 255).round()),
                      width: 1,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? Colors.blue
                          : FitnessAppTheme.darkerText,
                    ),
                  ),
                ),
                if (hasMedication)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (value * 0.2),
                          child: Transform.rotate(
                            angle: (value - 0.5) * 0.3,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.red[400],
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3 * value),
                                    blurRadius: 4 * value,
                                    spreadRadius: 1 * value,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.medication,
                                size: 8,
                                color: isSelected
                                    ? Colors.red[400]
                                    : Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        children: dayWidgets,
      ),
    );
  }

  String _getMonthName(int month, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final months = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december,
    ];
    return months[month - 1];
  }

  Widget emptyState() {
    return const SizedBox.shrink();
  }

  Widget eventsListContent() {
    final events = _getEventsForDate(_selectedDate);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: events.map((event) => scheduleCard(event)).toList(),
      ),
    );
  }

  Widget eventsList() {
    final events = _getEventsForDate(_selectedDate);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return scheduleCard(events[index]);
      },
    );
  }

  Widget scheduleCard(ScheduleEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: FitnessAppTheme.grey.withAlpha((0.2 * 255).round()),
            offset: const Offset(1.1, 1.1),
            blurRadius: 8.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: event.color.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(event.icon, color: event.color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: FitnessAppTheme.darkerText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.time,
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: FitnessAppTheme.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: FitnessAppTheme.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildUserConditionsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.yourHealthCondition,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._userConditions.map((condition) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.1 * 255).round()),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medical_services,
                      color: Colors.red[700],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          condition['name_vi'] ??
                              condition['condition_name'] ??
                              'Không rõ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (condition['treatment_duration_days'] != null)
                          Text(
                            'Điều trị: ${condition['treatment_duration_days']} ngày',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: condition['status'] == 'active'
                          ? Colors.green[100]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      condition['status'] == 'active'
                          ? AppLocalizations.of(context)!.inTreatment
                          : AppLocalizations.of(context)!.completed,
                      style: TextStyle(
                        fontSize: 11,
                        color: condition['status'] == 'active'
                            ? Colors.green[800]
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTodayMedicationsCard() {
    final now = DateTime.now();
    final currentTime = TimeOfDay.now();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.purple[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha((0.15 * 255).round()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.purple[600]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medication_liquid,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Text(
                          l10n.medicationSchedule,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        );
                      },
                    ),
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Text(
                          l10n.todayDate(
                            now.day.toString(),
                            now.month.toString(),
                            now.year.toString(),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Medication times
          ..._todayMedications.map((medication) {
            return _buildMedicationTimeSlot(medication, currentTime, now);
          }),

          // Ngày tới khám section
          if (_userConditions.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _buildFollowUpDateSection(now),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationTimeSlot(
    dynamic medication,
    TimeOfDay currentTime,
    DateTime now,
  ) {
    final isTaken = medication['status'] == 'taken';
    final medicationTime = medication['medication_time'];

    // Parse medication time
    final timeParts = medicationTime.split(':');
    final medHour = int.parse(timeParts[0]);
    final medMinute = int.parse(timeParts[1]);
    final medTime = TimeOfDay(hour: medHour, minute: medMinute);

    // Check if it's time to take medication (within 30 minutes window)
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final medMinutes = medTime.hour * 60 + medTime.minute;
    final diff = medMinutes - currentMinutes;
    final isTimeToTake =
        !isTaken && diff >= -30 && diff <= 30; // 30 min before/after

    // Determine period emoji and text
    String period = '🌙';
    String periodText = AppLocalizations.of(context)!.evening;
    MaterialColor periodColor = Colors.indigo;

    if (medHour >= 5 && medHour < 11) {
      period = '🌅';
      periodText = AppLocalizations.of(context)!.morning;
      periodColor = Colors.orange;
    } else if (medHour >= 11 && medHour < 17) {
      period = '☀️';
      periodText = AppLocalizations.of(context)!.afternoon;
      periodColor = Colors.amber;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTaken
            ? Colors.green[50]
            : isTimeToTake
            ? Colors.orange[50]
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTaken
              ? Colors.green[300]!
              : isTimeToTake
              ? Colors.orange[400]!
              : Colors.blue[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isTaken
                        ? Colors.green
                        : isTimeToTake
                        ? Colors.orange
                        : Colors.blue)
                    .withAlpha((0.1 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isTaken
                    ? [Colors.green[400]!, Colors.green[600]!]
                    : isTimeToTake
                    ? [Colors.orange[400]!, Colors.deepOrange[600]!]
                    : [periodColor.shade300, periodColor.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (isTaken ? Colors.green : periodColor).withAlpha(
                    (0.3 * 255).round(),
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isTaken ? Icons.check_circle : Icons.alarm,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(period, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      periodText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: periodColor.shade800,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isTimeToTake
                            ? Colors.orange[100]
                            : periodColor.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        medicationTime,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isTimeToTake
                              ? Colors.deepOrange[800]
                              : periodColor.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  medication['condition_name'] ??
                      AppLocalizations.of(context)!.medication,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                if (medication['notes'] != null &&
                    medication['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '💡 ${medication['notes']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Action button
          if (isTaken)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, size: 28, color: Colors.green[700]),
            )
          else if (isTimeToTake)
            ElevatedButton(
              onPressed: () => _markMedicationTaken(medication),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.medication_liquid,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Chọn thuốc uống',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.schedule, size: 24, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildFollowUpDateSection(DateTime now) {
    // Find conditions with upcoming follow-up dates
    final upcomingFollowUps = _userConditions.where((condition) {
      if (condition['treatment_end_date'] == null) return false;
      try {
        final endDate = DateTime.parse(condition['treatment_end_date']);
        return endDate.isAfter(now.subtract(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();

    if (upcomingFollowUps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.purple[700], size: 20),
            const SizedBox(width: 8),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(
                  l10n.nextAppointment,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...upcomingFollowUps.map((condition) {
          final endDate = DateTime.parse(condition['treatment_end_date']);
          final daysUntil = endDate.difference(now).inDays;
          final isToday = daysUntil == 0;
          final isPast = endDate.isBefore(now);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isToday
                  ? Colors.orange[50]
                  : isPast
                  ? Colors.red[50]
                  : Colors.purple[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isToday
                    ? Colors.orange[300]!
                    : isPast
                    ? Colors.red[300]!
                    : Colors.purple[200]!,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_hospital,
                      size: 18,
                      color: isToday
                          ? Colors.orange[700]
                          : isPast
                          ? Colors.red[700]
                          : Colors.purple[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        condition['condition_name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      'Ngày tái khám: ${endDate.day}/${endDate.month}/${endDate.year}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isToday
                            ? Colors.orange[200]
                            : isPast
                            ? Colors.red[200]
                            : Colors.purple[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isToday
                            ? AppLocalizations.of(context)!.today
                            : isPast
                            ? AppLocalizations.of(context)!.past
                            : AppLocalizations.of(
                                context,
                              )!.daysLeft((daysUntil + 1).toString()),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? Colors.orange[900]
                              : isPast
                              ? Colors.red[900]
                              : Colors.purple[900],
                        ),
                      ),
                    ),
                  ],
                ),
                if (isToday || isPast) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showExtendTreatmentDialog(condition),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Text(
                                l10n.continueTreatment,
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _markConditionRecovered(condition),
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Text(
                                l10n.recovered,
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _showExtendTreatmentDialog(dynamic condition) async {
    DateTime? newEndDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(l10n.continueTreatment);
          },
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(
                  l10n.confirmContinueTreatment(condition['condition_name']),
                );
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  newEndDate = picked;
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      newEndDate != null
                          ? '${newEndDate!.day}/${newEndDate!.month}/${newEndDate!.year}'
                          : AppLocalizations.of(context)!.selectNewEndDate,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.cancel);
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newEndDate != null) {
                await _extendTreatment(
                  condition['user_condition_id'],
                  newEndDate!,
                );
                Navigator.pop(context);
              }
            },
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.confirm);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _extendTreatment(
    int userConditionId,
    DateTime newEndDate,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) return;

      final response = await http.patch(
        Uri.parse(
          '${ApiConfig.baseUrl}/health/user/conditions/$userConditionId/extend',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'new_end_date': newEndDate.toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 200) {
        _loadUserConditions();
        _loadTodayMedications();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.treatmentExtended);
              },
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text('${l10n.errorColon} $e');
            },
          ),
        ),
      );
    }
  }

  Future<void> _markConditionRecovered(dynamic condition) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(l10n.confirm);
          },
        ),
        content: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(l10n.confirmRecovered(condition['condition_name']));
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.cancel);
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.recovered);
              },
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token') ?? prefs.getString('token');

        if (token == null) return;

        final response = await http.patch(
          Uri.parse(
            '${ApiConfig.baseUrl}/health/user/conditions/${condition['user_condition_id']}/recover',
          ),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          _loadUserConditions();
          _loadTodayMedications();
          _loadMedicationDates();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Text(l10n.congratulationsRecovered);
                },
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text('${l10n.errorColon} $e');
              },
            ),
          ),
        );
      }
    }
  }

  // ignore: unused_element
  void _showAddEventDialog() {
    String title = '';
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);
    IconData selectedIcon = Icons.event;
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.addNewAppointment,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.title,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) => title = value,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: startTime,
                              );
                              if (time != null) {
                                setDialogState(() => startTime = time);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.start,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: FitnessAppTheme.grey,
                                    ),
                                  ),
                                  Text(
                                    startTime.format(context),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: endTime,
                              );
                              if (time != null) {
                                setDialogState(() => endTime = time);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.end,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: FitnessAppTheme.grey,
                                    ),
                                  ),
                                  Text(
                                    endTime.format(context),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        _iconColorChip(
                          Icons.fitness_center,
                          Colors.orange,
                          selectedIcon,
                          selectedColor,
                          setDialogState,
                          (icon, color) {
                            selectedIcon = icon;
                            selectedColor = color;
                          },
                        ),
                        _iconColorChip(
                          Icons.breakfast_dining,
                          Colors.green,
                          selectedIcon,
                          selectedColor,
                          setDialogState,
                          (icon, color) {
                            selectedIcon = icon;
                            selectedColor = color;
                          },
                        ),
                        _iconColorChip(
                          Icons.self_improvement,
                          Colors.purple,
                          selectedIcon,
                          selectedColor,
                          setDialogState,
                          (icon, color) {
                            selectedIcon = icon;
                            selectedColor = color;
                          },
                        ),
                        _iconColorChip(
                          Icons.work,
                          Colors.blue,
                          selectedIcon,
                          selectedColor,
                          setDialogState,
                          (icon, color) {
                            selectedIcon = icon;
                            selectedColor = color;
                          },
                        ),
                        _iconColorChip(
                          Icons.directions_run,
                          Colors.red,
                          selectedIcon,
                          selectedColor,
                          setDialogState,
                          (icon, color) {
                            selectedIcon = icon;
                            selectedColor = color;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(l10n.cancel);
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (title.isNotEmpty) {
                      // Không còn dùng _events nữa - function này deprecated
                      // setState(() {
                      //   _events.add(
                      //     ScheduleEvent(
                      //       title: title,
                      //       time:
                      //           '${startTime.format(context)} - ${endTime.format(context)}',
                      //       icon: selectedIcon,
                      //       color: selectedColor,
                      //       date: _selectedDate,
                      //     ),
                      //   );
                      // });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text(
                    'Thêm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _iconColorChip(
    IconData icon,
    Color color,
    IconData selectedIcon,
    Color selectedColor,
    StateSetter setDialogState,
    Function(IconData, Color) onSelected,
  ) {
    final isSelected = icon == selectedIcon && color == selectedColor;
    return InkWell(
      onTap: () {
        setDialogState(() => onSelected(icon, color));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha((0.2 * 255).round())
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? color
                : Colors.grey.withAlpha((0.3 * 255).round()),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

// Drug Selection Dialog
class _DrugSelectionDialog extends StatefulWidget {
  final List<dynamic> conditionDrugs;
  final List<int> userConditionIds;
  final dynamic medication;

  const _DrugSelectionDialog({
    required this.conditionDrugs,
    required this.userConditionIds,
    required this.medication,
  });

  @override
  _DrugSelectionDialogState createState() => _DrugSelectionDialogState();
}

class _DrugSelectionDialogState extends State<_DrugSelectionDialog> {
  List<dynamic> _allDrugs = [];
  bool _isLoadingAllDrugs = false;
  bool _showAllDrugs = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadAllDrugs() async {
    if (_showAllDrugs && _allDrugs.isNotEmpty) return;

    setState(() => _isLoadingAllDrugs = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) {
        setState(() => _isLoadingAllDrugs = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/medications/drugs'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _allDrugs = data['drugs'] ?? [];
          _isLoadingAllDrugs = false;
        });
      } else {
        setState(() => _isLoadingAllDrugs = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tải danh sách thuốc')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoadingAllDrugs = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  bool _isDrugSuitable(dynamic drug) {
    if (widget.userConditionIds.isEmpty) return false;

    final drugConditions =
        (drug['conditions'] as List?)
            ?.map((c) => c['condition_id'] as int?)
            .where((id) => id != null)
            .toList() ??
        [];

    return drugConditions.any((id) => widget.userConditionIds.contains(id));
  }

  void _handleDrugTap(dynamic drug) {
    final isSuitable = _isDrugSuitable(drug);

    if (!isSuitable) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cảnh báo'),
          content: const Text(
            'Bạn không mắc bệnh nên không cần uống thuốc này. '
            'Vui lòng chọn thuốc phù hợp với tình trạng bệnh của bạn.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đã hiểu'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.pop(context, drug);
  }

  List<dynamic> _getDisplayDrugs() {
    final drugs = _showAllDrugs ? _allDrugs : widget.conditionDrugs;

    if (_searchQuery.isEmpty) return drugs;

    final query = _searchQuery.toLowerCase();
    return drugs.where((drug) {
      final nameVi = (drug['name_vi'] ?? '').toString().toLowerCase();
      final nameEn = (drug['name_en'] ?? '').toString().toLowerCase();
      final genericName = (drug['generic_name'] ?? '').toString().toLowerCase();
      return nameVi.contains(query) ||
          nameEn.contains(query) ||
          genericName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayDrugs = _getDisplayDrugs();
    final hasNoConditions = widget.userConditionIds.isEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(
                _showAllDrugs ? 'Tất cả thuốc' : 'Chọn thuốc để uống',
              ),
              automaticallyImplyLeading: false,
              actions: [
                if (!_showAllDrugs)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Xem tất cả thuốc',
                    onPressed: () {
                      setState(() {
                        _showAllDrugs = true;
                      });
                      _loadAllDrugs();
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm thuốc...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            // Drug list
            Flexible(
              child: _isLoadingAllDrugs
                  ? const Center(child: CircularProgressIndicator())
                  : displayDrugs.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          _showAllDrugs
                              ? 'Không tìm thấy thuốc nào'
                              : 'Chưa có thuốc nào cho bệnh này',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: displayDrugs.length,
                      itemBuilder: (context, index) {
                        final drug = displayDrugs[index];
                        final isSuitable = _isDrugSuitable(drug);
                        final shouldDim = hasNoConditions || !isSuitable;

                        return Opacity(
                          opacity: shouldDim ? 0.4 : 1.0,
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            color: shouldDim ? Colors.grey[100] : null,
                            child: ListTile(
                              enabled: isSuitable,
                              leading: drug['image_url'] != null
                                  ? Image.network(
                                      drug['image_url'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.medication),
                                    )
                                  : const Icon(Icons.medication),
                              title: Text(
                                drug['name_vi'] ?? '',
                                style: TextStyle(
                                  fontWeight: isSuitable
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (drug['generic_name'] != null)
                                    Text(drug['generic_name']),
                                  if (shouldDim)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        hasNoConditions
                                            ? 'Bạn không có bệnh nào đang điều trị'
                                            : 'Không phù hợp với bệnh của bạn',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.red[700],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (drug['is_primary'] == true)
                                    Chip(
                                      label: const Text(
                                        'Chính',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      backgroundColor: Colors.green[100],
                                    ),
                                  if (!isSuitable)
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange[700],
                                      size: 20,
                                    ),
                                ],
                              ),
                              onTap: () => _handleDrugTap(drug),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  if (_showAllDrugs)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showAllDrugs = false;
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Quay lại'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
