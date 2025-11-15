import 'package:flutter/material.dart';
import 'update_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UpdateService _updateService = UpdateService();
  bool _isLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    setState(() {
      _isLoading = true;
    });
    await _updateService.checkForUpdate();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _startUpdateProcess() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    bool downloaded = await _updateService.downloadUpdate((progress) {
      setState(() {
        _downloadProgress = progress;
      });
    });

    setState(() {
      _isDownloading = false;
    });

    if (downloaded) {
      // بدء التثبيت
      await _updateService.installUpdate();
    } else {
      // إظهار رسالة خطأ
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل تحميل التحديث')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('متجري البسيط'),
        actions: [
          // زر "تحديث" يظهر فقط إذا كان هناك تحديث
          if (!_isLoading && _updateService.updateAvailable && !_isDownloading)
            TextButton(
              onPressed: _startUpdateProcess,
              child: const Text(
                'تحديث متوفر!',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Center(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_isDownloading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'جاري تحميل التحديث... ${(_downloadProgress * 100).toStringAsFixed(0)}%',
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: LinearProgressIndicator(value: _downloadProgress),
          ),
        ],
      );
    }

    // هذه هي واجهة تطبيقك الرئيسية (التي طلبتها)
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // أيقونة تطبيقك
        const Icon(Icons.apps, size: 100, color: Colors.blue),
        const SizedBox(height: 20),

        // زر التحميل/التحديث
        ElevatedButton.icon(
          icon: Icon(
            _updateService.updateAvailable
                ? Icons.system_update
                : Icons.check_circle,
          ),
          label: Text(
            _updateService.updateAvailable
                ? 'تحميل وتثبيت التحديث'
                : 'أنت على أحدث إصدار',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _updateService.updateAvailable
                ? Colors.red
                : Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          onPressed: _updateService.updateAvailable
              ? _startUpdateProcess
              : null,
        ),
      ],
    );
  }
}
