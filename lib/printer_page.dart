import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

class PrintPage extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  const PrintPage({super.key, required this.data});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  List<BluetoothInfo> _devices = [];
  String _devicesMsg = "Vérification des permissions...";
  final f = NumberFormat("#,##0.00' EUR'", "fr_FR");
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInit();
  }

  Future<void> _checkPermissionsAndInit() async {
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }

    bool connectGranted = await Permission.bluetoothConnect.isGranted;
    bool scanGranted = await Permission.bluetoothScan.isGranted;

    if (!connectGranted || !scanGranted) {
      setState(() {
        _devicesMsg = "Permissions Bluetooth refusées. Veuillez les activer.";
        _isScanning = false;
      });
      _showPermissionDialog();
      return;
    }

    await initPrinter();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Permissions requises'),
        content: const Text(
          'Cette application a besoin des permissions Bluetooth pour se connecter à l\'imprimante.\n\n'
          'Veuillez activer les permissions "Appareils à proximité" dans les paramètres.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Ouvrir Paramètres'),
          ),
        ],
      ),
    );
  }

  Future<void> initPrinter() async {
    setState(() {
      _isScanning = true;
      _devicesMsg = "Vérification du Bluetooth...";
    });

    final bool bluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;

    if (!bluetoothEnabled) {
      setState(() {
        _devicesMsg = "Le Bluetooth est désactivé. Veuillez l'activer.";
        _isScanning = false;
      });
      return;
    }

    setState(() {
      _devicesMsg = "Recherche d'imprimantes en cours...";
    });

    final List<BluetoothInfo> devices =
        await PrintBluetoothThermal.pairedBluetooths;

    if (!mounted) return;

    setState(() {
      _devices = devices;
      _isScanning = false;
      if (_devices.isEmpty) {
        _devicesMsg =
            "Aucune imprimante trouvée.\n\nVeuillez appairer votre imprimante dans les paramètres Bluetooth d'abord.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Sélectionner Imprimante'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _devices.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: _isScanning
                          ? const CircularProgressIndicator(
                              color: Colors.blueAccent,
                            )
                          : const Icon(
                              Icons.bluetooth_searching,
                              size: 64,
                              color: Colors.blueAccent,
                            ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      _devicesMsg,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (!_isScanning) ...[
                      ElevatedButton.icon(
                        onPressed: _checkPermissionsAndInit,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Actualiser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _handleSettingsRouting,
                        child: const Text(
                          'Ouvrir les Paramètres',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _devices.length,
              itemBuilder: (c, i) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.print, color: Colors.green),
                    ),
                    title: Text(
                      _devices[i].name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(_devices[i].macAdress),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      _startPrint(_devices[i]);
                    },
                  ),
                );
              },
            ),
    );
  }

  Future<void> _handleSettingsRouting() async {
    bool connectGranted = await Permission.bluetoothConnect.isGranted;
    bool scanGranted = await Permission.bluetoothScan.isGranted;

    if (!connectGranted || !scanGranted) {
      // Les permissions manquent, on va dans les paramètres de l'application
      openAppSettings();
    } else {
      // Les permissions sont là, c'est l'antenne Bluetooth qui est éteinte
      AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
    }
  }

  Future<void> _startPrint(BluetoothInfo device) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Row(
            children: [
              const CircularProgressIndicator(color: Colors.blueAccent),
              const SizedBox(width: 20),
              const Expanded(
                child: Text(
                  "Connexion à l'imprimante...",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );

      final bool connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.macAdress,
      );

      if (!mounted) return;

      if (!connected) {
        Navigator.pop(context);
        _showMessage("Échec de la connexion à l'imprimante");
        return;
      }

      List<int> ticket = await _generateTicket();
      final bool result = await PrintBluetoothThermal.writeBytes(ticket);
      await PrintBluetoothThermal.disconnect;

      if (!mounted) return;

      Navigator.pop(context);

      if (result) {
        _showMessage("Impression réussie ! ✓", isSuccess: true);
        Navigator.pop(context);
      } else {
        _showMessage("Échec de l'impression");
      }
    } catch (e, stackTrace) {
      print('=== ERREUR IMPRESSION ===');
      print(e);
      print(stackTrace);
      if (!mounted) return;
      Navigator.pop(context);
      _showMessage("Erreur: $e");
    }
  }

  Future<List<int>> _generateTicket() async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    bytes += generator.reset();

    // En-tête Supermarché
    bytes += generator.text(
      'Amdy Market',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
      linesAfter: 1,
    );

    bytes += generator.text(
      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );

    bytes += generator.text(
      '123 Avenue du Commerce, Dakar',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.hr();

    // Articles
    num total = 0;
    for (var item in widget.data) {
      final price = item['price'] as num;
      final qty = item['qty'] as int;
      final subtotal = price * qty;
      total += subtotal;

      bytes += generator.text(
        item['title'],
        styles: const PosStyles(bold: true),
      );

      bytes += generator.row([
        PosColumn(
          text: '  ${f.format(price)} x $qty',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: f.format(subtotal),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // Total
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL TTC:',
        width: 6,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
      PosColumn(
        text: f.format(total),
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    ]);

    bytes += generator.hr();
    bytes += generator.text(
      'Merci de votre visite et a bientot !',
      styles: const PosStyles(align: PosAlign.center, bold: true),
      linesAfter: 2,
    );

    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess
            ? Colors.green.shade600
            : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
