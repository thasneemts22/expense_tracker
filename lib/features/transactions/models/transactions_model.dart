class TransactionModel {
  final String id;
  final String note;
  final double amount;
  final String type;
  final String? categoryId;
  final String timestamp;
  final int isSynced;
  final int isDeleted;

  TransactionModel({
    required this.id,
    required this.note,
    required this.amount,
    required this.type,
    this.categoryId,
    required this.timestamp,
    this.isSynced = 0,
    this.isDeleted = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note': note,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'timestamp': timestamp,
      'is_synced': isSynced,
      'is_deleted': isDeleted,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      note: map['note'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? 'debit',
      categoryId: map['category_id'],
      timestamp: map['timestamp'] ?? '',
      isSynced: map['is_synced'] ?? 0,
      isDeleted: map['is_deleted'] ?? 0,
    );
  }
}
