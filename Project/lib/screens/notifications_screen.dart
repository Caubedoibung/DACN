import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/widgets/season_effect.dart';
import 'package:my_diary/widgets/season_effect_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  late final AnimationController _intro;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.2, 1, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _intro,
            curve: const Interval(0.2, 0.85, curve: Curves.easeOutCubic),
          ),
        );
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await AuthService.getNotifications();
    setState(() {
      _items = data ?? [];
      _loading = false;
    });
    // Mark as seen now so the badge on the bell can clear
    await AuthService.markNotificationsSeenNow();
    if (mounted) _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final season = SeasonEffectNotifier.maybeOf(context);
    return SeasonEffect(
      currentDate: season?.selectedDate ?? DateTime.now(),
      enabled: season?.enabled ?? true,
      child: Container(
        color: FitnessAppTheme.background,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 180,
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Row(
                          children: const [
                            Hero(
                              tag: 'heroNotifications',
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 22,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Thông báo'),
                          ],
                        ),
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.indigo.shade500,
                                Colors.blue.shade600,
                              ],
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 24.0),
                              child: Icon(
                                Icons.notifications_active,
                                color: Colors.white.withValues(alpha: 0.2),
                                size: 120,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: (_items.isEmpty
                                  ? _emptyView()
                                  : _list()),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  List<Widget> _list() {
    return _items
        .map(
          (e) => _notificationTile(
            type: e['type']?.toString() ?? 'info',
            message: e['message']?.toString() ?? '—',
            at: e['at']?.toString(),
          ),
        )
        .toList();
  }

  List<Widget> _emptyView() {
    return [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FitnessAppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.info_outline, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Chưa có thông báo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _notificationTile({
    required String type,
    required String message,
    String? at,
  }) {
    final iconColor = _colorForType(type);
    final iconData = _iconForType(type);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor.withValues(alpha: 0.6), iconColor],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  _friendlyTime(at),
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final dt = DateTime.tryParse(iso)?.toLocal();
      if (dt == null) return '—';
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  MaterialColor _colorForType(String type) {
    switch (type) {
      case 'metrics_updated':
        return Colors.green;
      case 'account_unblocked':
        return Colors.orange;
      case 'last_login':
        return Colors.blue;
      default:
        return Colors.indigo;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'metrics_updated':
        return Icons.monitor_heart_rounded;
      case 'account_unblocked':
        return Icons.lock_open_rounded;
      case 'last_login':
        return Icons.login_rounded;
      default:
        return Icons.notifications;
    }
  }
}
