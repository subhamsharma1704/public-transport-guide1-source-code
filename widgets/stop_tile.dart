import 'package:flutter/material.dart';
import '../models/transit_stop.dart';

class StopTile extends StatelessWidget {
  final TransitStop stop;
  final VoidCallback? onTap;

  const StopTile({
    super.key,
    required this.stop,
    this.onTap,
  });

  IconData _getIcon(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('metro') || lower.contains('station')) return Icons.train_rounded;
    if (lower.contains('tram')) return Icons.tram_rounded;
    return Icons.directions_bus_rounded;
  }

  Color _getColor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('metro') || lower.contains('station')) return Colors.indigo;
    if (lower.contains('tram')) return Colors.teal;
    return Colors.deepOrange;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(stop.type);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(_getIcon(stop.type), color: color, size: 20),
        ),
        title: Text(
          stop.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              stop.type,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
            ),
            if (stop.lineInfo != null && stop.lineInfo!.isNotEmpty)
              Text(
                'Lines: ${stop.lineInfo}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: stop.distanceInKm != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${stop.distanceInKm} km',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            : null,
      ),
    );
  }
}
