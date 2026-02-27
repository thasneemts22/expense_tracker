import 'package:expense_manager/features/transactions/repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

class TransactionsHistoryScreen extends StatefulWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  State<TransactionsHistoryScreen> createState() =>
      _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    final repo = ExpenseRepository();
    final txns = await repo.getTransactionsWithCategory();

    setState(() {
      transactions = txns;
      isLoading = false;
    });
  }

  Future<void> deleteTransaction(String id) async {
    final repo = ExpenseRepository();

  
    await repo.deleteTransaction(id);

    
    await fetchTransactions();

    
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Deleted successfully ")));
    }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

          
              const Text(
                "Transactions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

  
              Expanded(
                child: isLoading
                    ? shimmerList()
                    : transactions.isEmpty
                    ? const Center(
                        child: Text(
                          "No transactions found.",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final txn = transactions[index];
                          return TransactionTile(
                            id: txn['id'].toString(),
                            title: txn['note'] ?? 'No note',
                            category: txn['category_name'] ?? 'Unknown',
                            date: formatTimestamp(txn['timestamp']),
                            amount: txn['type'] == 'debit'
                                ? "-₹${txn['amount']}"
                                : "+₹${txn['amount']}",
                            isExpense: txn['type'] == 'debit',
                            onDelete: () =>
                                deleteTransaction(txn['id'].toString()),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget shimmerList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFF111111),
          highlightColor: const Color(0xFF222222),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        );
      },
    );
  }
}

class TransactionTile extends StatelessWidget {
  final String id;
  final String title;
  final String category;
  final String date;
  final String amount;
  final bool isExpense;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.isExpense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
      
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: getCategoryIcon(category),
          ),

          const SizedBox(width: 14),

      
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
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
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      color: isExpense ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 18,
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
    final cleanCategory = category.trim().toLowerCase();

    if (cleanCategory.contains('bill')) {
      return SvgPicture.asset("assets/icons/bill.svg", height: 22, width: 22);
    } else {
      return SvgPicture.asset("assets/icons/cart.svg", height: 22, width: 22);
    }
  }
}
