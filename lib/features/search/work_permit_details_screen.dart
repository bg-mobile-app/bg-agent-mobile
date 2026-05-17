import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../home/models/home_models.dart';
import '../home/widgets/work_permit_card.dart';
import 'models/work_permit_details.dart';
import 'services/work_permit_service.dart';

const Color _brandBlue = Color(0xFF2563EB);
const Color _primary = Color(0xFF004AC6);
const Color _background = Color(0xFFF8F9FF);
const Color _surface = Color(0xFFFFFFFF);
const Color _surfaceLow = Color(0xFFEFF4FF);
const Color _surfaceHigh = Color(0xFFDCE9FF);
const Color _outline = Color(0xFFC3C6D7);
const Color _text = Color(0xFF0B1C30);
const Color _mutedText = Color(0xFF434655);
const Color _error = Color(0xFFBA1A1A);
const Color _errorContainer = Color(0xFFFFDAD6);

class WorkPermitDetailsScreen extends StatefulWidget {
  const WorkPermitDetailsScreen({super.key, required this.item});

  final WorkPermitItem item;

  @override
  State<WorkPermitDetailsScreen> createState() => _WorkPermitDetailsScreenState();
}

class _WorkPermitDetailsScreenState extends State<WorkPermitDetailsScreen> {
  bool _isLoading = true;
  WorkPermitDetails? _details;
  List<WorkPermitItem> _similarPermits = [];
  final WorkPermitService _service = WorkPermitService();

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final details = await _service.getWorkPermitDetails(widget.item.slug);
    final similar = await _service.getSimilarWorkPermits(widget.item.slug);
    if (mounted) {
      setState(() {
        _details = details;
        _similarPermits = similar;
        _isLoading = false;
      });
    }
  }

  WorkPermitDetails get displayDetails => _details ?? _getDummyDetails();
  List<WorkPermitItem> get displaySimilar => _isLoading ? [widget.item, widget.item] : _similarPermits;

  WorkPermitDetails _getDummyDetails() {
    return WorkPermitDetails(
      id: 0,
      slug: widget.item.slug,
      status: 'Active',
      customerPrice: 150000,
      agentPrice: 120000,
      countryName: widget.item.countryName,
      countryFlag: '',
      image: widget.item.image,
      agency: AgencyProps(id: 1, name: 'Dummy Agency Name', rlNumber: '1234', logo: ''),
      workType: WorkTypeProps(id: 1, name: 'Cleaner Worker'),
      favoriteCount: 0,
      bookedQuota: 0,
      availableQuota: 100,
      title: widget.item.title,
      companyName: 'Dummy Company Name Ltd.',
      companyAddress: 'Dummy Address',
      selectionType: 'Direct',
      visaOccupation: 'Worker',
      salary: 1000,
      currency: 'USD',
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
      description: 'Dummy description...',
      paymentSteps: [
        PaymentStepProps(name: 'Step 1: Initial Booking', amount: 50000, percentage: '30%'),
        PaymentStepProps(name: 'Step 2: After Visa', amount: 50000, percentage: '30%'),
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
          icon: const Icon(Icons.arrow_back, color: _brandBlue),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        titleSpacing: 0,
        title: const Text(
          'Urgent Recruitment in Jordan',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _brandBlue,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showMessage(context, 'Share option coming soon'),
            icon: const FaIcon(
              FontAwesomeIcons.shareNodes,
              color: _mutedText,
              size: 18,
            ),
          ),
        ],
      ),
      body: _details == null && !_isLoading
          ? const Center(child: Text('Failed to load details.'))
          : Skeletonizer(
              enabled: _isLoading,
              child: SafeArea(
                bottom: false,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _heroImage(isDesktop)),
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
                  128,
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
      ), // Close Skeletonizer
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

  Widget _heroImage(bool isDesktop) {
    return SizedBox(
      height: isDesktop ? 420 : 210,
      width: double.infinity,
      child: displayDetails.image.startsWith('http')
          ? Image.network(displayDetails.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported))
          : Image.asset(widget.item.image, fit: BoxFit.cover),
    );
  }

  Widget _headlineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            _Pill(label: 'Recruitment Open'),
            _IconText(
              icon: FaIcon(
                FontAwesomeIcons.circleCheck,
                color: _brandBlue,
                size: 14,
              ),
              label: 'Agency Verified',
              color: _brandBlue,
              bold: true,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          displayDetails.title,
          style: const TextStyle(
            color: _text,
            fontSize: 30,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: [
            _IconText(
              icon: const FaIcon(FontAwesomeIcons.calendarDays, size: 14),
              label: 'Posted: ${displayDetails.createdAt.toString().split(' ')[0]}',
            ),
            _IconText(
              icon: const FaIcon(FontAwesomeIcons.fingerprint, size: 14),
              label: 'Post ID: ${displayDetails.id}',
            ),
          ],
        ),
      ],
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
                  label: 'Quota',
                  value: '${displayDetails.quota}\nPositions',
                ),
                _StatCard(
                  icon: const FaIcon(
                    FontAwesomeIcons.clock,
                    color: _brandBlue,
                    size: 20,
                  ),
                  label: 'Work Hours',
                  value: '${displayDetails.workingHours}h / Day',
                ),
                _StatCard(
                  icon: const FaIcon(
                    FontAwesomeIcons.briefcase,
                    color: _brandBlue,
                    size: 20,
                  ),
                  label: 'Experience',
                  value: displayDetails.experienceRequired,
                ),
                _StatCard(
                  icon: const FaIcon(
                    FontAwesomeIcons.locationDot,
                    color: _brandBlue,
                    size: 20,
                  ),
                  label: 'Age Range',
                  value: '${displayDetails.minAge}-${displayDetails.maxAge} Years',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _specificationsCard(),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 650;
            final cards = [
              _InfoCard(
                icon: const FaIcon(
                  FontAwesomeIcons.hourglassHalf,
                  size: 15,
                  color: _primary,
                ),
                label: 'Processing Time',
                value: displayDetails.processingTime,
                color: _primary,
              ),
              _InfoCard(
                icon: const FaIcon(
                  FontAwesomeIcons.calendarXmark,
                  size: 15,
                  color: _error,
                ),
                label: 'Deadline',
                value: displayDetails.applicationDeadline != null ? displayDetails.applicationDeadline.toString().split(' ')[0] : 'N/A',
                color: _error,
              ),
              _InfoCard(
                icon: const FaIcon(
                  FontAwesomeIcons.idBadge,
                  size: 15,
                  color: _mutedText,
                ),
                label: 'Selection',
                value: displayDetails.selectionType,
                color: _mutedText,
              ),
            ];
            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cards
                    .map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: card,
                      ),
                    )
                    .toList(),
              );
            }
            return Row(
              children: cards
                  .map(
                    (card) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: card,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        _packageInclusions(),
        const SizedBox(height: 24),
        _safetyGuidelines(),
      ],
    );
  }

  Widget _sideDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _priceCard(),
        const SizedBox(height: 16),
        _paymentBreakdown(),
        const SizedBox(height: 16),
        _agencyInfo(),
      ],
    );
  }

  Widget _specificationsCard() {
    final rows = [
      _SpecItem('Country', displayDetails.countryName, FontAwesomeIcons.flag),
      _SpecItem('Work Type', displayDetails.workType?.name ?? 'General'),
      _SpecItem('Company Name', displayDetails.companyName),
      _SpecItem('Accommodation', displayDetails.accommodation),
      _SpecItem('Food Allowance', displayDetails.food),
      _SpecItem('Contract Period', '${displayDetails.contractDuration} (${displayDetails.isRenewable ? "Renewable" : "Non-Renewable"})'),
    ];

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
            child: const Text(
              'Contract Specifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _text,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth > 620;
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
          ),
        ],
      ),
    );
  }

  Widget _packageInclusions() {
    if (displayDetails.packageIncludes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Included in Package',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _text,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: displayDetails.packageIncludes
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDAE2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(FontAwesomeIcons.circleCheck, size: 14, color: _brandBlue),
                      const SizedBox(width: 8),
                      Text(
                        item,
                        style: const TextStyle(
                          color: Color(0xFF5C647A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _safetyGuidelines() {
    const tips = [
      'Do not quit your current job until the visa is stamped.',
      'Do not trust 100% guarantees; recruitment is subject to embassy approval.',
      'Always verify the agency\'s license number with the Ministry.',
      'Never pay full amounts in cash without a proper receipt.',
      'Verify your medical report status only through official GAMCA portal.',
      'Avoid brokers and agents; deal directly with the office.',
      'Keep a digital copy of all submitted documents.',
      'Ensure your passport has at least 1 year of validity.',
      'Do not sign blank papers or incomplete contracts.',
      'Report any suspicious demands to our support team immediately.',
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _errorContainer.withAlpha(107),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _error.withAlpha(56)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: _error,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.gavel,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Critical Safety Guidelines',
                      style: TextStyle(
                        color: Color(0xFF93000A),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Read carefully before proceeding with any recruitment process',
                      style: TextStyle(color: Color(0xCC93000A), height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth > 680;
              return Wrap(
                spacing: 18,
                runSpacing: 14,
                children: tips
                    .map(
                      (tip) => SizedBox(
                        width: twoColumns
                            ? (constraints.maxWidth - 18) / 2
                            : constraints.maxWidth,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: FaIcon(
                                FontAwesomeIcons.circleCheck,
                                size: 16,
                                color: _error,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(
                                  color: _text,
                                  fontSize: 14,
                                  height: 1.42,
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
    );
  }

  Widget _priceCard() {
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
          const Text(
            'TOTAL CUSTOMER COST',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'BDT ${_formatMoney(displayDetails.customerPrice)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Monthly Salary',
                  style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 14),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${displayDetails.salary} ${displayDetails.currency}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.moneyBillWave,
                  size: 16,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Standard Overseas Benefits Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentBreakdown() {
    if (displayDetails.paymentSteps.isEmpty) return const SizedBox.shrink();

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          const SizedBox(height: 22),
          Column(
            children: [
              for (var index = 0; index < displayDetails.paymentSteps.length; index++)
                _TimelineStep(
                  step: _PaymentStep(
                    displayDetails.paymentSteps[index].name,
                    'BDT ${_formatMoney(displayDetails.paymentSteps[index].amount.toInt())}',
                    '${displayDetails.paymentSteps[index].percentage} of total',
                    index == 0,
                  ),
                  isLast: index == displayDetails.paymentSteps.length - 1,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _agencyInfo() {
    if (displayDetails.agency == null) return const SizedBox.shrink();

    return _CardShell(
      color: _surfaceLow,
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _outline),
            ),
            child: displayDetails.agency!.logo.isNotEmpty 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(displayDetails.agency!.logo, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(
                    child: FaIcon(FontAwesomeIcons.buildingCircleCheck, color: _brandBlue, size: 24),
                  )),
                )
              : const Center(
                  child: FaIcon(
                    FontAwesomeIcons.buildingCircleCheck,
                    color: _brandBlue,
                    size: 24,
                  ),
                ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayDetails.agency!.name,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RL-${displayDetails.agency!.rlNumber} • Licensed Agency',
                  style: const TextStyle(color: _mutedText, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                    onPressed: () =>
                        _showMessage(context, 'Application process coming soon'),
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
                    label: const Text(
                      'Apply Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: compact ? 8 : 12),
                _ActionIconButton(
                  icon: const FaIcon(FontAwesomeIcons.commentDots, size: 18),
                  semanticLabel: 'Chat',
                  onPressed: () =>
                      _showMessage(context, 'Chat option coming soon'),
                ),
                SizedBox(width: compact ? 8 : 12),
                _ActionIconButton(
                  icon: const FaIcon(FontAwesomeIcons.bookmark, size: 18),
                  semanticLabel: 'Bookmark',
                  onPressed: () => _showMessage(context, 'Saved to bookmarks'),
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
        const Text(
          'Similar Work Permits',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _text,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 540,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: displaySimilar.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) => SizedBox(
              width: MediaQuery.of(context).size.width > 320 ? 300 : MediaQuery.of(context).size.width * 0.85,
              child: WorkPermitCard(
                item: displaySimilar[index],
                brandBlue: _brandBlue,
                onViewDetails: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => WorkPermitDetailsScreen(item: displaySimilar[index]),
                    ),
                  );
                },
                formatBdt: _formatMoney,
                timeAgo: (date) => '', // Fallback or format actual date
              ),
            ),
          ),
        ),
      ],
    );
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
    this.color = _surface,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outline),
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

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
        style: const TextStyle(
          color: Color(0xFF00174B),
          fontSize: 12,
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
  });

  final Widget icon;
  final String label;
  final Color color;
  final bool bold;

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
            fontSize: 13,
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
  });

  final Widget icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: _mutedText,
              fontSize: 12,
            ),
          ),
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
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final Widget icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: _text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
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
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _outline),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                color: _mutedText,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  FaIcon(
                    item.icon,
                    size: 14,
                    color: _mutedText,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    item.value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
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

class _PaymentStep {
  const _PaymentStep(this.title, this.amount, this.description, this.active);

  final String title;
  final String amount;
  final String description;
  final bool active;
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.step, required this.isLast});

  final _PaymentStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dotColor = step.active
        ? _brandBlue
        : const Color(0xFFDBE1FF);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: _outline,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title.toUpperCase(),
                    style: TextStyle(
                      color: step.active
                          ? _brandBlue
                          : _mutedText,
                      fontSize: 11,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.amount,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.description,
                    style: const TextStyle(
                      color: _mutedText,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
