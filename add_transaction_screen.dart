
import 'package:flutter/material.dart';

import '../../models/crop.dart';
import '../../repo/crop_repo.dart';


class AddTransactionScreen extends StatefulWidget {
  final Crop crop;
  const AddTransactionScreen({super.key, required this.crop});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final buyer = TextEditingController();
  final qty = TextEditingController();
  final total = TextEditingController();
  DateTime date = DateTime.now();
  bool loading = false;
  final repo = CropRepo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: buyer, decoration: const InputDecoration(labelText: 'Buyer name')),
            const SizedBox(height: 12),
            TextField(controller: qty, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: total, decoration: const InputDecoration(labelText: 'Total Price (Rs)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Text('Date: ${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}')),
              TextButton(onPressed: () async {
                final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100));
                if (picked != null) setState(() => date = picked);
              }, child: const Text('Pick date'))
            ]),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: loading ? null : () async {
                  if (buyer.text.isEmpty || qty.text.isEmpty || total.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields are required')));
                    return;
                  }
                  setState(() => loading = true);
                  try {
                    await repo.addTransaction(
                      cropId: widget.crop.id,
                      buyerName: buyer.text.trim(),
                      quantity: double.parse(qty.text),
                      totalPrice: double.parse(total.text),
                      date: date,
                    );
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  } finally {
                    if (mounted) setState(() => loading = false);
                  }
                },
                child: const Text('Save Transaction'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
