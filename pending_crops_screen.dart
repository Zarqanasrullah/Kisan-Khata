
import 'package:flutter/material.dart';
import '../../models/crop.dart';
import '../../repo/crop_repo.dart';
import 'crop_review_screen.dart';
import 'admin_crop_detail_screen.dart';

class PendingCropsScreen extends StatefulWidget {
  const PendingCropsScreen({super.key});
  @override
  State<PendingCropsScreen> createState() => _PendingCropsScreenState();
}

class _PendingCropsScreenState extends State<PendingCropsScreen> {
  bool _showApproved = false;

  @override
  Widget build(BuildContext context) {
    final repo = CropRepo();
    return Scaffold(
      appBar: AppBar(
        title: Text(_showApproved ? 'Approved Crops (Admin)' : 'Pending Crops (Admin)'),
        actions: [
          IconButton(
            tooltip: _showApproved ? 'Show Pending' : 'Show Approved',
            onPressed: () => setState(() => _showApproved = !_showApproved),
            icon: Icon(_showApproved ? Icons.hourglass_top_outlined : Icons.verified_outlined),
          )
        ],
      ),
      body: StreamBuilder<List<Crop>>(
        stream: _showApproved ? repo.approvedCropsStream() : repo.pendingCropsStream(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          if (items.isEmpty) return Center(child: Text(_showApproved ? 'No approved crops' : 'No pending crops'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, i) {
              final c = items[i];
              final url = dummyCropImages[c.type]
                  ?? 'https://placehold.co/1024x768?text=${Uri.encodeComponent(c.type)}';

              return ListTile(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _showApproved ? AdminCropDetailScreen(crop: c) : CropReviewScreen(crop: c))),
                leading: CircleAvatar(backgroundImage: NetworkImage(url)),
                title: Text('${c.name} • ${c.type}'),
                subtitle: Text('Rs ${c.pricePerUnit.toStringAsFixed(2)} ${c.unit}'),
                trailing: Chip(label: Text(c.status.name.toUpperCase())),
              );
            },
          );
        },
      ),
    );
  }
}
