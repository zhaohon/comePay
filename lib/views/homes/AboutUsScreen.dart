import 'package:flutter/material.dart';
import 'package:comecomepay/l10n/app_localizations.dart';
import 'package:comecomepay/utils/app_colors.dart';
import '../../services/content_service.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  final ContentService _contentService = ContentService();
  Map<String, dynamic> _siteContent = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadContent();
  }

  Future<void> _loadContent() async {
    // Prevent reloading if already loaded or loading (unless we want to support locale change live, which didChangeDependencies handles)
    if (!_isLoading && _siteContent.isNotEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final locale = Localizations.localeOf(context).languageCode;
      String lang = 'en';
      if (locale == 'zh') {
        lang = 'zh';
      } else if (locale == 'ar') {
        lang = 'ar';
      }

      final data = await _contentService.getSiteContent(lang);
      if (mounted) {
        setState(() {
          _siteContent = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.aboutUsTitle,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  /// Icon + Text sejajar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/logo.png", // ganti dengan logo kamu
                        height: 60,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Come Come Pay",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        "Error: $_errorMessage",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  /// Card dengan shadow
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                            AppLocalizations.of(context)!.companyIntroduction,
                            () {
                          _navigateToDetail(
                            AppLocalizations.of(context)!.companyIntroduction,
                            _siteContent['company_intro'] ?? '',
                          );
                        }),
                        _buildDivider(),
                        _buildMenuItem(AppLocalizations.of(context)!.termOfUse,
                            () {
                          _navigateToDetail(
                            AppLocalizations.of(context)!.termOfUse,
                            _siteContent['terms_of_service'] ?? '',
                          );
                        }),
                        _buildDivider(),
                        _buildMenuItem(
                            AppLocalizations.of(context)!.privacyPolicy, () {
                          _navigateToDetail(
                            AppLocalizations.of(context)!.privacyPolicy,
                            _siteContent['privacy_policy'] ?? '',
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }

  Widget _buildMenuItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios, // lebih mirip desain
              size: 14,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(title: title, content: content),
      ),
    );
  }
}

/// Contoh halaman detail
class DetailPage extends StatelessWidget {
  final String title;
  final String content;

  const DetailPage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
      ),
    );
  }
}
