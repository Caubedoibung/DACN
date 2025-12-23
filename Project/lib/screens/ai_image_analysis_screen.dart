import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../fitness_app_theme.dart';
import '../services/ai_analysis_service.dart';

/// Screen để phân tích hình ảnh thức ăn/đồ uống bằng AI
class AiImageAnalysisScreen extends StatefulWidget {
  const AiImageAnalysisScreen({super.key});

  @override
  State<AiImageAnalysisScreen> createState() => _AiImageAnalysisScreenState();
}

class _AiImageAnalysisScreenState extends State<AiImageAnalysisScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  List<Map<String, dynamic>> _analyzedItems = [];
  bool _isAnalyzing = false;
  String? _errorMessage;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analyzedItems = [];
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể chọn ảnh: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Vui lòng chọn ảnh trước';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final items = await AiAnalysisService.analyzeImage(_selectedImage!);

      setState(() {
        _analyzedItems = items;
        _isAnalyzing = false;
      });

      _animationController.forward(from: 0);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Lỗi phân tích: $e';
      });
    }
  }

  Future<void> _acceptItem(int itemId) async {
    try {
      await AiAnalysisService.acceptAnalysis(itemId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã chấp nhận và lưu vào hệ thống!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Remove accepted item from list
        setState(() {
          _analyzedItems.removeWhere((item) => item['id'] == itemId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectItem(int itemId) async {
    try {
      await AiAnalysisService.rejectAnalysis(itemId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã từ chối'),
            duration: Duration(seconds: 1),
          ),
        );

        setState(() {
          _analyzedItems.removeWhere((item) => item['id'] == itemId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      appBar: AppBar(
        title: const Text('Phân tích hình ảnh AI'),
        backgroundColor: FitnessAppTheme.nearlyWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image picker section
            _buildImagePickerSection(),
            const SizedBox(height: 20),

            // Analyze button
            if (_selectedImage != null) _buildAnalyzeButton(),

            const SizedBox(height: 20),

            // Loading indicator
            if (_isAnalyzing) _buildLoadingIndicator(),

            // Error message
            if (_errorMessage != null) _buildErrorMessage(),

            // Analysis results
            if (_analyzedItems.isNotEmpty) _buildResultsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedImage == null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Chụp ảnh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitnessAppTheme.nearlyDarkBlue,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Thư viện'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitnessAppTheme.nearlyDarkBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return ElevatedButton.icon(
      onPressed: _isAnalyzing ? null : _analyzeImage,
      icon: const Icon(Icons.analytics, size: 28),
      label: const Text(
        'Phân tích ngay',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Đang phân tích hình ảnh...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kết quả phân tích:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...List.generate(_analyzedItems.length, (index) {
          final item = _analyzedItems[index];
          return FadeTransition(
            opacity: _animationController,
            child: _buildItemCard(item, index),
          );
        }),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, int index) {
    final nutrients = AiAnalysisService.formatNutrientsForDisplay(
      item['nutrients'] as Map<String, dynamic>,
    );

    final waterMl = (item['water_ml'] as double?) ?? 0;

    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Tên món + confidence
            Row(
              children: [
                Expanded(
                  child: Text(
                    item['item_name'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildConfidenceBadge(item['confidence_score'] as double),
              ],
            ),
            const SizedBox(height: 8),

            // Type + Volume/Weight
            Row(
              children: [
                Icon(
                  item['item_type'] == 'food'
                      ? Icons.restaurant
                      : Icons.local_drink,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  item['item_type'] == 'food' ? 'Thức ăn' : 'Đồ uống',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  item['item_type'] == 'food'
                      ? '~${item['estimated_weight_g']}g'
                      : '~${item['estimated_volume_ml']}ml',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Main nutrients
            _buildNutrientsGrid(nutrients),

            // Water content
            if (waterMl > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Lượng nước: ${waterMl.toStringAsFixed(0)} ml',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Details button
            TextButton.icon(
              onPressed: () => _showDetailsDialog(item),
              icon: const Icon(Icons.info_outline),
              label: const Text('Xem chi tiết dinh dưỡng'),
            ),

            const Divider(height: 24),

            // Accept/Reject buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectItem(item['id'] as int),
                    icon: const Icon(Icons.close),
                    label: const Text('Từ chối'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptItem(item['id'] as int),
                    icon: const Icon(Icons.check),
                    label: const Text('Chấp nhận'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence) {
    Color color;
    if (confidence >= 80) {
      color = Colors.green;
    } else if (confidence >= 60) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        '${confidence.toStringAsFixed(0)}% chắc chắn',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNutrientsGrid(Map<String, String> nutrients) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: nutrients.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: FitnessAppTheme.nearlyWhite,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                entry.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showDetailsDialog(Map<String, dynamic> item) {
    final allNutrients = AiAnalysisService.formatAllNutrients(
      item['nutrients'] as Map<String, dynamic>,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['item_name'] ?? 'Chi tiết'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: allNutrients.entries.map((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text(
                  entry.value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
