import 'dart:convert';

import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  final dynamic response;
  final bool? isError;

  const ResultScreen({
    Key? key,
    this.response,
    this.isError = false,
  }) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool isError = false;
  @override
  void initState() {
    isError = widget.isError ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  !isError
                      ? 'Success! Transaction successful.'
                      : ' Error! Transaction failed. ',
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        color: isError ? Colors.red : Colors.green,
                      ),
                ),
                if (widget.response is Map &&
                    widget.response.containsKey('resultCode')) ...{
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Result Code: ${widget.response['resultCode']}'),
                      const SizedBox(height: 8),
                      Text('Payment Token: ${widget.response['paymentToken']}'),
                      const SizedBox(height: 8),
                      Text('paymentId: ${widget.response['paymentId']}'),
                      const SizedBox(height: 8),
                      Text('paidOn: ${widget.response['paidOn']}'),
                      const SizedBox(height: 8),
                      Text(
                          'orderReferenceNumber: ${widget.response['orderReferenceNumber']}'),
                      const SizedBox(height: 8),
                      Text('variable1: ${widget.response['variable1']}'),
                      const SizedBox(height: 8),
                      Text('variable2: ${widget.response['variable2']}'),
                      const SizedBox(height: 8),
                      Text('variable3: ${widget.response['variable3']}'),
                      const SizedBox(height: 8),
                      Text('variable4: ${widget.response['variable4']}'),
                      const SizedBox(height: 8),
                      Text('variable5: ${widget.response['variable5']}'),
                      const SizedBox(height: 8),
                      Text('method: ${widget.response['method']}'),
                      const SizedBox(height: 8),
                      Text(
                          'administrativeCharge: ${widget.response['administrativeCharge']}'),
                    ],
                  ),
                } else ...{
                  const SizedBox(height: 8),
                  Text('${widget.response}'),
                },
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getPrettyJson() {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    return encoder.convert(widget.response);
  }
}
