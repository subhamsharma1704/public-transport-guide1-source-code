import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../models/travel_note.dart';
import '../../widgets/route_card.dart';
import '../routes/route_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddEditNoteDialog(BuildContext context, {TravelNote? existingNote}) {
    final titleController = TextEditingController(text: existingNote?.title ?? '');
    final contentController = TextEditingController(text: existingNote?.content ?? '');
    final routeController = TextEditingController(text: existingNote?.routeName ?? 'Daily Commute Line');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existingNote == null ? 'Add Travel Note / Reminder' : 'Edit Travel Note'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title / Subject'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: routeController,
                  decoration: const InputDecoration(labelText: 'Associated Route / Bus No.'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes, Timings, Platform info...',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter note content' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final favProvider = Provider.of<FavoritesProvider>(context, listen: false);
                if (existingNote == null) {
                  favProvider.addTravelNote(
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    routeName: routeController.text.trim(),
                  );
                } else {
                  favProvider.updateTravelNote(
                    existingNote.copyWith(
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                      routeName: routeController.text.trim(),
                    ),
                  );
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(existingNote == null ? 'Note added successfully!' : 'Note updated!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved & Travel Notes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.favorite_rounded, size: 20),
              text: 'Routes (${favProvider.favoriteRoutes.length})',
            ),
            Tab(
              icon: const Icon(Icons.note_alt_rounded, size: 20),
              text: 'Notes & Plans (${favProvider.travelNotes.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. FAVORITE ROUTES TAB
          favProvider.favoriteRoutes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border_rounded, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No Favorite Routes Saved',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Search routes and tap the heart icon to save for quick access.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: favProvider.favoriteRoutes.length,
                  itemBuilder: (ctx, i) {
                    final route = favProvider.favoriteRoutes[i];
                    return Dismissible(
                      key: Key('fav_${route.id}_$i'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        favProvider.removeFavorite(i);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Removed from favorites')),
                        );
                      },
                      child: RouteCard(
                        route: route,
                        isFavorite: true,
                        onFavoriteTap: () => favProvider.toggleFavorite(route),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => RouteDetailsScreen(route: route)),
                          );
                        },
                      ),
                    );
                  },
                ),

          // 2. TRAVEL NOTES CRUD TAB
          favProvider.travelNotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_note_rounded, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No Travel Notes or Reminders',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('Add notes for bus schedules, platform numbers, and metro tokens.'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditNoteDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Note'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: favProvider.travelNotes.length,
                  itemBuilder: (ctx, i) {
                    final note = favProvider.travelNotes[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: note.isPinned ? Colors.amber : Colors.grey.withOpacity(0.2),
                          width: note.isPinned ? 1.5 : 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                    color: note.isPinned ? Colors.amber.shade700 : Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () => favProvider.togglePinNote(note.id),
                                ),
                                PopupMenuButton(
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                                  ],
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      _showAddEditNoteDialog(context, existingNote: note);
                                    } else if (val == 'delete') {
                                      favProvider.deleteTravelNote(note.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                            if (note.routeName.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  note.routeName,
                                  style: const TextStyle(color: Colors.teal, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              note.content,
                              style: const TextStyle(fontSize: 13, height: 1.3),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Created: ${note.createdAt}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditNoteDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
      ),
    );
  }
}
