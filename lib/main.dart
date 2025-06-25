import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// Item class **WEEK 2**
class InventoryItem {
  String name;
  int quantity;
  String location;

  InventoryItem(this.name, this.quantity, this.location);
}

// Root widget of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true, // modern Material design
      ),
      home: const HomePage(),
    );
  }
}

// Update to stateful home page **WEEK 2**
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Update to include functionality **WEEK 2**
class _HomePageState extends State<HomePage> {
  final List<InventoryItem> items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Tracker'), centerTitle: true),
      body: items.isEmpty
          ? const Center(
              child: Text('Inventory is empty', style: TextStyle(fontSize: 20)),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: const Icon(Icons.inventory),
                  title: Text(item.name),
                  subtitle: Text(
                    'Qty: ${item.quantity} | Location: ${item.location}',
                  ),
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
            setState(() => items.add(newItem));
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
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final locationController = TextEditingController();

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
      appBar: AppBar(title: const Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            ElevatedButton(onPressed: saveItem, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
