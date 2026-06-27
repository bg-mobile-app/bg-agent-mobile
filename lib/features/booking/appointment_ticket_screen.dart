import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AppointmentTicketScreen extends StatelessWidget {
  const AppointmentTicketScreen({
    super.key,
    required this.id,
    required this.name,
    required this.passportNo,
    required this.appointmentDate,
    required this.toCountry,
    required this.meetingType,
    this.qr,
  });

  final int id;
  final String name;
  final String passportNo;
  final String appointmentDate;
  final String toCountry;
  final String meetingType;
  final String? qr;

  ImageProvider? _qrImageProvider() {
    final value = qr?.trim();
    debugPrint('[QR DEBUG] Raw qr value: "$value"');
    if (value == null || value.isEmpty) {
      debugPrint('[QR DEBUG] qr value is null or empty. Generating QR server image provider fallback using booking ID: $id');
      // Generate QR Code using a public QR generation API containing the booking details
      final fallbackQrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=SL-BG-$id-$passportNo';
      return NetworkImage(fallbackQrUrl);
    }
    if (value.startsWith('data:image')) {
      final comma = value.indexOf(',');
      if (comma == -1) {
        debugPrint('[QR DEBUG] qr starts with data:image but lacks a comma separator. Falling back...');
        final fallbackQrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=SL-BG-$id-$passportNo';
        return NetworkImage(fallbackQrUrl);
      }
      try {
        final decodedBytes = base64Decode(value.substring(comma + 1));
        debugPrint('[QR DEBUG] Successfully decoded base64 memory image. Length: ${decodedBytes.length} bytes');
        return MemoryImage(decodedBytes);
      } catch (e) {
        debugPrint('[QR DEBUG] Failed to decode base64 memory image: $e. Falling back...');
        final fallbackQrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=SL-BG-$id-$passportNo';
        return NetworkImage(fallbackQrUrl);
      }
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      debugPrint('[QR DEBUG] Loading network image from absolute URL: "$value"');
      return NetworkImage(value);
    }
    debugPrint('[QR DEBUG] qr value does not match known prefix. Falling back...');
    final fallbackQrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=SL-BG-$id-$passportNo';
    return NetworkImage(fallbackQrUrl);
  }

  Future<Uint8List> _buildPdf() async {
    final doc = pw.Document();

    // Build QR image for PDF if available.
    pw.ImageProvider? pdfQrImage;
    var qrValue = qr?.trim();
    if (qrValue == null || qrValue.isEmpty) {
      qrValue = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=SL-BG-$id-$passportNo';
    }
    try {
      Uint8List? qrBytes;
      if (qrValue.startsWith('data:image')) {
        final comma = qrValue.indexOf(',');
        if (comma != -1) {
          qrBytes = base64Decode(qrValue.substring(comma + 1));
        } else {
          // fallback to qrserver
          final fallbackUri = Uri.parse('https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=SL-BG-$id-$passportNo');
          final req = await HttpClient().getUrl(fallbackUri);
          final resp = await req.close();
          qrBytes = await resp
              .fold<List<int>>([], (acc, chunk) => acc..addAll(chunk))
              .then((list) => Uint8List.fromList(list));
        }
      } else if (qrValue.startsWith('http://') || qrValue.startsWith('https://')) {
        final uri = Uri.parse(qrValue);
        final req = await HttpClient().getUrl(uri);
        final resp = await req.close();
        qrBytes = await resp
            .fold<List<int>>([], (acc, chunk) => acc..addAll(chunk))
            .then((list) => Uint8List.fromList(list));
      }
      if (qrBytes != null) {
        pdfQrImage = pw.MemoryImage(qrBytes);
      }
    } catch (_) {
      // Fallback request
      try {
        final uri = Uri.parse('https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=SL-BG-$id-$passportNo');
        final req = await HttpClient().getUrl(uri);
        final resp = await req.close();
        final qrBytes = await resp
            .fold<List<int>>([], (acc, chunk) => acc..addAll(chunk))
            .then((list) => Uint8List.fromList(list));
        pdfQrImage = pw.MemoryImage(qrBytes);
      } catch (e) {
        // QR image unavailable — continue without it.
      }
    }

    final detailsColumn = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          name.toUpperCase(),
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Passport Number: $passportNo',
          style: const pw.TextStyle(color: PdfColors.white, fontSize: 13),
        ),
        pw.Text(
          'Country: $toCountry',
          style: const pw.TextStyle(color: PdfColors.white, fontSize: 13),
        ),
        pw.Text(
          'Date & Time: $appointmentDate',
          style: const pw.TextStyle(color: PdfColors.white, fontSize: 13),
        ),
        pw.Text(
          'Service: Visa Consultancy',
          style: const pw.TextStyle(color: PdfColors.white, fontSize: 13),
        ),
        pw.Text(
          'Meeting: $meetingType',
          style: const pw.TextStyle(color: PdfColors.white, fontSize: 13),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Office Address: House No-27 (3rd Floor), Road No-10, Block-E, Banani, Dhaka-1213',
          style: const pw.TextStyle(color: PdfColors.white, fontSize: 11),
        ),
      ],
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (_) => pw.Container(
          padding: const pw.EdgeInsets.all(24),
          decoration: pw.BoxDecoration(
            gradient: const pw.LinearGradient(
              colors: [
                PdfColor.fromInt(0xFF1A56DB),
                PdfColor.fromInt(0xFF859BFF),
              ],
            ),
            borderRadius: pw.BorderRadius.circular(16),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SL-BG-$id',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Expanded(
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (pdfQrImage != null) ...[  
                      pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        child: pw.Image(pdfQrImage, width: 150, height: 150),
                      ),
                      pw.SizedBox(width: 20),
                    ],
                    pw.Expanded(child: detailsColumn),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/img/logo/logo_black.png', height: 32),
                  IconButton(
                    onPressed: () => Scaffold.maybeOf(context)?.openEndDrawer(),
                    icon: const Icon(Icons.menu, color: Colors.black87),
                    tooltip: 'Sidebar',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A56DB), Color(0xFF859BFF)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/img/logo/logo_white.png',
                            height: 28,
                          ),
                          Text(
                            'SL-BG-$id',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 700;
                            final qrImage = _qrImageProvider();
                            final qrWidget = Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white38),
                              ),
                              child: qrImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image(
                                        image: qrImage,
                                        width: 170,
                                        height: 170,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          debugPrint('[QR DEBUG] Image widget failed to load or render: $error\n$stackTrace');
                                          return Container(
                                            width: 170,
                                            height: 170,
                                            color: Colors.red.shade900,
                                            padding: const EdgeInsets.all(8),
                                            child: Center(
                                              child: Text(
                                                'Failed to render image:\n$error',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(color: Colors.white, fontSize: 10),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : const SizedBox(
                                      width: 170,
                                      height: 170,
                                      child: Center(
                                        child: Text(
                                          'QR preview unavailable',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                            );

                            final details = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _text('Passport Number: $passportNo'),
                                _text('Country: $toCountry'),
                                _text('Date & Time: $appointmentDate'),
                                _text('Service: Visa Consultancy'),
                                _text('Meeting: $meetingType'),
                                const SizedBox(height: 6),
                                _text(
                                  'Office Address: House No-27 (3rd Floor), Road No-10, Block-E, Banani, Dhaka-1213',
                                ),
                              ],
                            );

                            if (isMobile) {
                              return SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(child: qrWidget),
                                    const SizedBox(height: 16),
                                    details,
                                  ],
                                ),
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                qrWidget,
                                const SizedBox(width: 22),
                                Expanded(child: details),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final bytes = await _buildPdf();
                    await Printing.sharePdf(
                      bytes: bytes,
                      filename: 'ticket-$id.pdf',
                    );
                  },
                  child: const Text('Download Appointment Ticket (PDF)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _text(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      value,
      style: const TextStyle(color: Colors.white, fontSize: 14),
    ),
  );
}
