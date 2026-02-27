import 'package:expense_manager/constants/appcolor.dart';
import 'package:expense_manager/features/auth/screens/phone_screen.dart';
import 'package:expense_manager/features/transactions/bloc/sync_bloc.dart';
import 'package:expense_manager/features/transactions/bloc/sync_event.dart';
import 'package:expense_manager/features/transactions/bloc/sync_state.dart';
import 'package:expense_manager/features/transactions/models/category_model.dart';
import 'package:expense_manager/features/transactions/repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String nickname = "";
  final ExpenseRepository _repo = ExpenseRepository();
  List<Category> categories = [];
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  double currentLimit = 0;

  @override
  void initState() {
    super.initState();
    _loadNickname();
    _loadCategories();
    _loadLimit();
  }

  Future<void> _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNickname = prefs.getString("nickname") ?? "No nickname";
    setState(() {
      nickname = savedNickname;
    });
  }

  Future<void> _loadCategories() async {
    final fetchedCategories = await _repo.getCategories();

    if (!mounted) return;

    setState(() {
      categories = fetchedCategories.where((c) => c.isDeleted == 0).toList();
    });
  }

  Future<void> _addCategory() async {
    final name = _categoryController.text.trim();
    if (name.isEmpty) return;

    final newCategory = Category(id: const Uuid().v4(), name: name);
    await _repo.insertCategory(newCategory);
    _categoryController.clear();
    await _loadCategories();
  }

  Future<void> _deleteCategory(String id) async {
    try {
      
      final db = await _repo.dbHelper.database;
      await db.update(
        "categories",
        {"is_deleted": 1, "is_synced": 0},
        where: "id = ?",
        whereArgs: [id],
      );

      if (!mounted) return;

    
      final updatedCategories = await _repo.getCategories();
      setState(() {
        categories = updatedCategories;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Deleted Successfully ")));
    } catch (e) {
      debugPrint("Delete error : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

            
              const Text(
                "Profile & Settings",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 25),

            
              const Text(
                "NICKNAME",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        nickname,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    GestureDetector(
                      onTap: _editNickname,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ALERT LIMIT (₹)",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _limitController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: "Amount ( ₹ )",
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _setLimit,
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                "Set",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Current Limit: ₹${currentLimit.toStringAsFixed(0)}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              
              const Text(
                "CATEGORIES",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: _categoryController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: "New category Name",
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _addCategory,
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: Colors.white10, height: 30),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final c = categories[index];
                        return categoryTile(c.name, c.id);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

            
              const Text(
                "CLOUD SYNC",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 15),
              BlocListener<SyncBloc, SyncState>(
                listener: (context, state) async {
                  if (state is SyncLoading) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("Syncing...")));
                  }

                  if (state is SyncSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sync Success ")),
                    );

                    await _loadCategories();
                  }

                  if (state is SyncError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    context.read<SyncBloc>().add(SyncNowEvent());
                  },
                  child: Container(
                    padding: EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4B3EFF), Color(0xFF3A2EDC)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sync To Cloud",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Sync and update data to the backend",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.cloud_upload, color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 25),

        
              GestureDetector(
                onTap: () {
                

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PhoneScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Center(
                    child: Text(
                      "Log Out ⏻",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryTile(String title, String id) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          GestureDetector(
            onTap: () => _deleteCategory(id),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: const Icon(Icons.delete, color: Colors.red, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editNickname() async {
    final controller = TextEditingController(text: nickname);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: const Text(
            "Edit Nickname",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter nickname",
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) return;

                final prefs = await SharedPreferences.getInstance();
                await prefs.setString("nickname", newName);

                if (!mounted) return;

                setState(() {
                  nickname = newName;
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLimit = prefs.getDouble("monthly_limit") ?? 0;

    if (!mounted) return;

    setState(() {
      currentLimit = savedLimit;
    });
  }

  Future<void> _setLimit() async {
    final value = double.tryParse(_limitController.text.trim());

    if (value == null || value <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid amount")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("monthly_limit", value);

    if (!mounted) return;

    setState(() {
      currentLimit = value;
    });

    _limitController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Limit Updated ")));
  }
}
