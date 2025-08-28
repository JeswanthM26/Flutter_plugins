import 'package:flutter/material.dart';
import '../models/plugin_metadata.dart';

class ResultScreen extends StatelessWidget {
  final PluginMetadata plugin;
  final dynamic result;
  final Duration? executionTime;

  const ResultScreen({
    Key? key,
    required this.plugin,
    required this.result,
    this.executionTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${plugin.name.replaceAll('_', ' ').toUpperCase()} Result'),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FA), Color(0xFFC3CFE2)],
          ),
        ),
        child: Column(
          children: [
            // Header with execution info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _getPluginIcon(plugin.name),
                    size: 48,
                    color: _getPluginColor(plugin.name),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Execution Complete',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  if (executionTime != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer, color: Colors.green[600], size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Execution Time: ${executionTime!.inMilliseconds}ms',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Result content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildResultContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContent(BuildContext context) {
    Widget content;

    if (result == null) {
      content = _buildErrorContent('No result or operation was cancelled.');
    } else if (result is Map && result.containsKey('error')) {
      content = _buildErrorContent(result['error']);
    } else {
      content = _buildSuccessContent(context);
    }

    return content;
  }

  Widget _buildErrorContent(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red[400],
        ),
        const SizedBox(height: 16),
        const Text(
          'Operation Failed',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(BuildContext context) {
    Widget content;

    switch (plugin.name) {
      case 'camera':
      case 'photopicker':
        if (result is Map && result['imagePath'] != null) {
          content = Column(
            children: [
              if (result['imageFile'] != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      result['imageFile'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (result['base64'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Base64 Data:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        '${result['base64']!.substring(0, 100)}...',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        } else {
          content = const Text('No image captured');
        }
        break;

      case 'contact':
        if (result is List) {
          content = Expanded(
            child: ListView.builder(
              itemCount: result.length,
              itemBuilder: (context, index) {
                final contact = result[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        (contact['name'] ?? '?')[0].toUpperCase(),
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ),
                    title: Text(contact['name'] ?? 'Unknown'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (contact['numbers'] != null)
                          Text('Phone: ${contact['numbers'].join(', ')}'),
                        if (contact['emails'] != null)
                          Text('Email: ${contact['emails'].join(', ')}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          content = const Text('No contacts found');
        }
        break;

      case 'contact_picker':
        if (result is Map) {
          content = Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Text(
                  (result['fullName'] ?? '?')[0].toUpperCase(),
                  style: TextStyle(color: Colors.green[700]),
                ),
              ),
              title: Text(result['fullName'] ?? 'Unknown'),
              subtitle: Text('Phone: ${result['phoneNumber'] ?? 'N/A'}'),
            ),
          );
        } else {
          content = const Text('No contact selected');
        }
        break;

      case 'date_picker':
        if (result is List) {
          content = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              children: [
                const Icon(Icons.calendar_today, color: Colors.orange, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Selected date(s): ${result.join(', ')}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        } else {
          content = const Text('No date selected');
        }
        break;

      case 'device_info':
        if (result is Map) {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Device Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...result.entries.map<Widget>((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${e.key}:',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: Text(e.value.toString()),
                    ),
                  ],
                ),
              )).toList(),
            ],
          );
        } else {
          content = const Text('Device info not available');
        }
        break;

      case 'gps':
        if (result is Map) {
          if (result.containsKey('error')) {
            content = _buildErrorContent(result['error']);
          } else {
            content = Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Location Data',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Latitude', result['latitude']?.toString() ?? 'N/A'),
                  _buildInfoRow('Longitude', result['longitude']?.toString() ?? 'N/A'),
                  _buildInfoRow('Accuracy', result['accuracy']?.toString() ?? 'N/A'),
                  _buildInfoRow('Altitude', result['altitude']?.toString() ?? 'N/A'),
                  _buildInfoRow('Speed', result['speed']?.toString() ?? 'N/A'),
                  _buildInfoRow('Timestamp', result['timestamp']?.toString() ?? 'N/A'),
                ],
              ),
            );
          }
        } else {
          content = const Text('Location data not available');
        }
        break;

      case 'in_app_review':
        content = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.star, color: Colors.amber[600]),
              const SizedBox(width: 12),
              const Text(
                'In-app review dialog requested successfully.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
        break;

      case 'inapp_update':
        if (result is Map) {
          content = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.system_update, color: Colors.teal[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Update Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...result.entries.map<Widget>((e) => _buildInfoRow(e.key, e.value.toString())).toList(),
              ],
            ),
          );
        } else {
          content = const Text('Update info not available');
        }
        break;

      case 'network_state':
      case 'network_state_perm':
        if (result is Map) {
          content = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.wifi, color: Colors.indigo[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Network Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...result.entries.map<Widget>((e) => _buildInfoRow(e.key, e.value.toString())).toList(),
              ],
            ),
          );
        } else {
          content = const Text('Network info not available');
        }
        break;

      case 'notification':
        content = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.pink[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.pink[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.notifications, color: Colors.pink[600]),
              const SizedBox(width: 12),
              const Text(
                'Notification triggered successfully.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
        break;

      case 'qr':
        if (result is Map && result['qrBytes'] != null) {
          content = Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Image.memory(result['qrBytes']),
              ),
              const SizedBox(height: 16),
              const Text(
                'QR Code Generated Successfully',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          );
        } else {
          content = const Text('QR code generated.');
        }
        break;

      case 'screenshot':
        content = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.screenshot, color: Colors.grey[600]),
              const SizedBox(width: 12),
              const Text(
                'Screenshot captured and saved successfully.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
        break;

      case 'send_sms':
        if (result is Map) {
          content = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.lightGreen[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.lightGreen[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.sms, color: Colors.lightGreen[600]),
                const SizedBox(width: 12),
                Text(
                  'SMS Status: ${result['status']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        } else {
          content = const Text('SMS status not available');
        }
        break;

      case 'app_switch':
        if (result is Map) {
          content = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_horiz, color: Colors.deepPurple[600]),
                const SizedBox(width: 12),
                Text(
                  'App State: ${result['state']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        } else {
          content = const Text('App state not available');
        }
        break;

      case 'biometric':
        if (result is Map) {
          final isSuccess = result['status'] == true;
          content = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSuccess ? Colors.green[200]! : Colors.red[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      isSuccess ? Icons.fingerprint : Icons.error,
                      color: isSuccess ? Colors.green[600] : Colors.red[600],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Authentication ${isSuccess ? 'Success' : 'Failed'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  result['message'] ?? 'No message',
                  style: TextStyle(
                    color: isSuccess ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ],
            ),
          );
        } else {
          content = const Text('Biometric result not available');
        }
        break;

      case 'deeplink':
        if (result is Map) {
          content = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.lightBlue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.link, color: Colors.lightBlue[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Deep Link Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (result.containsKey('initialLink'))
                  _buildInfoRow('Initial Link', result['initialLink'] ?? "null"),
                if (result.containsKey('streamListening'))
                  const Text('Listening for live deep links via stream...'),
              ],
            ),
          );
        } else {
          content = const Text('Deep link info not available');
        }
        break;

      case 'device_fingerprint':
        if (result is Map) {
          content = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.purple[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Device Fingerprint',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: SelectableText(
                    result['fingerprint'] ?? 'Unavailable',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        } else {
          content = const Text('Device fingerprint not available');
        }
        break;

      case 'digi_scan_image':
        if (result is Map && result['scannedImages'] != null) {
          final List images = result['scannedImages'];
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.document_scanner, color: Colors.blueGrey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Scanned Images (${images.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...images.map<Widget>((img) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.image, color: Colors.blueGrey[600]),
                  title: Text("Image URI: ${img['imageUri']}"),
                  subtitle: Text("Size: ${img['bytes']} bytes"),
                ),
              )).toList(),
            ],
          );
        } else {
          content = const Text('No scanned images available');
        }
        break;

      case 'digi_scan_pdf':
        if (result is Map) {
          content = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueGrey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.blueGrey[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Scanned PDF',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: SelectableText(
                    result['pdfUri'] ?? 'No file returned',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        } else {
          content = const Text('PDF scan result not available');
        }
        break;

      case 'file_operations':
        if (result is Map && result['files'] != null) {
          final files = result['files'] as List<dynamic>;
          if (files.isEmpty) {
            content = const Text('No files selected or operation canceled.');
          } else {
            content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.folder_open, color: Colors.lime[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Picked Files (${files.length})',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...files.map<Widget>((f) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(Icons.insert_drive_file, color: Colors.lime[600]),
                    title: Text(f['name'] ?? 'Unknown'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Size: ${f['size']} bytes'),
                        Text('MIME: ${f['mimeType']}'),
                        Text('Path: ${f['path']}'),
                      ],
                    ),
                  ),
                )).toList(),
              ],
            );
          }
        } else {
          content = const Text('File operation result not available');
        }
        break;

      case 'apz_peripherals':
      case 'apz_screen_security':
      case 'apz_share':
      case 'apz_webview':
        if (result is Map) {
          content = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Operation Result',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...result.entries.map<Widget>((e) => _buildInfoRow(e.key, e.value.toString())).toList(),
              ],
            ),
          );
        } else {
          content = const Text('Operation result not available');
        }
        break;

      case 'apz_idle_timeout':
        content = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.timer, color: Colors.orange[600]),
              const SizedBox(width: 12),
              Text(
                result['status'] ?? 'Timeout behavior initialized.',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
        break;

      default:
        content = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Result',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SelectableText(
                result.toString(),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
    }

    return content;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }

  IconData _getPluginIcon(String pluginName) {
    switch (pluginName.toLowerCase()) {
      case 'camera':
        return Icons.camera_alt;
      case 'contact':
      case 'contact_picker':
        return Icons.contacts;
      case 'date_picker':
      case 'custom_datepicker':
        return Icons.calendar_today;
      case 'device_info':
        return Icons.device_hub;
      case 'gps':
        return Icons.location_on;
      case 'in_app_review':
        return Icons.star_rate;
      case 'inapp_update':
        return Icons.system_update;
      case 'network_state':
      case 'network_state_perm':
        return Icons.wifi;
      case 'notification':
        return Icons.notifications;
      case 'pdf_viewer':
        return Icons.picture_as_pdf;
      case 'photopicker':
        return Icons.photo_library;
      case 'qr':
        return Icons.qr_code;
      case 'screenshot':
        return Icons.screenshot;
      case 'send_sms':
        return Icons.sms;
      case 'app_switch':
        return Icons.swap_horiz;
      case 'biometric':
        return Icons.fingerprint;
      case 'deeplink':
        return Icons.link;
      case 'device_fingerprint':
        return Icons.security;
      case 'digi_scan_image':
      case 'digi_scan_pdf':
        return Icons.document_scanner;
      case 'file_operations':
        return Icons.folder_open;
      case 'apz_peripherals':
        return Icons.devices;
      case 'apz_screen_security':
        return Icons.screen_lock_portrait;
      case 'apz_share':
        return Icons.share;
      case 'apz_webview':
        return Icons.web;
      case 'apz_idle_timeout':
        return Icons.timer;
      default:
        return Icons.extension;
    }
  }

  Color _getPluginColor(String pluginName) {
    switch (pluginName.toLowerCase()) {
      case 'camera':
      case 'photopicker':
        return Colors.blue;
      case 'contact':
      case 'contact_picker':
        return Colors.green;
      case 'date_picker':
      case 'custom_datepicker':
        return Colors.orange;
      case 'device_info':
      case 'device_fingerprint':
        return Colors.purple;
      case 'gps':
        return Colors.red;
      case 'in_app_review':
        return Colors.amber;
      case 'inapp_update':
        return Colors.teal;
      case 'network_state':
      case 'network_state_perm':
        return Colors.indigo;
      case 'notification':
        return Colors.pink;
      case 'pdf_viewer':
        return Colors.brown;
      case 'qr':
        return Colors.cyan;
      case 'screenshot':
        return Colors.grey;
      case 'send_sms':
        return Colors.lightGreen;
      case 'app_switch':
        return Colors.deepPurple;
      case 'biometric':
        return Colors.deepOrange;
      case 'deeplink':
        return Colors.lightBlue;
      case 'digi_scan_image':
      case 'digi_scan_pdf':
        return Colors.blueGrey;
      case 'file_operations':
        return Colors.lime;
      case 'apz_peripherals':
        return Colors.indigo;
      case 'apz_screen_security':
        return Colors.red;
      case 'apz_share':
        return Colors.green;
      case 'apz_webview':
        return Colors.blue;
      case 'apz_idle_timeout':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}