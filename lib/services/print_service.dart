import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:intl/intl.dart';

class PrintService {
  final BluetoothPrint _bluetoothPrint = BluetoothPrint.instance;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<List<BluetoothDevice>> scanDevices() async {
    await _bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
    return await _bluetoothPrint.scanResults;
  }

  Future<bool> connect(BluetoothDevice device) async {
    _isConnected = await _bluetoothPrint.connect(device) ?? false;
    return _isConnected;
  }

  Future<void> disconnect() async {
    await _bluetoothPrint.disconnect();
    _isConnected = false;
  }

  Future<void> printReceipt({
    required String transactionId,
    required String customerName,
    required List<Map<String, dynamic>> items,
    required int totalAmount,
    required int totalPoints,
    required String paymentMethod,
    int cashReceived = 0,
  }) async {
    if (!_isConnected) {
      throw Exception('Printer tidak terhubung!');
    }

    List<LineText> list = [];
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'TOKO GIDEON',
      weight: 2,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Jl. Batam Center',
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '------------------------------',
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    list.add(LineText(
      content: 'No: $transactionId',
      linefeed: 1,
    ));
    list.add(LineText(
      content: 'Tgl: ' + DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      linefeed: 1,
    ));
    list.add(LineText(
      content: 'Customer: $customerName',
      linefeed: 1,
    ));
    list.add(LineText(
      content: '------------------------------',
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    for (var item in items) {
      list.add(LineText(
        content: item['product_name'] + ' (' + item['unit_type'] + ')',
        linefeed: 1,
      ));
      list.add(LineText(
        content: item['qty'].toString() + ' x ' + currencyFormat.format(item['unit_price']),
        align: LineText.ALIGN_LEFT,
        x: 0,
      ));
      list.add(LineText(
        content: currencyFormat.format(item['subtotal']),
        align: LineText.ALIGN_RIGHT,
        x: 350,
        linefeed: 1,
      ));
    }

    list.add(LineText(
      content: '------------------------------',
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    list.add(LineText(
      content: 'TOTAL',
      align: LineText.ALIGN_LEFT,
      x: 0,
      weight: 1,
    ));
    list.add(LineText(
      content: currencyFormat.format(totalAmount),
      align: LineText.ALIGN_RIGHT,
      x: 350,
      weight: 1,
      linefeed: 1,
    ));

    if (cashReceived > 0) {
      list.add(LineText(
        content: 'TUNAI',
        align: LineText.ALIGN_LEFT,
        x: 0,
      ));
      list.add(LineText(
        content: currencyFormat.format(cashReceived),
        align: LineText.ALIGN_RIGHT,
        x: 350,
        linefeed: 1,
      ));
      list.add(LineText(
        content: 'KEMBALI',
        align: LineText.ALIGN_LEFT,
        x: 0,
      ));
      list.add(LineText(
        content: currencyFormat.format(cashReceived - totalAmount),
        align: LineText.ALIGN_RIGHT,
        x: 350,
        linefeed: 1,
      ));
    }

    list.add(LineText(
      content: '------------------------------',
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    list.add(LineText(
      content: 'POIN DIDAPAT: +' + totalPoints.toString() + ' pts',
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    list.add(LineText(linefeed: 2));
    list.add(LineText(
      content: 'Terima Kasih!',
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));
    list.add(LineText(
      content: 'Selamat Berbelanja Kembali',
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    await _bluetoothPrint.printReceipt({}, list);
  }

  Future<void> printRedemptionReceipt({
    required String redemptionId,
    required String customerName,
    required String merchName,
    required int pointsUsed,
    required int remainingPoints,
  }) async {
    if (!_isConnected) {
      throw Exception('Printer tidak terhubung!');
    }

    List<LineText> list = [];

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'TOKO GIDEON',
      weight: 2,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));
    list.add(LineText(
      content: 'BUKTI PENUKARAN',
      align: LineText.ALIGN_CENTER,
      weight: 1,
      linefeed: 1,
    ));
    list.add(LineText(
      content: '------------------------------',
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    list.add(LineText(
      content: 'No: $redemptionId',
      linefeed: 1,
    ));
    list.add(LineText(
      content: 'Tgl: ' + DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      linefeed: 1,
    ));
    list.add(LineText(
      content: 'Member: $customerName',
      linefeed: 1,
    ));
    list.add(LineText(
      content: '------------------------------',
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    list.add(LineText(
      content: 'Item: $merchName',
      linefeed: 1,
    ));
    list.add(LineText(
      content: 'Poin Digunakan: ' + pointsUsed.toString() + ' pts',
      linefeed: 1,
    ));
    list.add(LineText(
      content: '------------------------------',
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));
    list.add(LineText(
      content: 'Sisa Poin: ' + remainingPoints.toString() + ' pts',
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    list.add(LineText(linefeed: 2));
    list.add(LineText(
      content: 'Terima Kasih!',
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    await _bluetoothPrint.printReceipt({}, list);
  }
}
