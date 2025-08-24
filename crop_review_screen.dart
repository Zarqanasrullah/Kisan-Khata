import 'package:flutter/material.dart';
import '../../models/crop.dart';
import '../../repo/crop_repo.dart';

class CropReviewScreen extends StatefulWidget {
  final Crop crop;

  const CropReviewScreen({super.key, required this.crop});

  @override
  State<CropReviewScreen> createState() => _CropReviewScreenState();
}

class _CropReviewScreenState extends State<CropReviewScreen> {
  final note = TextEditingController();
  bool working = false;


  @override
  Widget build(BuildContext context) {
    final c = widget.crop;
    final url = dummyCropImages[c.type]
        ?? 'https://placehold.co/1024x768?text=${Uri.encodeComponent(c.type)}';
    return Scaffold(
      appBar: AppBar(title: const Text('Review Crop')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(aspectRatio: 16 / 9, child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(url, fit: BoxFit.fill))),
          const SizedBox(height: 12),
          Text('${c.name} • ${c.type}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Price: Rs ${c.pricePerUnit.toStringAsFixed(2)} ${c.unit}'),
          const SizedBox(height: 12),
          TextField(
              controller: note, maxLines: 3, decoration: const InputDecoration(labelText: 'Admin note (optional)')),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton.icon(
                      onPressed: working
                          ? null
                          : () async {
                              setState(() => working = true);
                              await CropRepo().approve(c.id, note: note.text);
                              if (mounted) Navigator.pop(context);
                            },
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'))),
              const SizedBox(width: 12),
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: working
                          ? null
                          : () async {
                              setState(() => working = true);
                              await CropRepo().reject(c.id, note: note.text);
                              if (mounted) Navigator.pop(context);
                            },
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'))),
            ],
          )
        ],
      ),
    );
  }
}
