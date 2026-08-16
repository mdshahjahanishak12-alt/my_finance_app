import 'package:flutter/material.dart';

void main() {
  runApp(const FinanceApp());
}

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finance',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          primary: const Color(0xFF1565C0),
          surface: Colors.white,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: DashboardScreen(onToggleTheme: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

// Data Models
enum TransactionType { income, expense, transfer }

class Account {
  String id;
  String name;
  double balance;

  Account({required this.id, required this.name, required this.balance});
}

class TransactionItem {
  String id;
  TransactionType type;
  double amount;
  String category;
  String fromAccountId;
  String? toAccountId;
  DateTime date;
  String note;

  TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.fromAccountId,
    this.toAccountId,
    required this.date,
    required this.note,
  });
}

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const DashboardScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Accounts State
  List<Account> accounts = [
    Account(id: '1', name: 'Cash', balance: 5000),
    Account(id: '2', name: 'bKash', balance: 10000),
    Account(id: '3', name: 'Bank', balance: 25000),
  ];

  // Transactions State
  List<TransactionItem> transactions = [];

  // Helper Calculations (Automatic Engine)
  double get totalBalance {
    return accounts.fold(0, (sum, acc) => sum + acc.balance);
  }

  double get monthlyIncome {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpense {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get monthlySavings => monthlyIncome - monthlyExpense;

  // Transaction Operations
  void _addTransaction(TransactionItem t) {
    setState(() {
      transactions.insert(0, t);
      if (t.type == TransactionType.income) {
        final acc = accounts.firstWhere((a) => a.id == t.fromAccountId);
        acc.balance += t.amount;
      } else if (t.type == TransactionType.expense) {
        final acc = accounts.firstWhere((a) => a.id == t.fromAccountId);
        acc.balance -= t.amount;
      } else if (t.type == TransactionType.transfer) {
        final fromAcc = accounts.firstWhere((a) => a.id == t.fromAccountId);
        final toAcc = accounts.firstWhere((a) => a.id == t.toAccountId);
        fromAcc.balance -= t.amount;
        toAcc.balance += t.amount;
      }
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      final t = transactions.firstWhere((item) => item.id == id);
      if (t.type == TransactionType.income) {
        final acc = accounts.firstWhere((a) => a.id == t.fromAccountId);
        acc.balance -= t.amount;
      } else if (t.type == TransactionType.expense) {
        final acc = accounts.firstWhere((a) => a.id == t.fromAccountId);
        acc.balance += t.amount;
      } else if (t.type == TransactionType.transfer) {
        final fromAcc = accounts.firstWhere((a) => a.id == t.fromAccountId);
        final toAcc = accounts.firstWhere((a) => a.id == t.toAccountId);
        fromAcc.balance += t.amount;
        toAcc.balance -= t.amount;
      }
      transactions.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('স্বাগতম, শাহজাহান'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('বর্তমান ব্যালেন্স', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('৳ ${totalBalance.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🟢 মোট আয়', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('৳ ${monthlyIncome.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🔴 মোট খরচ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('৳ ${monthlyExpense.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🔵 সঞ্চয়', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('৳ ${monthlySavings.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Accounts Overview
            const Text('একাউন্টসমূহ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final acc = accounts[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('৳ ${acc.balance.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF1565C0))),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Recent Transactions Section
            const Text('সাম্প্রতিক লেনদেন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            transactions.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('কোনো লেনদেন যুক্ত করা হয়নি।')))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final item = transactions[index];
                      final isIncome = item.type == TransactionType.income;
                      final isExpense = item.type == TransactionType.expense;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isIncome
                                ? const Color(0xFF2E7D32).withOpacity(0.1)
                                : isExpense
                                    ? const Color(0xFFC62828).withOpacity(0.1)
                                    : Colors.blue.withOpacity(0.1),
                            child: Icon(
                              isIncome
                                  ? Icons.arrow_downward
                                  : isExpense
                                      ? Icons.arrow_upward
                                      : Icons.swap_horiz,
                              color: isIncome
                                  ? const Color(0xFF2E7D32)
                                  : isExpense
                                      ? const Color(0xFFC62828)
                                      : Colors.blue,
                            ),
                          ),
                          title: Text(item.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item.date.day}/${item.date.month}/${item.date.year} • ${item.note}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${isIncome ? "+" : isExpense ? "-" : ""}৳${item.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isIncome
                                      ? const Color(0xFF2E7D32)
                                      : isExpense
                                          ? const Color(0xFFC62828)
                                          : Colors.blue,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () => _deleteTransaction(item.id),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),

      // FAB for quick actions
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('হিসাব যোগ করুন', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    TransactionType selectedType = TransactionType.expense;
    double amount = 0;
    String category = 'বাজার';
    String fromAccId = accounts[0].id;
    String toAccId = accounts[1].id;
    String note = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16, right: 16, top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ChoiceChip(
                        label: const Text('খরচ'),
                        selected: selectedType == TransactionType.expense,
                        onSelected: (val) => setModalState(() => selectedType = TransactionType.expense),
                      ),
                      ChoiceChip(
                        label: const Text('আয়'),
                        selected: selectedType == TransactionType.income,
                        onSelected: (val) => setModalState(() => selectedType = TransactionType.income),
                      ),
                      ChoiceChip(
                        label: const Text('ট্রান্সফার'),
                        selected: selectedType == TransactionType.transfer,
                        onSelected: (val) => setModalState(() => selectedType = TransactionType.transfer),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'পরিমাণ (৳)', border: OutlineInputBorder()),
                    onChanged: (val) => amount = double.tryParse(val) ?? 0,
                  ),
                  const SizedBox(height: 8),
                  if (selectedType != TransactionType.transfer) ...[
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'ক্যাটাগরি', border: OutlineInputBorder()),
                      items: (selectedType == TransactionType.income
                              ? ['বেতন', 'ব্যবসা', 'Freelancing', 'Bonus', 'উপহার', 'অন্যান্য']
                              : ['বাজার', 'খাবার', 'বাসা ভাড়া', 'বিদ্যুৎ', 'ইন্টারনেট', 'যাতায়াত', 'অন্যান্য'])
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setModalState(() => category = val!),
                    ),
                    const SizedBox(height: 8),
                  ],
                  DropdownButtonFormField<String>(
                    value: fromAccId,
                    decoration: InputDecoration(
                        labelText: selectedType == TransactionType.transfer ? 'কোথা থেকে (From)' : 'একাউন্ট',
                        border: const OutlineInputBorder()),
                    items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                    onChanged: (val) => setModalState(() => fromAccId = val!),
                  ),
                  if (selectedType == TransactionType.transfer) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: toAccId,
                      decoration: const InputDecoration(labelText: 'কোথায় (To)', border: OutlineInputBorder()),
                      items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                      onChanged: (val) => setModalState(() => toAccId = val!),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(labelText: 'নোট (ঐচ্ছিক)', border: OutlineInputBorder()),
                    onChanged: (val) => note = val,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: const Color(0xFF1565C0),
                    ),
                    onPressed: () {
                      if (amount <= 0) return;
                      _addTransaction(TransactionItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        type: selectedType,
                        amount: amount,
                        category: selectedType == TransactionType.transfer ? 'Transfer' : category,
                        fromAccountId: fromAccId,
                        toAccountId: selectedType == TransactionType.transfer ? toAccId : null,
                        date: DateTime.now(),
                        note: note,
                      ));
                      Navigator.pop(context);
                    },
                    child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
