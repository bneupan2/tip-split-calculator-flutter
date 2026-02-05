import 'package:flutter/material.dart';

void main() {
  runApp(const TipSplitApp());
}

class TipSplitApp extends StatelessWidget {
  const TipSplitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tip & Split Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const InputScreen(),
    );
  }
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _billController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();

  @override
  void dispose() {
    _billController.dispose();
    _tipController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  void _calculateAndGo() {
    // Validate first
    if (!_formKey.currentState!.validate()) return;

    final double bill = double.parse(_billController.text.trim());
    final double tipPercent = double.parse(_tipController.text.trim());
    final int people = int.parse(_peopleController.text.trim());

    final double tipAmount = bill * (tipPercent / 100);
    final double total = bill + tipAmount;
    final double perPerson = total / people;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          bill: bill,
          tipPercent: tipPercent,
          tipAmount: tipAmount,
          total: total,
          people: people,
          perPerson: perPerson,
        ),
      ),
    );
  }

  void _clearAll() {
    _billController.clear();
    _tipController.clear();
    _peopleController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tip + Split Calculator'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Enter bill details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Bill Amount
                TextFormField(
                  controller: _billController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Bill Amount (\$)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Please enter the bill amount.';
                    final n = double.tryParse(v);
                    if (n == null) return 'Enter a valid number.';
                    if (n <= 0) return 'Bill amount must be greater than 0.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tip %
                TextFormField(
                  controller: _tipController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Tip Percentage (%)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.percent),
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Please enter the tip percentage.';
                    final n = double.tryParse(v);
                    if (n == null) return 'Enter a valid number.';
                    if (n < 0) return 'Tip cannot be negative.';
                    if (n > 100)
                      return 'Tip percentage seems too high (max 100).';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // People
                TextFormField(
                  controller: _peopleController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of People',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Please enter number of people.';
                    final n = int.tryParse(v);
                    if (n == null) return 'Enter a valid whole number.';
                    if (n <= 0) return 'People must be at least 1.';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _calculateAndGo,
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calculate'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _clearAll,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                const Text(
                  'Tip: Try bill = 50, tip = 15, people = 2',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final double bill;
  final double tipPercent;
  final double tipAmount;
  final double total;
  final int people;
  final double perPerson;

  const ResultScreen({
    super.key,
    required this.bill,
    required this.tipPercent,
    required this.tipAmount,
    required this.total,
    required this.people,
    required this.perPerson,
  });

  String money(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bill Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),

                      _row('Bill Amount', '\$${money(bill)}'),
                      _row('Tip (%)', '${money(tipPercent)}%'),
                      _row('Tip Amount', '\$${money(tipAmount)}'),
                      const Divider(height: 24),
                      _row('Total', '\$${money(total)}', isBold: true),

                      const SizedBox(height: 14),
                      _row('People', '$people'),
                      const Divider(height: 24),
                      _row('Per Person', '\$${money(perPerson)}', isBold: true),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Recalculate'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String left, String right, {bool isBold = false}) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: style),
          Text(right, style: style),
        ],
      ),
    );
  }
}
