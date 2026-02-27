import 'package:expense_manager/constants/appcolor.dart';
import 'package:expense_manager/core/database/app_database.dart';
import 'package:expense_manager/features/transactions/models/category_model.dart';
import 'package:expense_manager/features/transactions/models/transactions_model.dart';
import 'package:expense_manager/core/services/notification_service.dart';
import 'package:expense_manager/features/transactions/repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TransactionBottomsheetScreen extends StatefulWidget {
  final VoidCallback? onTransactionAdded;
  const TransactionBottomsheetScreen({super.key, this.onTransactionAdded});

  @override
  State<TransactionBottomsheetScreen> createState() =>
      _TransactionBottomsheetScreenState();
}

class _TransactionBottomsheetScreenState
    extends State<TransactionBottomsheetScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool isExpense = true;
  String selectedCategory = "Food";
  final transactionRepo = ExpenseRepository(); 
  List<Category> categories = [
    Category(id: "1", name: "Food"),
    Category(id: "2", name: "Bills"),
    Category(id: "3", name: "Transport"),
    Category(id: "4", name: "Shopping"),
  ];

  Future<void> insertCategoryIfNotExists(String name) async {
    final db = await DBHelper.instance.database;
    final result = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (result.isEmpty) {
      await db.insert('categories', {
        'id': Uuid().v4(),
        'name': name,
        'is_synced': 0,
        'is_deleted': 0,
      });
    }
  }

  
  Future<String> getCategoryId(String name) async {
    try {
      final category = categories.firstWhere((c) => c.name == name);
      return category.id;
    } catch (_) {
      throw Exception("Category not found");
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Padding(
      
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add Transaction",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Close",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

          
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: toggleBtn("Expense", isExpense, () {
                          setState(() {
                            isExpense = true;
                          });
                        }),
                      ),
                      Expanded(
                        child: toggleBtn("Income", !isExpense, () {
                          setState(() {
                            isExpense = false;
                          });
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

        
                inputField("Title", controller: titleController),

                const SizedBox(height: 12),

        
                inputField(
                  "Amount ( ₹ )",
                  controller: amountController,
                  keyboard: TextInputType.number,
                ),

                const SizedBox(height: 20),

                const Text(
                  "CATEGORY",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),

                const SizedBox(height: 10),
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: categories.map((c) => categoryChip(c)).toList(),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Everything you add here is saved only on your device.",
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final note = titleController.text.trim();
                      final amount =
                          double.tryParse(amountController.text.trim()) ?? 0.0;
                      print(
                        "DEBUG: note='$note', amount=$amount, category=$selectedCategory, type=${isExpense ? 'debit' : 'credit'}",
                      );

                      if (note.isEmpty || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter valid note and amount"),
                          ),
                        );
                        return;
                      }

                      try {
                        await insertCategoryIfNotExists(selectedCategory);
                        final categoryId = await getCategoryId(
                          selectedCategory,
                        );

                        double previousMonthTotal = 0;
                        if (isExpense) {
                          previousMonthTotal = await transactionRepo
                              .getCurrentMonthExpense();
                        }

                        final txn = TransactionModel(
                          id: Uuid().v4(),
                          note: note,
                          amount: amount,
                          type: isExpense ? 'debit' : 'credit',
                          categoryId: categoryId,
                          timestamp: DateTime.now().toIso8601String(),
                        );

                        await transactionRepo.insertTransaction(txn);
                        print("DEBUG: Transaction inserted with ID ${txn.id}");

                        if (isExpense) {
                          double newTotal = previousMonthTotal + amount;
                          const double budgetLimit = 1000.0;
                          if (previousMonthTotal <= budgetLimit &&
                              newTotal > budgetLimit) {
                            await NotificationService()
                                .showLimitExceededNotification(
                                  currentTotal: newTotal,
                                  limit: budgetLimit,
                                );
                          }
                        }

              
                        if (widget.onTransactionAdded != null) {
                          widget.onTransactionAdded!();
                        }

                        Navigator.pop(context, true);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Transaction added!")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error saving transaction: $e"),
                          ),
                        );
                      }
                    },

                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget inputField(
    String hint, {
    TextEditingController? controller,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: '',
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ).copyWith(hintText: hint),
      ),
    );
  }

  Widget toggleBtn(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget categoryChip(Category c) {
    final isSelected = selectedCategory == c.name;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = c.name; 
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          c.name,
          style: TextStyle(color: isSelected ? Colors.white : Colors.white70),
        ),
      ),
    );
  }
}
