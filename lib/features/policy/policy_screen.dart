import 'package:flutter/material.dart';
import '../../common/services/api_client.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const Color _blue = Color(0xFF2563EB);
const Color _darkBlue = Color(0xFF004AC6);
const Color _bg = Color(0xFFF8F9FF);
const Color _surface = Color(0xFFFFFFFF);
const Color _outline = Color(0xFFE5E7EB);
const Color _text = Color(0xFF0B1C30);
const Color _mutedText = Color(0xFF6B7280);

// ─── Model ────────────────────────────────────────────────────────────────────

enum PolicyType {
  terms('TERMS', 'Terms & Conditions'),
  privacy('PRIVACY', 'Privacy Policy'),
  refund('REFUND', 'Refund Policy'),
  aboutUs('ABOUT_US', 'About Us');

  const PolicyType(this.slug, this.label);
  final String slug;
  final String label;
}

class _Policy {
  final int id;
  final String policyType;
  final String policyTypeDisplay;
  final String title;
  final String? titleBn;
  final String content;
  final String? contentBn;
  final String updatedAt;
  final bool isActive;

  const _Policy({
    required this.id,
    required this.policyType,
    required this.policyTypeDisplay,
    required this.title,
    this.titleBn,
    required this.content,
    this.contentBn,
    required this.updatedAt,
    required this.isActive,
  });

  factory _Policy.fromJson(Map<String, dynamic> json) {
    return _Policy(
      id: json['id'] as int? ?? 0,
      policyType: json['policyType'] as String? ?? '',
      policyTypeDisplay: json['policyTypeDisplay'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titleBn: json['titleBn'] as String?,
      content: json['content'] as String? ?? '',
      contentBn: json['contentBn'] as String?,
      updatedAt: json['updatedAt'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

// ─── Service ──────────────────────────────────────────────────────────────────

class _PolicyService {
  final ApiClient _api = ApiClient();

  Future<_Policy?> fetchByType(String type) async {
    try {
      final response = await _api.get(
        '/main/policies/by-type/',
        queryParameters: {'type': type},
        useCache: false,
      );
      if (response.statusCode == 200 && response.data != null) {
        return _Policy.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[PolicyService] Error fetching $type: $e');
    }
    return null;
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class PolicyScreen extends StatefulWidget {
  const PolicyScreen({super.key, required this.type});

  final PolicyType type;

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  final _PolicyService _service = _PolicyService();

  _Policy? _policy;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isEnglish = true;

  @override
  void initState() {
    super.initState();
    _loadPolicy();
  }

  Future<void> _loadPolicy() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    final policy = await _service.fetchByType(widget.type.slug);
    if (mounted) {
      setState(() {
        _policy = policy;
        _isLoading = false;
        _hasError = policy == null;
      });
    }
  }

  bool get _hasBangla =>
      (_policy?.titleBn?.isNotEmpty ?? false) ||
      (_policy?.contentBn?.isNotEmpty ?? false);

  String get _currentTitle {
    if (!_isEnglish && (_policy?.titleBn?.isNotEmpty ?? false)) {
      return _policy!.titleBn!;
    }
    return _policy?.title ?? widget.type.label;
  }

  String get _currentContent {
    if (!_isEnglish && (_policy?.contentBn?.isNotEmpty ?? false)) {
      return _policy!.contentBn!;
    }
    return _policy?.content ?? '';
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        foregroundColor: _text,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _darkBlue),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        titleSpacing: 0,
        title: Text(
          widget.type.label,
          style: const TextStyle(
            color: _darkBlue,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        // Language toggle in actions
        actions: [
          if (!_isLoading && !_hasError && _hasBangla)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('EN'),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('বাং'),
                  ),
                ],
                selected: {_isEnglish},
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.white
                        : _blue,
                  ),
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? _blue
                        : _surface,
                  ),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: _blue),
                  ),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                onSelectionChanged: (selection) {
                  setState(() => _isEnglish = selection.first);
                },
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _blue),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 34,
                  color: _blue,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Failed to load content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _mutedText),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadPolicy,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _blue.withValues(alpha: 0.07),
                  _darkBlue.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _blue.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_policyIcon, color: _blue, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _text,
                          height: 1.2,
                        ),
                      ),
                      if (_policy?.updatedAt.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Last updated: ${_formatDate(_policy!.updatedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _mutedText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _outline),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: _currentContent.isNotEmpty
                ? _HtmlText(html: _currentContent)
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'No content available.',
                        style: TextStyle(color: _mutedText),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  IconData get _policyIcon {
    switch (widget.type) {
      case PolicyType.terms:
        return Icons.gavel_rounded;
      case PolicyType.privacy:
        return Icons.lock_outline_rounded;
      case PolicyType.refund:
        return Icons.replay_rounded;
      case PolicyType.aboutUs:
        return Icons.info_outline_rounded;
    }
  }
}

// ─── Simple HTML → Flutter text renderer ──────────────────────────────────────
// Converts the most common HTML tags to styled Flutter RichText spans.
// This avoids adding a heavyweight webview dependency.

class _HtmlText extends StatelessWidget {
  const _HtmlText({required this.html});

  final String html;

  @override
  Widget build(BuildContext context) {
    final segments = _parseHtml(html);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments,
    );
  }

  List<Widget> _parseHtml(String raw) {
    // Strip HTML tags for a clean readable presentation
    final List<Widget> widgets = [];

    // Split by block-level tags to get paragraphs/headings/lists
    final blockPattern = RegExp(
      r'<(h[1-6]|p|li|ul|ol|br)[^>]*>(.*?)<\/\1>|<br\s*/?>',
      caseSensitive: false,
      dotAll: true,
    );

    int lastEnd = 0;
    final matches = blockPattern.allMatches(raw);

    for (final match in matches) {
      // Any plain text before this match
      if (match.start > lastEnd) {
        final plain = _strip(raw.substring(lastEnd, match.start)).trim();
        if (plain.isNotEmpty) {
          widgets.add(_bodyText(plain));
          widgets.add(const SizedBox(height: 8));
        }
      }

      final tag = match.group(1)?.toLowerCase() ?? '';
      final inner = _strip(match.group(2) ?? '').trim();

      if (tag.startsWith('h')) {
        if (inner.isNotEmpty) {
          widgets.add(_heading(inner, tag));
          widgets.add(const SizedBox(height: 10));
        }
      } else if (tag == 'p') {
        if (inner.isNotEmpty) {
          widgets.add(_bodyText(inner));
          widgets.add(const SizedBox(height: 10));
        }
      } else if (tag == 'li') {
        if (inner.isNotEmpty) {
          widgets.add(_listItem(inner));
          widgets.add(const SizedBox(height: 6));
        }
      } else if (tag == 'br') {
        widgets.add(const SizedBox(height: 6));
      }

      lastEnd = match.end;
    }

    // Remaining text after last block tag
    if (lastEnd < raw.length) {
      final plain = _strip(raw.substring(lastEnd)).trim();
      if (plain.isNotEmpty) {
        widgets.add(_bodyText(plain));
      }
    }

    // Fallback: if nothing was parsed, just display stripped plain text
    if (widgets.isEmpty) {
      final plain = _strip(raw).trim();
      if (plain.isNotEmpty) {
        widgets.add(_bodyText(plain));
      }
    }

    return widgets;
  }

  /// Strips all remaining HTML tags from a string
  String _strip(String input) {
    return input.replaceAll(RegExp(r'<[^>]+>'), '').trim();
  }

  Widget _heading(String text, String tag) {
    final sizes = {
      'h1': 22.0,
      'h2': 20.0,
      'h3': 18.0,
      'h4': 16.0,
      'h5': 15.0,
      'h6': 14.0,
    };
    return Text(
      text,
      style: TextStyle(
        fontSize: sizes[tag] ?? 16.0,
        fontWeight: FontWeight.w800,
        color: _text,
        height: 1.3,
      ),
    );
  }

  Widget _bodyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14.5,
        color: Color(0xFF374151),
        height: 1.7,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _listItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: Icon(Icons.circle, size: 6, color: _blue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14.5,
              color: Color(0xFF374151),
              height: 1.65,
            ),
          ),
        ),
      ],
    );
  }
}
