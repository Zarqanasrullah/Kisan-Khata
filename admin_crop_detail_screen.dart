import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/crop.dart';
import '../../repo/crop_repo.dart';
import 'add_transaction_screen.dart';

class AdminCropDetailScreen extends StatelessWidget {
  final Crop crop;

  const AdminCropDetailScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final repo = CropRepo();
    final url = dummyCropImages[crop.type]
        ?? 'https://placehold.co/1024x768?text=${Uri.encodeComponent(crop.type)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Crop (Admin)')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen(crop: crop))),
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: 16 / 9, child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(url, fit: BoxFit.fill))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${crop.name} • ${crop.type}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('Asking: Rs ${crop.pricePerUnit.toStringAsFixed(2)} ${crop.unit}'),
              if (crop.adminNote != null && crop.adminNote!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Note: ${crop.adminNote}'),
              ],
              const SizedBox(height: 16),
              Text('Transactions', style: Theme.of(context).textTheme.titleMedium),
            ]),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: repo.transactionsStream(crop.id),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final tx = snap.data!;
                if (tx.isEmpty) return const Center(child: Text('No transactions yet'));
                return ListView.builder(
                  itemCount: tx.length,
                  itemBuilder: (context, i) {
                    final t = tx[i];
                    final ts = (t['date'] as Timestamp?)?.toDate();
                    return ListTile(
                      leading: const Icon(Icons.handshake_outlined),
                      title: Text(t['buyerName'] ?? '—'),
                      subtitle:
                          Text('Qty: ${t['quantity']} • Total: Rs ${(t['totalPrice'] as num).toStringAsFixed(2)}'),
                      trailing: Text(ts != null
                          ? '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')}'
                          : ''),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
