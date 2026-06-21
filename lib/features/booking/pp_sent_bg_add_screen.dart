import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../common/theme/app_palette.dart';
import '../../common/theme/app_text_styles.dart';
import '../../routes/navigation_history.dart';
import 'services/booking_service.dart';

class PPSentBGAddScreen extends StatefulWidget {
  const PPSentBGAddScreen({super.key, required this.initialBookingId});

  final int initialBookingId;

  @override
  State<PPSentBGAddScreen> createState() => _PPSentBGAddScreenState();
}

class _PPSentBGAddScreenState extends State<PPSentBGAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _employeeOfController = TextEditingController();

  bool _isLoadingInitial = true;
  bool _isSubmitting = false;
  ReceiveBookingItemDto? _initialBooking;
  final List<ReceiveBookingItemDto> _additionalBookings = [];

  @override
  void initState() {
    super.initState();
    _loadInitialBooking();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _emailController.dispose();
    _employeeOfController.dispose();
    super.dispose();
  }

  void _goBack() {
    debugPrint('PPSentBGAddScreen: navigating back');
    if (Navigator.canPop(context)) {
      context.pop();
    } else if (AppNavigationHistory.canPop) {
      final prev = AppNavigationHistory.pop();
      debugPrint('PPSentBGAddScreen: going to history route: $prev');
      if (prev != null) {
        context.go(prev);
      }
    } else {
      debugPrint('PPSentBGAddScreen: falling back to ticket-done booking list');
      context.go('/dashboard/receive-booking/ticket-done');
    }
  }

  Future<void> _loadInitialBooking() async {
    debugPrint('PPSentBGAddScreen: Loading initial booking with ID ${widget.initialBookingId}');
    try {
      debugPrint('PPSentBGAddScreen: Trying to fetch booking detail directly from /booking/wp/${widget.initialBookingId}/');
      try {
        final detail = await _bookingService.getReceiveBookingDetail(widget.initialBookingId);
        debugPrint('PPSentBGAddScreen: Successfully fetched booking details directly.');
        if (mounted) {
          setState(() {
            _initialBooking = detail;
            _isLoadingInitial = false;
          });
        }
        return;
      } catch (detailError) {
        debugPrint('PPSentBGAddScreen: Direct fetch failed ($detailError), trying fallback list fetch...');
      }

      final response = await _bookingService.getReceiveBookings(
        status: 'TICKET_DONE',
        page: 1,
      );
      debugPrint('PPSentBGAddScreen: Fallback list API returned ${response.results.length} results');
      final match = response.results.firstWhere(
        (item) => item.id == widget.initialBookingId,
        orElse: () => throw Exception('Booking not found under TICKET_DONE status.'),
      );
      debugPrint('PPSentBGAddScreen: Found matching booking ${match.name} (ID: ${match.id})');
      if (mounted) {
        setState(() {
          _initialBooking = match;
          _isLoadingInitial = false;
        });
      }
    } catch (e, stacktrace) {
      debugPrint('PPSentBGAddScreen: Error loading initial booking: $e\n$stacktrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load initial booking details: $e')),
        );
        _goBack();
      }
    }
  }

  void _openAddPassportsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => _AddPassportsModal(
        bookingService: _bookingService,
        excludeIds: [
          widget.initialBookingId,
          ..._additionalBookings.map((b) => b.id),
        ],
        onAdd: (selected) {
          setState(() {
            _additionalBookings.addAll(selected);
          });
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_initialBooking == null) return;

    final List<int> bookingIds = [
      _initialBooking!.id,
      ..._additionalBookings.map((b) => b.id),
    ];

    debugPrint('PPSentBGAddScreen: Submitting passport list with booking IDs $bookingIds');
    setState(() => _isSubmitting = true);

    try {
      await _bookingService.submitSendPassportRequest(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        employeeId: _employeeIdController.text.trim(),
        email: _emailController.text.trim(),
        employeeOf: _employeeOfController.text.trim(),
        bookingIds: bookingIds,
      );

      debugPrint('PPSentBGAddScreen: Submit successful');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passport delivery list submitted successfully.')),
      );
      _goBack();
    } catch (e, stacktrace) {
      debugPrint('PPSentBGAddScreen: Submit failed: $e\n$stacktrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit passport list: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.pageBackground,
      appBar: AppBar(
        title: const Text('Send Passport to BG', style: AppTextStyles.subtitle1),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: _isLoadingInitial
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Delivery Details'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _fullNameController,
                        labelText: 'Full Name',
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _phoneController,
                        labelText: 'Phone',
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _employeeIdController,
                        labelText: 'Employee ID',
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Required';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _employeeOfController,
                        labelText: 'Employee Of (Company/Organization)',
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionTitle('Passports to Send'),
                          TextButton.icon(
                            onPressed: _openAddPassportsSheet,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add More'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppPalette.textStrongBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildBookingCard(_initialBooking!, isInitial: true),
                      ..._additionalBookings.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _buildBookingCard(item, isInitial: false),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppPalette.textStrongBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Submit Deliveries',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppPalette.textStrongBlue,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD8E3FA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD8E3FA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.textStrongBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBookingCard(ReceiveBookingItemDto item, {required bool isInitial}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${item.id} | WP ID: ${item.workPermitId}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (item.passportNo != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Passport: ${item.passportNo}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (isInitial)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Locked',
                style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
              onPressed: () {
                setState(() {
                  _additionalBookings.removeWhere((b) => b.id == item.id);
                });
              },
            ),
        ],
      ),
    );
  }
}

class _AddPassportsModal extends StatefulWidget {
  const _AddPassportsModal({
    required this.bookingService,
    required this.excludeIds,
    required this.onAdd,
  });

  final BookingService bookingService;
  final List<int> excludeIds;
  final ValueChanged<List<ReceiveBookingItemDto>> onAdd;

  @override
  State<_AddPassportsModal> createState() => _AddPassportsModalState();
}

class _AddPassportsModalState extends State<_AddPassportsModal> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<ReceiveBookingItemDto> _bookings = [];
  final List<ReceiveBookingItemDto> _selectedBookings = [];

  @override
  void initState() {
    super.initState();
    _fetchTicketDoneBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTicketDoneBookings() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.bookingService.getReceiveBookings(
        status: 'TICKET_DONE',
        page: 1,
        search: _searchController.text.trim(),
      );
      setState(() {
        _bookings = response.results
            .where((item) => !widget.excludeIds.contains(item.id))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load bookings list.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Additional Passports',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by ID, name, passport...',
              isDense: true,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check_circle_outline_rounded),
                onPressed: _fetchTicketDoneBookings,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _fetchTicketDoneBookings(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _bookings.isEmpty
                    ? const Center(child: Text('No matching bookings found.'))
                    : ListView.builder(
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final item = _bookings[index];
                          final isSelected = _selectedBookings.any((b) => b.id == item.id);
                          return CheckboxListTile(
                            title: Text(item.name),
                            subtitle: Text('ID: ${item.id} | WP ID: ${item.workPermitId}'),
                            value: isSelected,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedBookings.add(item);
                                } else {
                                  _selectedBookings.removeWhere((b) => b.id == item.id);
                                }
                              });
                            },
                          );
                        },
                      ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _selectedBookings.isEmpty
                  ? null
                  : () {
                      widget.onAdd(_selectedBookings);
                      Navigator.pop(context);
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.textStrongBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Add ${_selectedBookings.length} Selected'),
            ),
          ),
        ],
      ),
    );
  }
}
