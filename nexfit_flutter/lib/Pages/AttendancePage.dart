// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:nexfit_flutter/Pages/Homepage.dart';

class AttendancePage extends StatefulWidget {
  final int? userID;
  final bool isTrainer;
  const AttendancePage({super.key, this.userID, required this.isTrainer});
  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = false;
  bool isProcessing = false; // Move isProcessing to class-level scope

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: isScanning
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        // Start/stop scanning
                        setState(() {
                          isScanning = !isScanning;
                          if (controller != null) {
                            if (isScanning) {
                              controller!.resumeCamera();
                            } else {
                              controller!.pauseCamera();
                            }
                          }
                        });
                      },
                      child:
                          Text(isScanning ? 'Stop Scanning' : 'Start Scanning'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isProcessing) {
        // Check if scanning is not already in progress
        isProcessing =
            true; // Set the flag to indicate that scanning is in progress
        // Handle scanned QR code data
        print(scanData.code);
        _handleQRCodeData(scanData.code!);
      }
    });
  }

  void _handleQRCodeData(String qrData) async {
    // Make API call to mark attendance and deduct tokens

    try {
      final response = widget.isTrainer
          ? await http.post(
              Uri.parse('http://192.168.1.13:8001/api/scan-qr-code-trainer/'),
              body: {
                'qr_code_data': 'valid_qr_code',
                'user_id': widget.userID.toString()
              },
            )
          : await http.post(
              Uri.parse('http://192.168.1.13:8001/api/scan-qr-code/'),
              body: {
                'qr_code_data': 'valid_qr_code',
                'user_id': widget.userID.toString()
              },
            );
      print('QR Data : $qrData');
      print('User ID : ${widget.userID}');
      print(response.body);
      if (response.statusCode == 200) {
        // Attendance marked successfully
        print('Attendance Marked.');

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Attendance Marked Successfully.')));
        // Handle success as per your app requirements
      }
      if (response.statusCode == 201) {
        print('Attendance Already Marked for Today.');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Attendance Already Marked for Today.')));
      }
    } catch (e) {
      // Error occurred during API call
      print('Error - $e');
      // Handle error as per your app requirements
    } finally {
      isProcessing = false;
    }
  }

  @override
  void dispose() {
    // controller?.pauseCamera(); // Pause the camera when the page is disposed
    controller?.dispose();
    super.dispose();
  }
}
