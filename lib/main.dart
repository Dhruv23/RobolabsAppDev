import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: webOptions);
  runApp(const MyApp());
}

// Item class
class InventoryItem {
  String name;
  int quantity;
  String location;

  InventoryItem(this.name, this.quantity, this.location);

  factory InventoryItem.fromMap(Map<String, dynamic> data) {
    return InventoryItem(
      data['name'] ?? 'Unnamed',
      data['quantity'] ?? 0,
      data['location'] ?? 'Unknown',
    );
  }
}

// Root widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robolabs Inventory Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB2232A), // Robolabs Red
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1C1C1C), // Dark background
        textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB2232A),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFB2232A),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// Home Page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _hoveredIndex;

  Future<void> addItemToFirebase(InventoryItem item) async {
    await FirebaseFirestore.instance.collection('inventory').add({
      'name': item.name,
      'quantity': item.quantity,
      'location': item.location,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteItem(String docId) async {
    await FirebaseFirestore.instance
        .collection('inventory')
        .doc(docId)
        .delete();
  }

  Future<void> editItem(String docId, InventoryItem updatedItem) async {
    await FirebaseFirestore.instance.collection('inventory').doc(docId).update({
      'name': updatedItem.name,
      'quantity': updatedItem.quantity,
      'location': updatedItem.location,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Robolabs Inventory Tracker',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Image.asset('assets/robolabs_logo.png', height: 30),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('inventory')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('Inventory is empty', style: TextStyle(fontSize: 20)),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final item = InventoryItem.fromMap(
                doc.data() as Map<String, dynamic>,
              );

              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredIndex = index),
                onExit: (_) => setState(() => _hoveredIndex = null),
                child: ListTile(
                  leading: const Icon(Icons.inventory),
                  title: Text(item.name),
                  subtitle: Text(
                    'Qty: ${item.quantity} | Location: ${item.location}',
                  ),
                  trailing: _hoveredIndex == index
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () async {
                                final edited = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddItemPage(item: item),
                                  ),
                                );

                                if (edited != null && edited is InventoryItem) {
                                  await editItem(doc.id, edited);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete item?'),
                                    content: Text(
                                      'Are you sure you want to delete "${item.name}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await deleteItem(doc.id);
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newItem = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemPage()),
          );

          if (newItem != null && newItem is InventoryItem) {
            await addItemToFirebase(newItem);
          }
        },
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Screen to add a new item **WEEK 2**

class AddItemPage extends StatefulWidget {
  final InventoryItem? item;
  const AddItemPage({super.key, this.item});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      nameController.text = widget.item!.name;
      quantityController.text = widget.item!.quantity.toString();
      locationController.text = widget.item!.location;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void saveItem() {
    final name = nameController.text.trim();
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    final location = locationController.text.trim();

    if (name.isNotEmpty && location.isNotEmpty && quantity > 0) {
      Navigator.pop(context, InventoryItem(name, quantity, location));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/robolabs_logo.png',
              height: 30, // adjust as needed
            ),
            const SizedBox(width: 8),
            Text(widget.item != null ? 'Edit Item' : 'Add Item'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form Fields
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveItem,
              child: Text(widget.item != null ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
