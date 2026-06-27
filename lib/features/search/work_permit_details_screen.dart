import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/services/api_client.dart';
import '../../routes/app_routes.dart';
import '../home/models/home_models.dart';
import '../home/widgets/work_permit_card.dart';
import '../booking/bulk_booking_form_screen.dart';
import 'models/work_permit_details.dart';
import 'services/work_permit_service.dart';
import '../chat/services/chat_service.dart';
import '../chat/chat_conversation_screen.dart';

const Color _brandBlue = Color(0xFF2563EB);
const Color _primary = Color(0xFF004AC6);
const Color _background = Color(0xFFF8F9FF);
const Color _surface = Color(0xFFFFFFFF);
const Color _surfaceLow = Color(0xFFEFF4FF);
const Color _outline = Color(0xFFC3C6D7);
const Color _text = Color(0xFF0B1C30);
const Color _mutedText = Color(0xFF434655);
const Color _error = Color(0xFFBA1A1A);
const Color _errorContainer = Color(0xFFFFDAD6);

class WorkPermitDetailsScreen extends StatefulWidget {
  const WorkPermitDetailsScreen({super.key, required this.item});

  final WorkPermitItem item;

  @override
  State<WorkPermitDetailsScreen> createState() =>
      _WorkPermitDetailsScreenState();
}

class _WorkPermitDetailsScreenState extends State<WorkPermitDetailsScreen> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isBangla = false;
  WorkPermitDetails? _details;
  List<WorkPermitItem> _similarPermits = [];
  final WorkPermitService _service = WorkPermitService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadDetails();
  }

  Future<void> _showShareSheet() async {
    final title = widget.item.title;
    final country = widget.item.countryName;
    final slug = widget.item.slug;
    final shareUrl = 'https://bideshgami.com/work-permits/$slug';
    final shareText = 'Check out this work permit: $title in $country. Price: BDT ${widget.item.customerPrice}. Learn more at: $shareUrl';
    final imageUrl = _details?.image.isNotEmpty == true ? _details!.image : widget.item.image;

    debugPrint('╔══════════════════════════════════════════════════════');
    debugPrint('║ [SHARE] Share sheet opened');
    debugPrint('║  source      = WorkPermitDetailsScreen._showShareSheet()');
    debugPrint('║  title       = $title');
    debugPrint('║  country     = $country');
    debugPrint('║  slug        = $slug');
    debugPrint('║  shareUrl    = $shareUrl');
    debugPrint('║  shareText   = $shareText');
    debugPrint('║  imageUrl    = $imageUrl');
    debugPrint('╚══════════════════════════════════════════════════════');

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share Work Permit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              // Share with Image — uses platform native share sheet
              if (imageUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.image_rounded, color: _brandBlue),
                  title: const Text('Share in social media', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Opens native share sheet with image', style: TextStyle(fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(context);
                    debugPrint('║ [SHARE] Native share with image requested');
                    await _shareWithImage(
                      imageUrl: imageUrl,
                      shareText: shareText,
                      shareUrl: shareUrl,
                    );
                  },
                ),
              // Share text only via native share sheet
              ListTile(
                leading: const Icon(Icons.share_rounded, color: _brandBlue),
                title: const Text('Share Link', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Opens native share sheet', style: TextStyle(fontSize: 12)),
                onTap: () async {
                  Navigator.pop(context);
                  debugPrint('║ [SHARE] Native share link requested');
                  try {
                    await SharePlus.instance.share(
                      ShareParams(text: shareText),
                    );
                    debugPrint('║  ✅ Native share completed');
                  } catch (e) {
                    debugPrint('║  ❌ Native share failed: $e');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: _brandBlue),
                title: const Text('Copy Link', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  debugPrint('║ [SHARE] Copy link requested');
                  Clipboard.setData(ClipboardData(text: shareUrl));
                  debugPrint('║  ✅ Link copied to clipboard');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareWithImage({
    required String imageUrl,
    required String shareText,
    required String shareUrl,
  }) async {
    try {
      debugPrint('╔══════════════════════════════════════════════════════');
      debugPrint('║ [SHARE] Preparing image-based share');
      debugPrint('║  imageUrl = $imageUrl');
      debugPrint('║  shareText = $shareText');
      debugPrint('║  shareUrl = $shareUrl');
      debugPrint('╚══════════════════════════════════════════════════════');

      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Preparing image...'),
            ],
          ),
          duration: Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Download image bytes
      debugPrint('║ [SHARE] Downloading share image');
      final response = await http.get(Uri.parse(imageUrl));
      debugPrint('║  image download status = ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final ext = imageUrl.contains('.png') ? 'png' : 'jpg';
      final file = File('${tempDir.path}/wp_share_image.$ext');
      await file.writeAsBytes(response.bodyBytes);
      debugPrint('║  image saved to = ${file.path}');

      // Dismiss loading snackbar
      if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Share with image using share_plus
      debugPrint('║ [SHARE] Invoking native share with image');
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          files: [XFile(file.path)],
        ),
      );
      debugPrint('║  ✅ Image share completed');
    } catch (e) {
      debugPrint('║  ❌ Error sharing with image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not share image. Sharing link only.'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Share Link',
              onPressed: () async {
                await SharePlus.instance.share(
                  ShareParams(text: shareText),
                );
              },
            ),
          ),
        );
      }
    }
  }


  Future<void> _checkLoginStatus() async {
    final cookies = await ApiClient().tokenStorage.getCookies();
    if (mounted && cookies != null && cookies.isNotEmpty) {
      setState(() => _isLoggedIn = true);
    }
  }

  Future<void> _loadDetails() async {
    final details = await _service.getWorkPermitDetails(widget.item.slug);
    final similar = await _service.getSimilarWorkPermits(widget.item.slug);
    if (mounted) {
      setState(() {
        _details = details;
        _similarPermits = similar;
        _isBangla = details?.isBn ?? false;
        _isLoading = false;
      });
    }
  }

  WorkPermitDetails get displayDetails => _details ?? _getDummyDetails();
  List<WorkPermitItem> get displaySimilar =>
      _isLoading ? [widget.item, widget.item] : _similarPermits;
  String _tr(String english, String bangla) => _isBangla ? bangla : english;

  String _paymentStepLabel(String name, int index) {
    final normalized = name.trim().toLowerCase();
    if (!_isBangla) return name;

    if (normalized.contains('advance') || normalized.contains('অগ্রিম')) {
      return 'অগ্রিম';
    }
    if (normalized.contains('after visa') || normalized.contains('ভিসার পর')) {
      return 'ভিসার পর';
    }
    if (normalized.contains('before flight') || normalized.contains('ফ্লাইটের আগে')) {
      return 'ফ্লাইটের আগে';
    }

    if (index == 0) return 'অগ্রিম';
    if (index == 1) return 'ভিসার পর';
    if (index == 2) return 'ফ্লাইটের আগে';
    return name;
  }

  WorkPermitDetails _getDummyDetails() {
    return WorkPermitDetails(
      id: 0,
      slug: widget.item.slug,
      status: 'Active',
      customerPrice: 150000,
      agentPrice: 120000,
      packagePrice: 115000,
      countryName: widget.item.countryName,
      countryFlag: '',
      image: widget.item.image,
      agency: AgencyProps(
        id: 1,
        name: 'Dummy Agency Name',
        rlNumber: '1234',
        logo: '',
      ),
      workType: WorkTypeProps(id: 1, name: 'Cleaner Worker'),
      favoriteCount: 0,
      bookedQuota: 0,
      availableQuota: 100,
      title: widget.item.title,
      companyName: 'Dummy Company Name Ltd.',
      companyAddress: 'Dummy Address',
      visaSponsorName: 'Dummy Sponsor',
      selectionType: 'Direct',
      visaOccupation: 'Worker',
      salary: 1000,
      currency: 'USD',
      currencyFlag: '',
      minAge: 18,
      maxAge: 45,
      iqama: 'Provided',
      food: 'Provided',
      accommodation: 'Provided',
      workingHours: '8',
      quota: 50,
      contractDuration: '2 Years',
      isRenewable: true,
      gender: 'Any',
      documentsRequired: ['Passport', 'Photo'],
      packageIncludes: ['Visa', 'Ticket', 'Accommodation'],
      experienceRequired: '2 Years Experience',
      processingTime: '45 Days',
      applicationDeadline: DateTime.now(),
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 60)),
      customerPercentage: 30,
      agentPercentage: 20,
      paymentSystem: 'Step Payment',
      isBn: false,
      description: 'Dummy description...',
      paymentSteps: [
        PaymentStepProps(
          name: 'Step 1: Initial Booking',
          amount: 50000,
          percentage: '30%',
        ),
        PaymentStepProps(
          name: 'Step 2: After Visa',
          amount: 50000,
          percentage: '30%',
        ),
      ],
      advancePrice: 50000,
      afterVisa: 50000,
      beforeFlight: 50000,
      createdAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 980;
    final horizontalPadding = isDesktop ? 48.0 : 16.0;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        surfaceTintColor: _surface,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          icon: const Icon(Icons.arrow_back, color: _brandBlue),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        titleSpacing: 0,
        title: Text(
          displayDetails.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _brandBlue,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.language, size: 15),
                  label: Text('EN'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.translate, size: 15),
                  label: Text('BN'),
                ),
              ],
              selected: {_isBangla},
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? Colors.white
                      : _brandBlue,
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? _brandBlue
                      : _surface,
                ),
                side: WidgetStateProperty.all(
                  const BorderSide(color: _brandBlue),
                ),
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              onSelectionChanged: (selection) {
                setState(() => _isBangla = selection.first);
              },
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            onPressed: _showShareSheet,
            icon: const FaIcon(
              FontAwesomeIcons.shareNodes,
              color: _mutedText,
              size: 18,
            ),
          ),
        ],
      ),
      body: _details == null && !_isLoading
          ? Center(
              child: Text(
                _tr('Failed to load details.', 'বিস্তারিত লোড করা যায়নি।'),
              ),
            )
          : Skeletonizer(
              enabled: _isLoading,
              child: SafeArea(
                bottom: false,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _heroImage()),
                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1344),
                          child: _headlineSection(),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1344),
                            child: _safetyGuidelines(),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1344),
                            child: _priceCard(),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        displaySimilar.isNotEmpty ? 24 : 128,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1344),
                            child: isDesktop ? _desktopBody() : _mobileBody(),
                          ),
                        ),
                      ),
                    ),
                    if (displaySimilar.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          16,
                          horizontalPadding,
                          24,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1344),
                              child: _buildSimilarPermitsSection(),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _bottomActions(context),
    );
  }

  Widget _desktopBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 8, child: _primaryDetails()),
        const SizedBox(width: 24),
        Expanded(flex: 4, child: _sideDetails()),
      ],
    );
  }

  Widget _mobileBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_primaryDetails(), const SizedBox(height: 16), _sideDetails()],
    );
  }

  Widget _heroImage() {
    final imagePath = displayDetails.image.isNotEmpty
        ? displayDetails.image
        : widget.item.image;

    if (imagePath.isEmpty) {
      return const ColoredBox(
        color: _surface,
        child: SizedBox(
          height: 220,
          child: Center(child: Icon(Icons.image_not_supported)),
        ),
      );
    }

    final image = imagePath.startsWith('http')
        ? Image.network(
            imagePath,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              height: 220,
              child: Center(child: Icon(Icons.image_not_supported)),
            ),
          )
        : Image.asset(imagePath, width: double.infinity, fit: BoxFit.contain);

    return ColoredBox(
      color: _surface,
      child: Center(child: image),
    );
  }

  Widget _headlineSection() {
    final width = MediaQuery.sizeOf(context).width;
    final isSmallPhone = width <= 720;
    final isMediumPhone = width > 720 && width <= 1080;
    final horizontalPadding = width >= 980 ? 48.0 : 16.0;
    final topPadding = isSmallPhone ? 18.0 : 22.0;
    final titleFontSize = isSmallPhone
        ? 21.0
        : isMediumPhone
        ? 24.0
        : 30.0;
    final badgeFontSize = isSmallPhone
        ? 10.0
        : isMediumPhone
        ? 11.0
        : 12.0;
    final metaFontSize = isSmallPhone
        ? 11.0
        : isMediumPhone
        ? 12.0
        : 13.0;
    final iconSize = isSmallPhone
        ? 11.0
        : isMediumPhone
        ? 13.0
        : 14.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Pill(
                label: _tr('Recruitment Open', 'নিয়োগ চলছে'),
                fontSize: badgeFontSize,
              ),
              _IconText(
                icon: FaIcon(
                  FontAwesomeIcons.circleCheck,
                  color: _brandBlue,
                  size: iconSize,
                ),
                label: _tr('Agency Verified', 'এজেন্সি যাচাইকৃত'),
                color: _brandBlue,
                bold: true,
                fontSize: metaFontSize,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            displayDetails.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _text,
              fontSize: titleFontSize,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: isSmallPhone ? 12 : 18,
            runSpacing: 8,
            children: [
              _IconText(
                icon: FaIcon(FontAwesomeIcons.calendarDays, size: iconSize),
                label: _tr(
                  'Posted: ${displayDetails.createdAt.toString().split(' ')[0]}',
                  'প্রকাশিত: ${displayDetails.createdAt.toString().split(' ')[0]}',
                ),
                fontSize: metaFontSize,
              ),
              _IconText(
                icon: FaIcon(FontAwesomeIcons.fingerprint, size: iconSize),
                label: _tr(
                  'Post ID: ${displayDetails.id}',
                  'পোস্ট আইডি: ${displayDetails.id}',
                ),
                fontSize: metaFontSize,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _primaryDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 620 ? 4 : 2;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 4 ? 1.05 : 1.0,
              children: [
                _StatCard(
                  icon: const FaIcon(
                    FontAwesomeIcons.users,
                    color: _brandBlue,
                    size: 20,
                  ),
                  label: _tr('Quota', 'কোটা'),
                  value: _tr(
                    '${displayDetails.quota}\nPositions',
                    '${displayDetails.quota}\nপদ',
                  ),
                  detail: _tr(
                    '${displayDetails.bookedQuota} applied • ${displayDetails.availableQuota} available',
                    '${displayDetails.bookedQuota} আবেদন • ${displayDetails.availableQuota} খালি',
                  ),
                ),
                _StatCard(
                  icon: const FaIcon(
                    FontAwesomeIcons.clock,
                    color: _brandBlue,
                    size: 20,
                  ),
                  label: _tr('Work Hours', 'কর্মঘণ্টা'),
                  value: _tr(
                    '${displayDetails.workingHours}h / Day',
                    'দিনে ${displayDetails.workingHours} ঘণ্টা',
                  ),
                ),
                _StatCard(
                  icon: const FaIcon(
                    FontAwesomeIcons.briefcase,
                    color: _brandBlue,
                    size: 20,
                  ),
                  label: _tr('Experience', 'অভিজ্ঞতা'),
                  value: displayDetails.experienceRequired,
                ),
                _StatCard(
                  icon: const FaIcon(
                    FontAwesomeIcons.moneyBillWave,
                    color: _brandBlue,
                    size: 20,
                  ),
                  label: _tr('Monthly Salary', 'মাসিক বেতন'),
                  value: '${displayDetails.salary} ${displayDetails.currency}',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _sideDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _specificationDetails(),
        if (displayDetails.packageIncludes.isNotEmpty) ...[
          const SizedBox(height: 16),
          _packageInclusions(),
        ],
        if (displayDetails.documentsRequired.isNotEmpty) ...[
          const SizedBox(height: 16),
          _documentsRequired(),
        ],
        if (displayDetails.description.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _descriptionBox(),
        ],
      ],
    );
  }

  Widget _specificationDetails() {
    final rows = [
      _SpecItem(
        _tr('Country', 'দেশ'),
        displayDetails.countryName,
        FontAwesomeIcons.flag,
      ),
      _SpecItem(
        _tr('Work Type', 'কাজের ধরন'),
        displayDetails.workType?.name ?? _tr('General', 'সাধারণ'),
      ),
      _SpecItem(
        _tr('Company Name', 'কোম্পানির নাম'),
        displayDetails.companyName,
      ),
      if (displayDetails.companyAddress.isNotEmpty)
        _SpecItem(
          _tr('Company Address', 'কোম্পানির ঠিকানা'),
          displayDetails.companyAddress,
          FontAwesomeIcons.locationDot,
        ),
      if (displayDetails.visaSponsorName.isNotEmpty)
        _SpecItem(
          _tr('Visa Sponsor', 'ভিসা স্পন্সর'),
          displayDetails.visaSponsorName,
          FontAwesomeIcons.userTie,
        ),
      if (displayDetails.visaOccupation.isNotEmpty)
        _SpecItem(
          _tr('Visa Occupation', 'ভিসা পেশা'),
          displayDetails.visaOccupation,
          FontAwesomeIcons.passport,
        ),
      _SpecItem(
        _tr('Salary', 'বেতন'),
        '${displayDetails.salary} ${displayDetails.currency}',
        FontAwesomeIcons.moneyBillWave,
      ),
      _SpecItem(
        _tr('Age Range', 'বয়সসীমা'),
        _ageRangeValue(),
        FontAwesomeIcons.userClock,
      ),
      _SpecItem(
        _tr('Gender', 'লিঙ্গ'),
        _formatEnum(displayDetails.gender),
        FontAwesomeIcons.venusMars,
      ),
      _SpecItem(
        _tr('Processing Time', 'প্রসেসিং সময়'),
        displayDetails.processingTime,
        FontAwesomeIcons.hourglassHalf,
      ),
      _SpecItem(
        _tr('Deadline', 'শেষ তারিখ'),
        _formatDate(displayDetails.applicationDeadline),
        FontAwesomeIcons.calendarXmark,
      ),
      _SpecItem(
        _tr('Selection', 'নির্বাচন'),
        _formatEnum(displayDetails.selectionType),
        FontAwesomeIcons.idBadge,
      ),
      if (displayDetails.startDate != null)
        _SpecItem(
          _tr('Application Starting Date', 'আবেদন শুরুর তারিখ'),
          _formatDate(displayDetails.startDate),
          FontAwesomeIcons.calendarPlus,
        ),
      if (displayDetails.endDate != null)
        _SpecItem(
          _tr('Application End Date', 'আবেদন শেষের তারিখ'),
          _formatDate(displayDetails.endDate),
          FontAwesomeIcons.calendarMinus,
        ),
      _SpecItem(
        _tr('Working Hours', 'কর্মঘণ্টা'),
        _tr(
          '${displayDetails.workingHours}h / Day',
          'দিনে ${displayDetails.workingHours} ঘণ্টা',
        ),
        FontAwesomeIcons.clock,
      ),
      _SpecItem(
        _tr('Quota', 'কোটা'),
        _tr('${displayDetails.quota} Positions', '${displayDetails.quota} পদ'),
        FontAwesomeIcons.users,
      ),
      _SpecItem(
        _tr('Iqama', 'ইকামা'),
        _formatEnum(displayDetails.iqama),
        FontAwesomeIcons.addressCard,
      ),
      _SpecItem(
        _tr('Accommodation', 'আবাসন'),
        _formatEnum(displayDetails.accommodation),
        FontAwesomeIcons.houseChimney,
      ),
      _SpecItem(
        _tr('Food Allowance', 'খাবার সুবিধা'),
        _formatEnum(displayDetails.food),
        FontAwesomeIcons.utensils,
      ),
      _SpecItem(
        _tr('Contract Period', 'চুক্তির মেয়াদ'),
        '${_formatEnum(displayDetails.contractDuration)} - ${displayDetails.isRenewable ? _tr('Renewable', 'নবায়নযোগ্য') : _tr('Non-Renewable', 'অ-নবায়নযোগ্য')}',
        FontAwesomeIcons.fileContract,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth > 700;
        return Wrap(
          children: rows
              .map(
                (row) => SizedBox(
                  width: twoColumns
                      ? constraints.maxWidth / 2
                      : constraints.maxWidth,
                  child: _SpecRow(item: row),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _packageInclusions() {
    if (displayDetails.packageIncludes.isEmpty) return const SizedBox.shrink();

    return _tagCard(
      title: _tr('Included in Package', 'প্যাকেজে অন্তর্ভুক্ত'),
      items: displayDetails.packageIncludes,
    );
  }

  Widget _descriptionBox() {
    if (displayDetails.description.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return _CardShell(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: _surfaceLow,
              border: Border(bottom: BorderSide(color: _outline)),
            ),
            child: Text(
              _tr('Description', 'বর্ণনা'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _text,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              displayDetails.description.trim(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _text,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentsRequired() {
    if (displayDetails.documentsRequired.isEmpty) {
      return const SizedBox.shrink();
    }

    return _tagCard(
      title: _tr('Required Documents', 'প্রয়োজনীয় ডকুমেন্ট'),
      items: displayDetails.documentsRequired,
    );
  }

  Widget _tagCard({required String title, required List<String> items}) {
    return _CardShell(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: _surfaceLow,
              border: Border(bottom: BorderSide(color: _outline)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _text,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxTagWidth = constraints.maxWidth > 0
                    ? constraints.maxWidth
                    : 240.0;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: items
                      .map(
                        (item) =>
                            _PackageTag(label: item, maxWidth: maxTagWidth),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _safetyGuidelines() {
    final tips = [
      _tr(
        'Do not leave your current work/job until your visa is confirmed.',
        'ভিসা না হওয়া অব্দি কর্ম/চাকরী ছেড়ে দিবেন না।',
      ),
      _tr(
        'Do not travel to Asia from Bangladesh through risky routes to try for Europe.',
        'বাংলাদেশ থেকে গেইম দিয়ে এশিয়ার দেশে গিয়ে ইউরোপের জন্য গেইম দিবেন না।',
      ),
      _tr(
        'Do not try to go abroad without a visa.',
        'ভিসা ছাড়া বিদেশ যাওয়ার চেষ্টা করবেন না।',
      ),
      _tr(
        "Do not trust promises of a '100% guaranteed visa'.",
        "'১০০% গ্যারান্টি ভিসা' কথায় বিশ্বাস করবেন না।",
      ),
      _tr(
        'Do not sign any document without understanding it.',
        'না জেনে কোনো কাগজে সাইন করবেন না।',
      ),
      _tr(
        'Do not take risky loans beyond your capacity.',
        'অতিরিক্ত ঋণ নিয়ে ঝুঁকি নেবেন না।',
      ),
      _tr(
        'Do not submit files with false information.',
        'ভুয়া তথ্য দিয়ে ফাইল জমা দিবেন না।',
      ),
      _tr(
        'Do not try shortcuts or illegal routes to go abroad.',
        'শর্টকাট বা অবৈধ পথে বিদেশ যাওয়ার চেষ্টা করবেন না।',
      ),
      _tr(
        'Do not submit files to multiple agencies at the same time.',
        'একাধিক এজেন্সিতে একসাথে ফাইল জমা দিবেন না।',
      ),
      _tr(
        'Do not make decisions without informing your family.',
        'পরিবারকে না জানিয়ে সিদ্ধান্ত নিবেন না।',
      ),
    ];

    final width = MediaQuery.sizeOf(context).width;
    final compactGuidelines = width <= 1080;
    final borderRadius = compactGuidelines ? 14.0 : 20.0;
    final leadingSize = compactGuidelines ? 32.0 : 48.0;
    final leadingIconSize = compactGuidelines ? 14.0 : 20.0;
    final titleFontSize = compactGuidelines ? 12.0 : 18.0;
    final subtitleFontSize = compactGuidelines ? 9.0 : 14.0;
    final tipFontSize = compactGuidelines ? 6.0 : 14.0;
    final tipIconSize = compactGuidelines ? 8.0 : 16.0;
    final itemSpacing = compactGuidelines ? 8.0 : 18.0;
    final itemRunSpacing = compactGuidelines ? 8.0 : 14.0;

    return Container(
      decoration: BoxDecoration(
        color: _errorContainer.withAlpha(107),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: _error.withAlpha(56)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: compactGuidelines ? 12 : 24,
            vertical: compactGuidelines ? 8 : 14,
          ),
          childrenPadding: EdgeInsets.fromLTRB(
            compactGuidelines ? 12 : 24,
            0,
            compactGuidelines ? 12 : 24,
            compactGuidelines ? 12 : 24,
          ),
          collapsedIconColor: _error,
          iconColor: _error,
          leading: Container(
            width: leadingSize,
            height: leadingSize,
            decoration: const BoxDecoration(
              color: _error,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.gavel,
                color: Colors.white,
                size: leadingIconSize,
              ),
            ),
          ),
          title: Text(
            _tr(
              'Safety guidelines: Things you should never do before going abroad.',
              'সতর্কতামূলক নির্দেশনা: বিদেশ যাওয়ার আগে যা কখনো করবেন না।',
            ),
            style: TextStyle(
              color: const Color(0xFF93000A),
              fontSize: titleFontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(
            _tr('Tap to view details', 'বিস্তারিত দেখতে ট্যাপ করুন'),
            style: TextStyle(
              color: const Color(0xCC93000A),
              fontSize: subtitleFontSize,
              height: compactGuidelines ? 1.2 : 1.4,
            ),
          ),
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns = constraints.maxWidth > 680;
                return Wrap(
                  spacing: itemSpacing,
                  runSpacing: itemRunSpacing,
                  children: tips
                      .map(
                        (tip) => SizedBox(
                          width: twoColumns
                              ? (constraints.maxWidth - itemSpacing) / 2
                              : constraints.maxWidth,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: compactGuidelines ? 1 : 3,
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.circleCheck,
                                  size: tipIconSize,
                                  color: _error,
                                ),
                              ),
                              SizedBox(width: compactGuidelines ? 6 : 12),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: TextStyle(
                                    color: _text,
                                    fontSize: tipFontSize,
                                    height: compactGuidelines ? 1.25 : 1.42,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceCard() {
    final agentSpending = _isLoggedIn ? displayDetails.agentPrice : null;

    debugPrint('╔══════════════════════════════════════════════════════');
    debugPrint('║ [UI] Price card rendered from work permit details');
    debugPrint('║  source             = WorkPermitDetailsScreen._priceCard()');
    debugPrint('║  slug               = ${displayDetails.slug}');
    debugPrint('║  isBn               = ${displayDetails.isBn}');
    debugPrint('║  customerPrice      = ${displayDetails.customerPrice}');
    debugPrint('║  agentPrice         = ${agentSpending ?? 'n/a'}');
    debugPrint('║  paymentSystem      = ${displayDetails.paymentSystem}');
    debugPrint('║  paymentSteps count = ${displayDetails.paymentSteps.length}');
    for (var i = 0; i < displayDetails.paymentSteps.length; i++) {
      final step = displayDetails.paymentSteps[i];
      debugPrint('║  step[$i] name=${step.name} amount=${step.amount}');
    }
    debugPrint('╚══════════════════════════════════════════════════════');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332563EB),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr('TOTAL CUSTOMER COST', 'মোট গ্রাহক খরচ'),
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'BDT ${_formatMoney(displayDetails.customerPrice)}',
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              height: 1.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          // Timeline-style payment breakdown
          if (displayDetails.paymentSteps.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              _tr('Payment System', 'পেমেন্ট পদ্ধতি'),
              style: const TextStyle(
                color: Color(0xCCFFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                for (var i = 0; i < displayDetails.paymentSteps.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PriceTimelineStep(
                      title: _paymentStepLabel(displayDetails.paymentSteps[i].name, i),
                      amount:
                          'BDT ${_formatMoney(displayDetails.paymentSteps[i].amount.toInt())}',
                      active: i == 0,
                      isLast: i == displayDetails.paymentSteps.length - 1,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }


  String _ageRangeValue() {
    final minAge = displayDetails.minAge;
    final maxAge = displayDetails.maxAge;

    if (minAge > 0 && maxAge > 0) {
      return _tr('$minAge - $maxAge\nYears', '$minAge - $maxAge\nবছর');
    }
    if (minAge > 0) return _tr('$minAge+\nYears', '$minAge+\nবছর');
    if (maxAge > 0) {
      return _tr('Up to $maxAge\nYears', '$maxAge বছর পর্যন্ত');
    }
    return _tr('N/A', 'প্রযোজ্য নয়');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return _tr('N/A', 'প্রযোজ্য নয়');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatEnum(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return _tr('N/A', 'প্রযোজ্য নয়');

    final normalized = trimmed.toLowerCase();
    if (normalized == 'self') {
      return _tr('Self', 'নিজ');
    }
    if (normalized == 'company' ||
        normalized == 'provided by company' ||
        normalized == 'company provided') {
      return _tr('Provided by company', 'কোম্পানি বহন করবে');
    }

    return trimmed
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) {
          final lower = part.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }

  Widget _bottomActions(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: _surface.withAlpha(240),
          border: const Border(top: BorderSide(color: _outline)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 18,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 390;
            return Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _onApplyNowPressed(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 48),
                      padding: EdgeInsets.symmetric(
                        vertical: compact ? 12 : 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const FaIcon(FontAwesomeIcons.paperPlane, size: 16),
                    label: Text(
                      _tr('Apply Now', 'এখন আবেদন করুন'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: compact ? 8 : 12),
                _ActionIconButton(
                  icon: const FaIcon(FontAwesomeIcons.commentDots, size: 18),
                  semanticLabel: _tr('Chat', 'চ্যাট'),
                  onPressed: () async {
                    debugPrint('╔══════════════════════════════════════════════════════');
                    debugPrint('║ [DETAILS] Chat button tapped');
                    debugPrint('║  _isLoggedIn      = $_isLoggedIn');
                    debugPrint('║  _details loaded? = ${_details != null}');
                    debugPrint('║  workPermitId     = ${_details?.id ?? widget.item.id}');
                    debugPrint('║  title            = ${_details?.title ?? widget.item.title}');
                    debugPrint('║  slug             = ${_details?.slug ?? widget.item.slug}');
                    debugPrint('╠══════════════════════════════════════════════════════');

                    if (!_isLoggedIn) {
                      debugPrint('║  ⛔ User not logged in — aborting chat');
                      debugPrint('╚══════════════════════════════════════════════════════');
                      _showMessage(context, _tr('Please login first', 'দয়া করে আগে লগইন করুন'));
                      return;
                    }
                    final service = ChatService();
                    debugPrint('║  Calling createConversation...');
                    final chat = await service.createConversation(
                      workPermitId: _details?.id.toString() ?? widget.item.id.toString(),
                      receiverRole: "CALL_CENTER",
                    );
                    if (chat != null && mounted) {
                       final title = _details?.title ?? widget.item.title;
                       final slug = _details?.slug ?? widget.item.slug;
                       final initialMessage = "Hi, I need help with my work permit: $title\n🔗 https://bideshgami.com/work-permit/$slug";
                       debugPrint('║  ✅ Conversation created: id=${chat.id}');
                       debugPrint('║  Navigating to ChatConversationScreen');
                       debugPrint('║  initialMessage = $initialMessage');
                       debugPrint('╚══════════════════════════════════════════════════════');
                       Navigator.of(context).push(
                         MaterialPageRoute(
                           builder: (_) => ChatConversationScreen(
                             chat: chat,
                             initialMessage: initialMessage,
                           ),
                         ),
                       );
                    } else if (mounted) {
                       debugPrint('║  ❌ createConversation returned null — showing error');
                       debugPrint('╚══════════════════════════════════════════════════════');
                       _showMessage(context, _tr('Failed to start chat', 'চ্যাট শুরু করতে ব্যর্থ'));
                    }
                  },
                ),
                SizedBox(width: compact ? 8 : 12),
                _ActionIconButton(
                  icon: const FaIcon(FontAwesomeIcons.bookmark, size: 18),
                  semanticLabel: _tr('Bookmark', 'বুকমার্ক'),
                  onPressed: () => _showMessage(
                    context,
                    _tr('Saved to bookmarks', 'বুকমার্কে সংরক্ষণ করা হয়েছে'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onApplyNowPressed(BuildContext context) async {
    debugPrint('╔══════════════════════════════════════════════════════');
    debugPrint('║ [ACTION] Apply now tapped');
    debugPrint('║  source             = WorkPermitDetailsScreen._onApplyNowPressed()');
    debugPrint('║  slug               = ${displayDetails.slug}');
    debugPrint('║  title              = ${displayDetails.title}');
    debugPrint('║  customerPrice      = ${displayDetails.customerPrice}');
    debugPrint('║  isBn               = ${displayDetails.isBn}');
    debugPrint('║  paymentSteps count = ${displayDetails.paymentSteps.length}');
    debugPrint('║  isLoggedIn         = $_isLoggedIn');
    debugPrint('╚══════════════════════════════════════════════════════');

    if (_isLoggedIn) {
      debugPrint('║ [APPLY] User is logged in — navigating to bulk booking screen');
      
      // Convert WorkPermitDetails into WorkPermitItem to feed the BulkBookingFormScreen
      final workPermitItem = WorkPermitItem(
        id: displayDetails.id,
        title: displayDetails.title,
        slug: displayDetails.slug,
        image: displayDetails.image,
        customerPrice: displayDetails.customerPrice,
        agentPrice: displayDetails.agentPrice ?? displayDetails.packagePrice ?? 0,
        countryName: displayDetails.countryName,
        countryFlag: displayDetails.countryFlag,
        workType: displayDetails.workType?.name ?? 'Work Permit',
        selectionType: displayDetails.selectionType,
        createdAt: displayDetails.createdAt,
      );

      debugPrint('║ [APPLY] Converted details to WorkPermitItem: id=${workPermitItem.id}, title="${workPermitItem.title}", country="${workPermitItem.countryName}"');
      debugPrint('║ [APPLY] Pushing BulkBookingFormScreen onto navigation stack');

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => BulkBookingFormScreen(item: workPermitItem),
        ),
      );
      return;
    }

    debugPrint('║ [APPLY] User is not logged in — showing sign-in dialog');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _tr('Need to sign in or sign up', 'সাইন ইন বা সাইন আপ করতে হবে'),
          ),
          content: Text(
            _tr(
              'Please sign in or sign up to continue with your application.',
              'আবেদন চালিয়ে যেতে অনুগ্রহ করে সাইন ইন বা সাইন আপ করুন।',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push('/login');
              },
              child: Text(_tr('Sign In', 'সাইন ইন')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push(AppRoutes.agentSignUp);
              },
              child: Text(_tr('Sign Up', 'সাইন আপ')),
            ),
          ],
        );
      },
    );
  }

  static String _formatMoney(int amount) {
    final text = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final remaining = text.length - i;
      buffer.write(text[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

  Widget _buildSimilarPermitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tr('Similar Work Permits', 'একই ধরনের ওয়ার্ক পারমিট'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _text,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 375,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: displaySimilar.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) => SizedBox(
              width: MediaQuery.of(context).size.width > 320
                  ? 300
                  : MediaQuery.of(context).size.width * 0.85,
              child: WorkPermitCard(
                item: displaySimilar[index],
                brandBlue: _brandBlue,
                onViewDetails: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          WorkPermitDetailsScreen(item: displaySimilar[index]),
                    ),
                  );
                },
                formatBdt: _formatMoney,
                timeAgo: _timeAgo,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final Widget icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _mutedText,
          side: const BorderSide(color: _outline),
          minimumSize: const Size(48, 48),
          fixedSize: const Size(48, 48),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: icon,
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outline),
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.fontSize = 12});

  final String label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDBE1FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: const Color(0xFF00174B),
          fontSize: fontSize,
          letterSpacing: 0.7,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({
    required this.icon,
    required this.label,
    this.color = _mutedText,
    this.bold = false,
    this.fontSize = 13,
  });

  final Widget icon;
  final String label;
  final Color color;
  final bool bold;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.detail,
  });

  final Widget icon;
  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: _mutedText, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _text,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 6),
            Text(
              detail!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _mutedText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecItem {
  const _SpecItem(this.label, this.value, [this.icon]);

  final String label;
  final String value;
  final IconData? icon;
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.item});

  final _SpecItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _outline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _mutedText,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 6, child: _SpecValue(item: item, alignRight: true)),
        ],
      ),
    );
  }
}

class _SpecValue extends StatelessWidget {
  const _SpecValue({required this.item, required this.alignRight});

  final _SpecItem item;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignRight
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.icon != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: FaIcon(item.icon, size: 14, color: _mutedText),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: alignRight ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              color: _text,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _PackageTag extends StatelessWidget {
  const _PackageTag({required this.label, required this.maxWidth});

  final String label;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFDAE2FD),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.circleCheck,
              size: 14,
              color: _brandBlue,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF5C647A),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceTimelineStep extends StatelessWidget {
  const _PriceTimelineStep({
    required this.title,
    required this.amount,
    this.active = false,
    this.isLast = false,
  });

  final String title;
  final String amount;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dotColor = active ? _brandBlue : const Color(0xFFDBE1FF);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: _outline)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
