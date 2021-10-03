import 'package:example/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:hesabe/hesabe.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

enum PaymentType { DEFAULT, KNET, MPGS }

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Hesabe hesabe;
  bool showLoader = false;
  PaymentType paymentType = PaymentType.DEFAULT;
  late final TextEditingController urlController;
  late final TextEditingController merchantCodeController;
  late final TextEditingController orderRefNumberController;
  late final TextEditingController failureUrlController;
  late final TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    hesabe = Hesabe(
      baseUrl: 'https://sandbox.hesabe.com',
      accessCode: 'c333729b-d060-4b74-a49d-7686a8353481',
      ivKey: '5NVdrlPVNnjo2Jy9',
      secretKey: 'PkW64zMe5NVdrlPVNnjo2Jy9nOb7v1Xg',
    );
    urlController = TextEditingController();
    failureUrlController = TextEditingController();
    merchantCodeController = TextEditingController();
    orderRefNumberController = TextEditingController();
    amountController = TextEditingController();
    hesabe.on(Hesabe.EVENT_PAYMENT_SUCCESS, (data) {
      setState(() {
        showLoader = false;
      });
      navigateToResultScreen(data, false);
    });
    hesabe.on(Hesabe.EVENT_PAYMENT_ERROR, (data) {
      setState(() {
        showLoader = false;
      });
      navigateToResultScreen(data, true);
    });
  }

  void navigateToResultScreen(data, bool isError) {
    if (data != null)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            isError: isError,
            response: data,
          ),
        ),
      );
  }

  Map<String, dynamic> _getPaymentRequestObject() {
    return {
      "merchantCode": merchantCodeController.text.isNotEmpty == true
          ? merchantCodeController.text
          : "842217",
      "amount": amountController.text.isNotEmpty == true
          ? amountController.text
          : '2.000',
      "paymentType": "${paymentType.index}",
      "responseUrl": urlController.text.isNotEmpty == true
          ? urlController.text
          : "https://sandbox.hesabe.com/customer-response?id=842217",
      "failureUrl": failureUrlController.text.isNotEmpty == true
          ? failureUrlController.text
          : "https://sandbox.hesabe.com/customer-response?id=842217",
      "version": "2.0",
      "orderReferenceNumber": orderRefNumberController.text.isNotEmpty == true
          ? orderRefNumberController.text
          : "OR-12345",
      "variable1": "",
      "variable2": "",
      "variable3": "",
      "variable4": "",
      "variable5": "",
      "name": "",
      "mobile_number": "",
      'email': "",
    };
  }

  @override
  void dispose() {
    urlController.dispose();
    failureUrlController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(_getPaymentRequestObject());
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RadioListTile(
              value: PaymentType.DEFAULT,
              groupValue: paymentType,
              onChanged: (PaymentType? type) {
                setState(() {
                  paymentType = type!;
                });
              },
              title: Text('DEFAULT'),
            ),
            RadioListTile(
              value: PaymentType.KNET,
              groupValue: paymentType,
              onChanged: (PaymentType? type) {
                setState(() {
                  paymentType = type!;
                });
              },
              title: Text('KNET'),
            ),
            RadioListTile(
              value: PaymentType.MPGS,
              groupValue: paymentType,
              activeColor: Colors.blueAccent,
              onChanged: (PaymentType? type) {
                setState(() {
                  paymentType = type!;
                });
              },
              title: Text('MPGS'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Order Ref Number:'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: orderRefNumberController,
                decoration: InputDecoration(
                  hintText: 'Enter Order Ref Number',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Merchant Code:'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: merchantCodeController,
                decoration: InputDecoration(
                  hintText: 'Enter merchant code',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Response url:'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: urlController,
                decoration: InputDecoration(
                  hintText:
                      'Enter response url (example: http://success.hesbstaging.com/',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Failure url:'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: failureUrlController,
                decoration: InputDecoration(
                  hintText:
                      'Enter failure url (example: http://success.hesbstaging.com/',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Amount:'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter amount (default to 2)',
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showLoader = true;
                  });
                  hesabe.openCheckout(
                    context,
                    paymentRequestObject: _getPaymentRequestObject(),
                  );
                },
                child: Text('Open Checkout'),
              ),
            ),
            const SizedBox(height: 16),
            if (showLoader) ...{
              Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
            },
          ],
        ),
      ),
    );
  }
}
