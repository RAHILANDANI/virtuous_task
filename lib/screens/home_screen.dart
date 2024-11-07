import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../servicies/authentication.dart';
import '../servicies/database.dart';
import '../servicies/firebase.dart';
import 'login_screen.dart';
import '../model/student_record.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbService = DatabaseService.instance;
  final firebaseService = FirebaseService();
  List<Record> records = [];
  String searchQuery = "";
  bool isLoading = true;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    initializePreferences();
    fetchRecords();
  }

  Future<void> initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> fetchRecords() async {
    setState(() {
      isLoading = true;
    });
    final data = await dbService.fetchRecords();

    data.forEach((record) {
      record.isFavorite = _prefs?.getBool(record.id.toString()) ?? false;
    });

    setState(() {
      records = data;
      isLoading = false;
    });
  }

  void addOrEditRecord({Record? record}) async {
    TextEditingController nameController = TextEditingController(text: record?.name ?? "");
    TextEditingController ageController = TextEditingController(text: record?.age.toString() ?? "");
    TextEditingController addressController = TextEditingController(text: record?.address ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record == null ? 'Add Record' : 'Edit Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (int.tryParse(ageController.text) == null) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid age (numbers only).')),
                );
                return;
              }

              Navigator.pop(context);
              final newRecord = Record(
                id: record?.id,
                name: nameController.text,
                age: int.parse(ageController.text),
                address: addressController.text,
                isFavorite: record?.isFavorite ?? false,
              );

              if (record == null) {
                await dbService.addRecord(newRecord);
              } else {
                await dbService.updateRecord(newRecord);
                if (newRecord.isFavorite) {
                  await firebaseService.updateFavoriteList(newRecord);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Student record edited successfully.')),
                );
              }
              fetchRecords();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void toggleFavorite(Record record) async {
    setState(() {
      record.isFavorite = !record.isFavorite;
    });

    _prefs?.setBool(record.id.toString(), record.isFavorite);

    if (record.isFavorite) {
      await firebaseService.addFavoriteList(record);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to favorites.')),
      );
    } else {
      await firebaseService.removeFavoriteList(record.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from favorites.')),
      );
    }
  }

  void deleteRecord(Record record) async {
    await dbService.deleteRecord(record.id!);

    _prefs?.remove(record.id.toString());

    if (record.isFavorite) {
      await firebaseService.removeFavoriteList(record.id!);
    }

    fetchRecords();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Student record deleted successfully.')),
    );
  }

  Future<void> _logout() async {
    await AuthHelper().logout();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = records.where((record) => record.name.contains(searchQuery)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Record'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredRecords.isEmpty
                ? Center(child: Text('No Student data available'))
                : ListView.builder(
              itemCount: filteredRecords.length,
              itemBuilder: (context, index) {
                final record = filteredRecords[index];
                return ListTile(
                  title: Text(record.name),
                  subtitle: Text(record.address),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          addOrEditRecord(record: record);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          record.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: record.isFavorite ? Colors.red : null,
                        ),
                        onPressed: () => toggleFavorite(record),
                      ),
                      IconButton(
                        onPressed: () {
                          deleteRecord(record);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrEditRecord(),
        child: Icon(Icons.add),
      ),
    );
  }
}
