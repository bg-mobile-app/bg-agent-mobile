import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/services/api_client.dart';
import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import '../../routes/navigation_history.dart';
import 'services/booking_service.dart';

class BookingDocumentsScreen extends StatefulWidget {
  const BookingDocumentsScreen({super.key, required this.bookingId});

  final int bookingId;

  @override
  State<BookingDocumentsScreen> createState() => _BookingDocumentsScreenState();
}

class _BookingDocumentsScreenState extends State<BookingDocumentsScreen> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _documents = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      final docs = await _bookingService.getBookingDocuments(widget.bookingId);
      if (mounted) {
        setState(() {
          _documents = docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _getFileUrl(Map<String, dynamic> doc) {
    String? path = doc['document'] ?? doc['image'];
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final apiBase = ApiClient().baseUrl;
    // Remove trailing slash of apiBase if present, and leading slash of path if present
    final base = apiBase.endsWith('/') ? apiBase.substring(0, apiBase.length - 1) : apiBase;
    final relative = path.startsWith('/') ? path : '/$path';
    return '$base$relative';
  }

  Future<void> _downloadFile(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.pageBackground,
      appBar: AppBar(
        title: const Text('Booking Documents', style: AppTextStyles.subtitle1),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else if (AppNavigationHistory.canPop) {
              final prev = AppNavigationHistory.pop();
              if (prev != null) {
                context.go(prev);
              }
            } else {
              context.go('/dashboard/receive-booking/all-booking');
            }
          },
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Failed to load documents: $_errorMessage',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _documents.isEmpty
                    ? const Center(
                        child: Text(
                          'No documents uploaded for this booking.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _documents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doc = _documents[index];
                          final title = doc['title'] ?? 'Untitled Document';
                          final fileUrl = _getFileUrl(doc);
                          final isPdf = fileUrl.toLowerCase().endsWith('.pdf');

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isPdf
                                        ? const Color(0xFFFEE2E2)
                                        : const Color(0xFFDBEAFE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                                    color: isPdf ? Colors.red : AppPalette.brandBlue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Color(0xFF1E293B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isPdf ? 'PDF Document' : 'Image File',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.download_rounded, color: AppPalette.brandBlue),
                                  onPressed: () => _downloadFile(fileUrl),
                                  tooltip: 'Download File',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
