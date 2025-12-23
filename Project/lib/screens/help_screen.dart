import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/widgets/season_effect.dart';
import 'package:my_diary/widgets/season_effect_provider.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {
  final List<_FaqItem> _faqs = [
    _FaqItem(
      'Làm sao để thêm bữa ăn?',
      'Vào mục bữa ăn trong ngày, chọn loại bữa (sáng/trưa/tối) rồi tìm thực phẩm và nhập khối lượng.',
    ),
    _FaqItem(
      'Cách cập nhật mục tiêu hàng ngày?',
      'Vào trang Tài khoản > chỉnh sửa hồ sơ, nhập chiều cao, cân nặng, độ tuổi và hệ số vận động để hệ thống tính toán.',
    ),
    _FaqItem(
      'Theo dõi lượng nước uống như thế nào?',
      'Trong màn hình chính, chọn ô nước và nhấn nút cộng để ghi nhận từng lần uống.',
    ),
    _FaqItem(
      'Tôi quên mật khẩu thì sao?',
      'Liên hệ quản trị hoặc sử dụng email đăng ký để khôi phục khi tính năng được bật.',
    ),
    _FaqItem(
      'Tài khoản bị chặn phải làm gì?',
      'Tại màn hình đăng nhập, ứng dụng sẽ hiển thị lý do và cho phép gửi yêu cầu gỡ chặn tới quản trị.',
    ),
  ];

  late final AnimationController _introController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeIn = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
          ),
        );
    // start after build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _introController.forward();
    });
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
          appBar: AppBar(
            title: Row(
              children: const [
                Hero(
                  tag: 'heroHelp',
                  child: Icon(Icons.help_outline, size: 24),
                ),
                SizedBox(width: 8),
                Text('Trợ giúp'),
              ],
            ),
          ),
          body: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [_heroCard(), const SizedBox(height: 16), _faqList()],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FitnessAppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.06 * 255).round()),
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
                color: Colors.blue.withAlpha((0.08 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.help_outline, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Câu hỏi thường gặp',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nhấn vào từng mục để xem câu trả lời',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqList() {
    return Container(
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.06 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionPanelList.radio(
            expandedHeaderPadding: EdgeInsets.zero,
            animationDuration: const Duration(milliseconds: 300),
            children: _faqs
                .map(
                  (f) => ExpansionPanelRadio(
                    value: f.title,
                    headerBuilder: (_, isOpen) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        f.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: AnimatedRotation(
                        turns: isOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(Icons.expand_more, color: Colors.grey[700]),
                      ),
                    ),
                    body: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        f.content,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }
}

class _FaqItem {
  final String title;
  final String content;
  _FaqItem(this.title, this.content);
}
