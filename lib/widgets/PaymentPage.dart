import 'package:flutter/material.dart';
import 'package:koumi/widgets/Subscribe.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);


class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
       appBar: AppBar(
        backgroundColor: d_colorOr,
        toolbarHeight: 75,
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Subscribe()));
                  
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "Paiement",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}