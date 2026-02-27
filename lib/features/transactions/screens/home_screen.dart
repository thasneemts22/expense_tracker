import 'package:expense_manager/constants/appcolor.dart';
import 'package:expense_manager/core/services/notification_service.dart';
import 'package:expense_manager/features/transactions/repository/expense_repository.dart';
import 'package:expense_manager/features/transactions/screens/transaction_bottomsheet_screen.dart';
import 'package:expense_manager/features/transactions/services/limit_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String nickname = "";
  List<Map<String, dynamic>> transactions = [];
  double totalIncome = 0;
  double totalExpense = 0;
  bool isLoading = true;
  double monthlyLimit = 0;
  double monthlyExpense = 0;
  double remainingPercent = 0;
  double progressValue = 0;

  @override
  void initState() {
    super.initState();

    _loadNickname();

    Future.microtask(() async {
      await fetchTransactions();
      await checkMonthlyLimit();
    });
  }

  Future<void> _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNickname = prefs.getString("nickname") ?? "User";
    setState(() {
      nickname = savedNickname;
    });
  }

  Future<void> fetchTransactions() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    final repo = ExpenseRepository();

    final txns = await repo.getTransactionsWithCategory(limit: 10);

    final totals = await repo.getTotals();

    if (!mounted) return;

    setState(() {
      transactions = txns;
      totalIncome = totals['income'] ?? 0;
      totalExpense = totals['expense'] ?? 0;
      isLoading = false;
    });
  }

  String formatTimestamp(String? isoString) {
    if (isoString == null) return 'N/A';
    try {
      final dt = DateTime.parse(isoString);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (_) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.success,
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return const TransactionBottomsheetScreen();
            },
          );

          
          await fetchTransactions();
          await checkMonthlyLimit();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

            
                Text(
                  "👋 Welcome, $nickname!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

            
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F9D58), Color(0xFF087F23)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total Income",
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "↓ ₹${totalIncome.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD32F2F), Color(0xFF8E0000)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total Expense",
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "↑ ₹${totalExpense.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "MONTHLY LIMIT",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "₹${monthlyExpense.toStringAsFixed(0)} / ₹${monthlyLimit.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (monthlyExpense >= monthlyLimit)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 18,
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 6,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation(
                            monthlyExpense >= monthlyLimit
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// Status Text
                      Text(
                        monthlyExpense >= monthlyLimit
                            ? "Limit Exceeded"
                            : monthlyLimit > 0
                            ? "${(100 - (monthlyExpense / monthlyLimit * 100)).clamp(0, 100).toStringAsFixed(0)}% Remaining"
                            : "100% Remaining",
                        style: TextStyle(
                          color: monthlyExpense >= monthlyLimit
                              ? Colors.redAccent
                              : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

          
                const Text(
                  "Recent Transactions",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                isLoading
                    ? shimmerList()
                    : transactions.isEmpty
                    ? const Text(
                        "No transactions yet",
                        style: TextStyle(color: Colors.white54),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final txn = transactions[index];
                          print("CATEGORY ID: ${txn['category_id']}");
                          print("CATEGORY NAME: ${txn['category_name']}");

                          return transactionTile(
                            id: txn['id'].toString(),
                            title: txn['note'] ?? 'No note',
                            category: txn['category_name'] ?? 'Unknown',
                            date: formatTimestamp(txn['timestamp']),
                            amount: txn['type'] == 'debit'
                                ? "-₹${txn['amount']}"
                                : "+₹${txn['amount']}",
                            isExpense: txn['type'] == 'debit',
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget shimmerList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFF1C1C1E),
          highlightColor: const Color(0xFF2C2C2E),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      },
    );
  }

  Widget transactionTile({
    required String id,
    required String title,
    required String category,
    required String date,
    required String amount,
    required bool isExpense,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          getCategoryIcon(category),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(category, style: const TextStyle(color: Colors.white54)),
              ],
            ),
          ),

          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Row(
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      color: isExpense ? Colors.red : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => deleteTransaction(id),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getCategoryIcon(String category) {
    print("CATEGORY VALUE RECEIVED: $category");

    if (category.toLowerCase().contains('bill')) {
      return SvgPicture.asset("assets/icons/bill.svg", height: 22, width: 22);
    } else {
      return SvgPicture.asset("assets/icons/cart.svg", height: 22, width: 22);
    }
  }

  Future<void> deleteTransaction(String id) async {
    final repo = ExpenseRepository();

    await repo.deleteTransaction(id);

    if (!mounted) return;

    await fetchTransactions();
    await checkMonthlyLimit();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Deleted successfully ")));
  }

  Future<void> checkMonthlyLimit() async {
    final repo = ExpenseRepository();
    final limitService = LimitService();
    final notification = NotificationService();

    final totals = await repo.getTotals();

    final income = totals['income'] ?? 0;
    final expense = totals['expense'] ?? 0;

    final total = income + expense; 

    final limit = await limitService.getLimit();

    double percent = 0;

    if (limit > 0) {
      percent = (total / limit).clamp(0.0, 1.0);
    }

    if (total > limit) {
      await notification.showLimitExceededNotification(
        currentTotal: total,
        limit: limit,
      );
    }

    if (!mounted) return;

    setState(() {
      monthlyExpense = total; 
      monthlyLimit = limit;
      progressValue = percent;
    });
  }
}
