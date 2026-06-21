import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/styled_data_table_card.dart';
import '../../common/widgets/view_toggle_button.dart';
import '../../common/theme/app_palette.dart';
import 'widgets/received_booking_card.dart';
import '../home/dashboard_screen.dart';
import 'services/booking_service.dart';

class _BookingStatusFilterOption {
  const _BookingStatusFilterOption({required this.value, required this.label});

  final String value;
  final String label;
}

const List<_BookingStatusFilterOption> _bookingStatusFilterOptions = [
  _BookingStatusFilterOption(value: '', label: 'All Booking'),
  _BookingStatusFilterOption(value: 'APPLIED_FILE', label: 'Applied Booking'),
  _BookingStatusFilterOption(
    value: 'BG_COLLECT_PP',
    label: 'BG Collect Passport',
  ),
  _BookingStatusFilterOption(value: 'BG_SENT_PP', label: 'BG Sent Passport'),
  _BookingStatusFilterOption(value: 'A_RECEIVE_PP', label: 'Receive Passport'),
  _BookingStatusFilterOption(
    value: 'UNDER_PROCESSING',
    label: 'Under Processing',
  ),
  _BookingStatusFilterOption(value: 'VISA_APPROVED', label: 'Visa Approved'),
  _BookingStatusFilterOption(value: 'BMET_DONE', label: 'BMET Done'),
  _BookingStatusFilterOption(value: 'TICKET_DONE', label: 'Ticket Done'),
  _BookingStatusFilterOption(value: 'PP_SENT_TO_BG', label: 'PP Sent to BG'),
  _BookingStatusFilterOption(
    value: 'BG_RECEIVED_PP',
    label: 'BG Receive Passport',
  ),
  _BookingStatusFilterOption(
    value: 'READY_FOR_FLIGHT',
    label: 'Ready For Flight',
  ),
  _BookingStatusFilterOption(value: 'SUCCESS_FLIGHT', label: 'Success Flight'),
  _BookingStatusFilterOption(value: 'REJECT_FILE', label: 'Reject File'),
];

class ReceivedAllBookingScreen extends StatefulWidget {
  const ReceivedAllBookingScreen({
    super.key,
    this.initialStatus = '',
    this.pageTitle = 'All Booking',
    this.currentHref = '/dashboard/receive-booking/all-booking',
  });
  final String initialStatus;
  final String pageTitle;
  final String currentHref;

  @override
  State<ReceivedAllBookingScreen> createState() =>
      _ReceivedAllBookingScreenState();
}

class _ReceivedAllBookingScreenState extends State<ReceivedAllBookingScreen> {
  bool _isCardView = true;
  late final TextEditingController _searchController;
  String _searchQuery = '';
  late String _selectedStatus;
  DateTimeRange? _selectedDateRange;

  final BookingService _bookingService = BookingService();
  List<BookingItem> _bookings = const [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedStatus = widget.initialStatus;
    _fetchBookings();
  }

  @override
  void didUpdateWidget(covariant ReceivedAllBookingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final statusChanged = oldWidget.initialStatus != widget.initialStatus;
    final routeChanged = oldWidget.currentHref != widget.currentHref;
    if (!statusChanged && !routeChanged) return;

    _selectedStatus = widget.initialStatus;
    _searchController.clear();
    _searchQuery = '';
    _selectedDateRange = null;
    _fetchBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _selectedStatusLabel {
    for (final option in _bookingStatusFilterOptions) {
      if (option.value == _selectedStatus) return option.label;
    }
    return widget.pageTitle;
  }

  List<BookingItem> get _filteredBookings {
    final query = _searchQuery.trim().toLowerCase();
    return _bookings.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.workPermitId.toLowerCase().contains(query) ||
          item.id.toString().contains(query) ||
          item.serviceType.toLowerCase().contains(query) ||
          item.name.toLowerCase().contains(query) ||
          item.passportNo.toLowerCase().contains(query) ||
          item.statusLabel.toLowerCase().contains(query);
      final matchesStatus =
          _selectedStatus.isEmpty || item.status == _selectedStatus;
      final createdAt = DateTime.tryParse(item.createdAt);
      final matchesDate =
          _selectedDateRange == null ||
          (createdAt != null &&
              !createdAt.isBefore(_selectedDateRange!.start) &&
              !createdAt.isAfter(_selectedDateRange!.end));
      return matchesQuery && matchesStatus && matchesDate;
    }).toList();
  }

  List<BookingItem> get _skeletonBookings => List.generate(
    6,
    (index) => BookingItem(
      workPermitId: 'WP-XXXX',
      id: 1000 + index,
      serviceType: 'Work Permit',
      createdAt: '2026-01-01T00:00:00Z',
      name: 'Loading Name',
      passportNo: 'P0000000',
      fromCountry: 'Bangladesh',
      toCountry: 'Saudi Arabia',
      agencyTotalCost: 0,
      paidAmount: 0,
      status: _selectedStatus.isEmpty ? 'APPLIED_FILE' : _selectedStatus,
      statusLabel: 'Loading',
    ),
  );

  List<BookingItem> get _visibleBookings =>
      _isLoading && _bookings.isEmpty ? _skeletonBookings : _filteredBookings;

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _bookingService.getReceiveBookings(
        status: _selectedStatus,
        search: _searchQuery,
        page: 1,
        fromDate: _selectedDateRange == null
            ? null
            : _formatApiDate(_selectedDateRange!.start),
        toDate: _selectedDateRange == null
            ? null
            : _formatApiDate(_selectedDateRange!.end),
      );

      if (!mounted) return;
      setState(() {
        _bookings = response.results.map(_mapDtoToBookingItem).toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Failed to load bookings. Please try again.',
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBookingAction(BookingItem item, String action) async {
    switch (action) {
      case 'Receive Passport':
        await _confirmStatusUpdate(
          item: item,
          dialogTitle: 'Receive Passport?',
          dialogMessage:
              'Confirm that passport for booking #${item.id} has been received?',
          status: 'A_RECEIVE_PP',
          successMessage: 'Passport received successfully.',
          errorMessage: 'Failed to receive passport. Please try again.',
        );
        break;
      case 'Sent to Processing':
        await _confirmStatusUpdate(
          item: item,
          dialogTitle: 'Send to Processing?',
          dialogMessage: 'Move booking #${item.id} to Under Processing?',
          status: 'UNDER_PROCESSING',
          successMessage: 'Booking sent to processing successfully.',
          errorMessage:
              'Failed to send booking to processing. Please try again.',
        );
        break;
      case 'Payment Request':
        await _showPaymentRequestDialog(item);
        break;
      case 'Upload Documents':
        await _showUploadDocumentsDialog(item);
        break;
      case 'Add Reminder':
        await _showReminderDialog(item);
        break;
      case 'Visa Reminder':
        await _showVisaReminderDialog(item);
        break;
      case 'Visa Approved':
        await _confirmStatusUpdate(
          item: item,
          dialogTitle: 'Visa Approved?',
          dialogMessage: 'Mark this passport as visa approved?',
          status: 'VISA_APPROVED',
          successMessage: 'Booking marked as visa approved successfully.',
          errorMessage: 'Failed to mark visa approved. Please try again.',
        );
        break;
      case 'BMET Done':
        await _confirmStatusUpdate(
          item: item,
          dialogTitle: 'BMET Done?',
          dialogMessage: 'Mark as BMET done?',
          status: 'BMET_DONE',
          successMessage: 'BMET Done successfully for ${item.passportNo}',
          errorMessage: 'Failed to mark BMET done. Please try again.',
        );
        break;
      case 'Ticket Done':
        await _confirmStatusUpdate(
          item: item,
          dialogTitle: 'Mark as Ticket Done?',
          dialogMessage: 'Mark this booking as Ticket Done?',
          status: 'TICKET_DONE',
          successMessage: 'Ticket Done successfully for ${item.passportNo}',
          errorMessage: 'Failed to mark ticket done. Please try again.',
        );
        break;
      case 'View Documents':
        context.go('/dashboard/booking/documents/${item.id}');
        break;
      case 'PP Send to BG':
        debugPrint('Navigating to PP Send to BG form for booking ${item.id}');
        context.go('/dashboard/agency/booking-file/pp-sent-bg/add/${item.id}');
        break;
      case 'Reject':
      case 'Reject File':
        context.go('/dashboard/agency/booking-file/return/request/${item.id}');
        break;
    }
  }

  Future<void> _confirmStatusUpdate({
    required BookingItem item,
    required String dialogTitle,
    required String dialogMessage,
    required String status,
    required String successMessage,
    required String errorMessage,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogTitle),
        content: Text(dialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      debugPrint(
        'Updating booking ${item.id} (${item.passportNo}) status from ${item.status} to $status',
      );
      await _bookingService.updateBookingStatus(
        bookingId: item.id,
        status: status,
      );
      debugPrint('Status update successful for booking ${item.id} to $status');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
      await _fetchBookings();
    } catch (error, stackTrace) {
      debugPrint('Status update failed for booking ${item.id}: $error');
      debugPrint(stackTrace.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<void> _showPaymentRequestDialog(BookingItem item) async {
    final amountController = TextEditingController();
    final step = _paymentRequestStepFor(item.status);
    final isAmountRequired =
        item.status != 'VISA_APPROVED' && item.status != 'TICKET_DONE';
    String? validationError;

    final request = await showDialog<_PaymentRequestInput>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Payment Request'),
          content: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: isAmountRequired
                  ? 'Request Amount'
                  : 'Request Amount (Optional)',
              prefixText: '৳ ',
              errorText: validationError,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final rawAmount = amountController.text.trim().replaceAll(
                  ',',
                  '',
                );
                final amount = rawAmount.isEmpty
                    ? null
                    : num.tryParse(rawAmount);
                if (isAmountRequired && (amount == null || amount <= 0)) {
                  setDialogState(
                    () => validationError = 'Enter a valid request amount.',
                  );
                  return;
                }
                if (amount != null && amount <= 0) {
                  setDialogState(
                    () => validationError = 'Enter a valid request amount.',
                  );
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  _PaymentRequestInput(requestAmount: amount),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      amountController.dispose();
    });

    if (request == null) return;

    try {
      final payload = {
        'booking': item.id,
        'step': step,
        'requestAmount': request.requestAmount,
      };
      debugPrint('Submitting payment request: $payload');
      await _bookingService.submitAgencyPayoutRequest(
        bookingId: item.id,
        step: step,
        requestAmount: request.requestAmount,
      );
      debugPrint('Payment request API call completed for booking ${item.id}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment Request submitted successfully.'),
        ),
      );
      await _fetchBookings();
    } catch (_) {
      debugPrint('Payment request failed for booking ${item.id}');
      // attempt to print stack trace if available
      try {
        // no-op: placeholder to hint stacktrace availability in catch
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit payment request. Please try again.'),
        ),
      );
    }
  }

  String _paymentRequestStepFor(String status) {
    switch (status) {
      case 'VISA_APPROVED':
        return 'AFTER_VISA';
      case 'TICKET_DONE':
        return 'BEFORE_FLIGHT';
      case 'A_RECEIVE_PP':
      default:
        return 'ADVANCE';
    }
  }

  Future<void> _showUploadDocumentsDialog(BookingItem item) async {
    var selectedFiles = <PlatformFile>[];
    final fileTitleControllers = <String, TextEditingController>{};
    String? validationError;

    try {
      final shouldUpload = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Upload Documents'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accepted: PDF, JPG, JPEG, PNG, WEBP. Each file will be uploaded separately.',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                        type: FileType.custom,
                        allowedExtensions: const [
                          'pdf',
                          'jpg',
                          'jpeg',
                          'png',
                          'webp',
                        ],
                        withData: true,
                      );
                      if (result == null) return;
                      setDialogState(() {
                        selectedFiles = result.files;
                        validationError = null;
                        final controllersToDispose = List<TextEditingController>.from(fileTitleControllers.values);
                        fileTitleControllers.clear();
                        for (final file in selectedFiles) {
                          fileTitleControllers[file.name] = TextEditingController(
                            text: file.name.split('.').first,
                          );
                        }
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          for (final controller in controllersToDispose) {
                            controller.dispose();
                          }
                        });
                      });
                    },
                    icon: const Icon(Icons.attach_file_rounded),
                    label: const Text('Select Files'),
                  ),
                  if (selectedFiles.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...selectedFiles.map(
                      (file) {
                        final controller = fileTitleControllers[file.name];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppPalette.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  labelText: 'Document Title',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  if (validationError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      validationError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (selectedFiles.isEmpty) {
                    setDialogState(
                      () => validationError = 'Select at least one document.',
                    );
                    return;
                  }
                  for (final file in selectedFiles) {
                    final title = fileTitleControllers[file.name]?.text.trim() ?? '';
                    if (title.isEmpty) {
                      setDialogState(() => validationError = 'Title cannot be empty.');
                      return;
                    }
                  }
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Upload'),
              ),
            ],
          ),
        ),
      );

      if (shouldUpload != true) return;

      debugPrint('Uploading ${selectedFiles.length} document(s) for booking ${item.id} (${item.status})');
      await Future.wait(
        selectedFiles.map(
          (file) {
            final title = fileTitleControllers[file.name]?.text.trim() ?? file.name;
            return _bookingService.uploadBookingDocument(
              bookingId: item.id,
              fileName: file.name,
              title: title.isNotEmpty ? title : file.name,
              filePath: file.path,
              fileBytes: file.bytes,
            );
          },
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documents uploaded successfully.')),
      );
      await _fetchBookings();
    } catch (error, stackTrace) {
      debugPrint('Upload documents failed for booking ${item.id} (${item.status}): $error');
      debugPrint(stackTrace.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload documents. Please try again.'),
        ),
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (var controller in fileTitleControllers.values) {
          controller.dispose();
        }
      });
    }
  }

  Future<void> _showReminderDialog(BookingItem item) async {
    final medicalController = TextEditingController(
      text: _initialReminderDateText(item.medicalExpiryDate),
    );
    final policeController = TextEditingController(
      text: _initialReminderDateText(item.policeClearanceExpiryDate),
    );
    String? validationError;

    final reminder = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ReminderDateField(
                controller: medicalController,
                label: 'Medical Expiry Date',
                onPickDate: () async {
                  final picked = await _pickReminderDate(dialogContext);
                  if (picked == null) return;
                  setDialogState(() {
                    medicalController.text = _formatApiDate(picked);
                    validationError = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              _ReminderDateField(
                controller: policeController,
                label: 'Police Clearance Expiry Date',
                onPickDate: () async {
                  final picked = await _pickReminderDate(dialogContext);
                  if (picked == null) return;
                  setDialogState(() {
                    policeController.text = _formatApiDate(picked);
                    validationError = null;
                  });
                },
              ),
              if (validationError != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    validationError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final medicalDate = medicalController.text.trim();
                final policeDate = policeController.text.trim();
                if (medicalDate.isEmpty && policeDate.isEmpty) {
                  setDialogState(
                    () => validationError = 'Add at least one expiry date.',
                  );
                  return;
                }
                Navigator.pop(dialogContext, {
                  if (medicalDate.isNotEmpty)
                    'medical_expiry_date': medicalDate,
                  if (policeDate.isNotEmpty)
                    'police_clearance_expiry_date': policeDate,
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      medicalController.dispose();
      policeController.dispose();
    });

    if (reminder == null) return;

    try {
      await _bookingService.updateBookingReminders(
        bookingId: item.id,
        medicalExpiryDate: reminder['medical_expiry_date'],
        policeClearanceExpiryDate: reminder['police_clearance_expiry_date'],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder updated successfully.')),
      );
      await _fetchBookings();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update reminder.')),
      );
    }
  }

  Future<void> _showVisaReminderDialog(BookingItem item) async {
    final visaController = TextEditingController(
      text: _initialReminderDateText(item.visaExpiryDate),
    );
    String? validationError;

    final visaDate = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Visa Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ReminderDateField(
                controller: visaController,
                label: 'Visa Expiry Date',
                onPickDate: () async {
                  final picked = await _pickReminderDate(dialogContext);
                  if (picked == null) return;
                  setDialogState(() {
                    visaController.text = _formatApiDate(picked);
                    validationError = null;
                  });
                },
              ),
              if (validationError != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    validationError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = visaController.text.trim();
                if (value.isEmpty) {
                  setDialogState(
                    () => validationError = 'Add a visa expiry date.',
                  );
                  return;
                }
                Navigator.pop(dialogContext, value);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      visaController.dispose();
    });

    if (visaDate == null) return;

    try {
      await _bookingService.updateBookingReminders(
        bookingId: item.id,
        visaExpiryDate: visaDate,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visa reminder updated successfully.')),
      );
      await _fetchBookings();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update visa reminder.')),
      );
    }
  }

  Future<DateTime?> _pickReminderDate(BuildContext dialogContext) {
    final now = DateTime.now();
    return showDatePicker(
      context: dialogContext,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
  }

  String _initialReminderDateText(String? value) {
    if (value == null || value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    return parsed == null ? value : _formatApiDate(parsed);
  }

  BookingItem _mapDtoToBookingItem(ReceiveBookingItemDto item) {
    return BookingItem(
      workPermitId: item.workPermitId.isEmpty ? '-' : item.workPermitId,
      id: item.id,
      serviceType: item.serviceType,
      createdAt: item.createdAt,
      name: item.name,
      passportNo: item.passportNo ?? '-',
      fromCountry: item.fromCountry,
      toCountry: item.toCountry,
      agencyTotalCost: item.agencyTotalCost ?? 0,
      paidAmount: item.paidAmount ?? 0,
      status: item.status,
      statusLabel: item.statusLabel,
      appointmentDate: item.appointmentDate,
      medicalExpiryDate: item.medicalExpiryDate,
      policeClearanceExpiryDate: item.policeClearanceExpiryDate,
      visaExpiryDate: item.visaExpiryDate,
      hasAdvancePayout: item.hasAdvancePayout,
      hasAfterVisaPayout: item.hasAfterVisaPayout,
      hasBeforeFlightPayout: item.hasBeforeFlightPayout,
      paymentStepCount: item.paymentStepCount ?? 0,
      isReturn: item.isReturn,
    );
  }

  String _formatApiDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageScaffold(
      currentHref: widget.currentHref,
      child: Container(
        color: AppPalette.pageBackground,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _breadcrumb(),
                    const SizedBox(height: 14),
                    AppSearchBar(
                      controller: _searchController,
                      hintText:
                          'Search by booking ID, name, passport or status',
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      onSearchTap: () {
                        setState(() => _searchQuery = _searchController.text);
                        _fetchBookings();
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _viewToggle(),
                        const SizedBox(width: 10),
                        Expanded(child: _dateRangeButton()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _statusDropdown(),
                    const SizedBox(height: 16),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else
                      Skeletonizer(
                        enabled: _isLoading,
                        child: _isCardView
                            ? _buildCardList()
                            : _buildTableList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusDropdown() {
    final selectedStatus =
        _bookingStatusFilterOptions.any(
          (option) => option.value == _selectedStatus,
        )
        ? _selectedStatus
        : '';

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E3FA)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppPalette.textStrongBlue,
          ),
          selectedItemBuilder: (context) => _bookingStatusFilterOptions
              .map(
                (option) => Row(
                  children: [
                    const Icon(
                      Icons.filter_list_rounded,
                      size: 18,
                      color: AppPalette.textStrongBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option.label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppPalette.textStrongBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
          items: _bookingStatusFilterOptions
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option.value,
                  child: Text(option.label),
                ),
              )
              .toList(),
          onChanged: (status) {
            if (status == null || status == _selectedStatus) return;
            setState(() => _selectedStatus = status);
            _fetchBookings();
          },
        ),
      ),
    );
  }

  Widget _breadcrumb() {
    return BreadCrumb(
      items: <BreadCrumbItem>[
        BreadCrumbItem(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.view_list_rounded,
                size: 14,
                color: AppPalette.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                'Receive Booking List',
                style: TextStyle(color: AppPalette.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        BreadCrumbItem(
          content: Text(
            _selectedStatusLabel,
            style: TextStyle(
              color: AppPalette.textStrongBlue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
      divider: const Icon(
        Icons.chevron_right_rounded,
        size: 16,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  Widget _viewToggle() {
    return ViewToggleButton(
      isCardView: _isCardView,
      onChanged: (isCardView) => setState(() => _isCardView = isCardView),
    );
  }

  Widget _dateRangeButton() {
    final label = _selectedDateRange == null
        ? 'Select Date Range'
        : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}';
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E3FA)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(now.year + 3, 12, 31),
                initialDateRange: _selectedDateRange,
              );
              if (picked == null) return;
              setState(() => _selectedDateRange = picked);
              _fetchBookings();
            },
            child: Row(
              children: [
                const Icon(
                  Icons.date_range_rounded,
                  size: 18,
                  color: AppPalette.textStrongBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppPalette.textStrongBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (_selectedDateRange != null)
            InkWell(
              onTap: () {
                setState(() => _selectedDateRange = null);
                _fetchBookings();
              },
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppPalette.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableList() => StyledDataTableCard(
    dataRowMaxHeight: 86,
    columnSpacing: 20,
    columns: _tableColumns(),
    rows: _visibleBookings.map((item) {
      final style = _styleFor(item.statusLabel);
      return DataRow(
        onLongPress: () => _openActionsSheet(
          context,
          item,
          onActionSelected: _handleBookingAction,
        ),
        cells: [
          DataCell(Text(item.workPermitId)),
          DataCell(Text(item.id.toString())),
          DataCell(Text(_displayDate(item.createdAt))),
          DataCell(
            Text(
              '${item.name}\n${item.passportNo}',
              style: const TextStyle(height: 1.35),
            ),
          ),
          DataCell(Text('${item.fromCountry} → ${item.toCountry}')),
          DataCell(Text('৳ ${_money(item.agencyTotalCost)}')),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: style.badgeBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.statusLabel,
                style: TextStyle(
                  color: style.badgeText,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          if (_selectedStatus == 'UNDER_PROCESSING')
            DataCell(
              Text(
                item.medicalExpiryDate == null
                    ? '-'
                    : _displayDate(item.medicalExpiryDate!),
              ),
            ),
          if (_selectedStatus == 'UNDER_PROCESSING')
            DataCell(
              Text(
                item.policeClearanceExpiryDate == null
                    ? '-'
                    : _displayDate(item.policeClearanceExpiryDate!),
              ),
            ),
          if (_selectedStatus == 'VISA_APPROVED')
            DataCell(
              Text(
                item.visaExpiryDate == null
                    ? '-'
                    : _displayDate(item.visaExpiryDate!),
              ),
            ),
          DataCell(
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: IconButton(
                onPressed: () => _openActionsSheet(
                  context,
                  item,
                  onActionSelected: _handleBookingAction,
                ),
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppPalette.textMuted,
                  size: 18,
                ),
                padding: const EdgeInsets.all(2),
                constraints: const BoxConstraints(),
                tooltip: 'Actions',
              ),
            ),
          ),
        ],
      );
    }).toList(),
  );

  List<DataColumn> _tableColumns() {
    const baseColumns = <DataColumn>[
      DataColumn(label: Text('Post ID')),
      DataColumn(label: Text('Booking ID')),
      DataColumn(label: Text('Apply Date')),
      DataColumn(label: Text('Customer Info')),
      DataColumn(label: Text('From & To')),
      DataColumn(label: Text('Total Cost')),
      DataColumn(label: Text('Status')),
    ];
    if (_selectedStatus == 'UNDER_PROCESSING') {
      return const [
        ...baseColumns,
        DataColumn(label: Text('Medical Expiry Date')),
        DataColumn(label: Text('Police Clearance Expiry Date')),
        DataColumn(label: Text('Actions')),
      ];
    }
    if (_selectedStatus == 'VISA_APPROVED') {
      return const [
        ...baseColumns,
        DataColumn(label: Text('Visa Expiry Date')),
        DataColumn(label: Text('Actions')),
      ];
    }
    return const [...baseColumns, DataColumn(label: Text('Actions'))];
  }

  Widget _buildCardList() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ..._visibleBookings.map((item) {
        return ReceivedBookingCard(
          bookingId: item.id,
          postId: item.workPermitId,
          statusText: item.status,
          name: item.name,
          passportNo: item.passportNo,
          createdAtText: _displayDate(item.createdAt),
          fromCountry: item.fromCountry,
          toCountry: item.toCountry,
          medicalText: item.medicalExpiryDate == null
              ? '-'
              : _displayDate(item.medicalExpiryDate!),
          visaText: item.visaExpiryDate == null
              ? '-'
              : _displayDate(item.visaExpiryDate!),
          policeClearText: item.policeClearanceExpiryDate == null
              ? '-'
              : _displayDate(item.policeClearanceExpiryDate!),
          totalCostText: '৳ ${_money(item.agencyTotalCost)}',
          hasAdvancePayout: item.hasAdvancePayout,
          hasAfterVisaPayout: item.hasAfterVisaPayout,
          hasBeforeFlightPayout: item.hasBeforeFlightPayout,
          showMedical: _selectedStatus == 'UNDER_PROCESSING',
          showPoliceClear: _selectedStatus == 'UNDER_PROCESSING',
          showVisa: _selectedStatus == 'VISA_APPROVED',
          style: _styleFor(item.statusLabel),
          onMoreTap: () => _openActionsSheet(
            context,
            item,
            onActionSelected: _handleBookingAction,
          ),
        );
      }),
    ],
  );

  String _displayDate(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    final date = parsed.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  String _money(int amount) {
    final s = amount.toString();
    final chars = s.split('').reversed.toList();
    final chunks = <String>[];
    for (var i = 0; i < chars.length; i += 3) {
      chunks.add(chars.skip(i).take(3).join());
    }
    return chunks
        .map((c) => c.split('').reversed.join())
        .toList()
        .reversed
        .join(',');
  }

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  ReceivedBookingCardStyle _styleFor(String status) {
    switch (status) {
      case 'Success Flight':
        return const ReceivedBookingCardStyle(
          badgeBg: AppPalette.successBg,
          badgeText: AppPalette.success,
          ctaLabel: 'View Receipt',
        );
      case 'Under Processing':
        return const ReceivedBookingCardStyle(
          badgeBg: AppPalette.warningBg,
          badgeText: AppPalette.warning,
          ctaLabel: 'View Details',
        );
      default:
        return const ReceivedBookingCardStyle(
          badgeBg: Color(0xFFDBEAFE),
          badgeText: Color(0xFF1D4ED8),
          ctaLabel: 'View Details',
        );
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.error = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.borderSoftBlue),
        boxShadow: AppPalette.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: AppPalette.brandBlue),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppPalette.textMuted,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              color: error ? AppPalette.danger : AppPalette.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRequestInput {
  const _PaymentRequestInput({this.requestAmount});

  final num? requestAmount;
}

class _ReminderDateField extends StatelessWidget {
  const _ReminderDateField({
    required this.controller,
    required this.label,
    required this.onPickDate,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'YYYY-MM-DD',
        suffixIcon: IconButton(
          onPressed: onPickDate,
          icon: const Icon(Icons.calendar_today_rounded),
        ),
      ),
      onTap: onPickDate,
    );
  }
}

class BookingItem {
  const BookingItem({
    required this.workPermitId,
    required this.id,
    required this.serviceType,
    required this.createdAt,
    required this.name,
    required this.passportNo,
    required this.fromCountry,
    required this.toCountry,
    required this.agencyTotalCost,
    required this.paidAmount,
    required this.status,
    required this.statusLabel,
    this.medicalExpiryDate,
    this.policeClearanceExpiryDate,
    this.visaExpiryDate,
    this.appointmentDate,
    this.isReturn = false,
    this.paymentStepCount = 0,
    this.hasAdvancePayout = false,
    this.hasAfterVisaPayout = false,
    this.hasBeforeFlightPayout = false,
  });

  final String workPermitId;
  final int id;
  final String serviceType;
  final String createdAt;
  final String name;
  final String passportNo;
  final String fromCountry;
  final String toCountry;
  final int agencyTotalCost;
  final int paidAmount;
  final String status;
  final String statusLabel;
  final String? medicalExpiryDate;
  final String? policeClearanceExpiryDate;
  final String? visaExpiryDate;
  final String? appointmentDate;
  final bool isReturn;
  final int paymentStepCount;
  final bool hasAdvancePayout;
  final bool hasAfterVisaPayout;
  final bool hasBeforeFlightPayout;
}

List<String> _actionsFor(BookingItem row) {
  if (row.isReturn) return const ['File in Return'];
  final actions =
      <String, List<String>>{
        'APPLIED_FILE': ['View Post', 'Reject'],
        'BG_COLLECT_PP': [],
        'BG_SENT_PP': ['Receive Passport'],
        'A_RECEIVE_PP': [
          'Sent to Processing',
          'Payment Request',
          'Add Reminder',
          'View Documents',
          'Reject',
        ],
        'UNDER_PROCESSING': [
          'Visa Approved',
          'Upload Documents',
          'Add Reminder',
          'Visa Reminder',
          'View Documents',
          'Reject',
        ],
        'VISA_APPROVED': [
          'BMET Done',
          'Upload Documents',
          'Payment Request',
          'View Documents',
          'Reject',
        ],
        'BMET_DONE': [
          'Ticket Done',
          'Upload Documents',
          'View Documents',
          'Reject',
        ],
        'TICKET_DONE': [
          'Payment Request',
          'PP Send to BG',
          'Upload Documents',
          'View Documents',
          'Reject',
        ],
        'PP_SENT_TO_BG': ['View Documents'],
        'BG_RECEIVED_PP': ['View Documents'],
        'READY_FOR_FLIGHT': ['View Documents'],
        'SUCCESS_FLIGHT': ['View Documents'],
        'RETURN_PP_SENT_TO_BG': ['View Documents'],
        'BG_COLLECT_RETURN_PP': ['View Documents'],
        'BG_HANDOVER_PP_TO_CUSTOMER': ['View Documents'],
        'REJECT_FILE': [],
      }[row.status] ??
      <String>[];
  return actions.where((action) {
    if (action == 'Sent to Processing' && row.status == 'A_RECEIVE_PP') {
      if (row.paymentStepCount == 3 && !row.hasAdvancePayout) return false;
    }
    if (action == 'Payment Request') {
      if (row.status == 'A_RECEIVE_PP' &&
          (row.paymentStepCount != 3 || row.hasAdvancePayout))
        return false;
      if (row.status == 'VISA_APPROVED' && row.hasAfterVisaPayout)
        return false;
      if (row.status == 'TICKET_DONE' && row.hasBeforeFlightPayout)
        return false;
    }
    if (action == 'PP Send to BG' &&
        row.status == 'TICKET_DONE' &&
        !row.hasBeforeFlightPayout)
      return false;
    return true;
  }).toList();
}

void _openActionsSheet(
  BuildContext context,
  BookingItem row, {
  Future<void> Function(BookingItem row, String action)? onActionSelected,
}) {
  final actions = _actionsFor(row);
  showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions • ${row.statusLabel}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (actions.isEmpty)
              const Text('No actions available')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions
                    .map(
                      (action) => OutlinedButton(
                        onPressed: row.isReturn
                            ? null
                            : () async {
                                Navigator.pop(context);
                                await onActionSelected?.call(row, action);
                              },
                        child: Text(action),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    ),
  );
}
