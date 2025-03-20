import 'package:flutter/material.dart';
import 'package:my_finance/core/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _amountController = TextEditingController();
  final _newCategoryController = TextEditingController();
  final _incomeController = TextEditingController();

  bool _showIncomeField = false;
  String? _selectedCategory;
  List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Transport', 'icon': Icons.directions_car},
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Bills', 'icon': Icons.receipt},
    {'name': 'Entertainment', 'icon': Icons.movie},
    {'name': 'Health', 'icon': Icons.medical_services},
  ];

  List<Map<String, dynamic>> _recentExpenses = [];

  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  bool _loadingExpenses = true;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories[0]['name'] as String;
    _fetchCustomCategories();
    _fetchRecentExpenses();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _newCategoryController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _fetchCustomCategories() async {
    try {
      final response = await _supabase
          .from('custom_categories')
          .select()
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        final customCategories = response
            .map<Map<String, dynamic>>((item) => {
                  'name': item['name'],
                  'icon': Icons.category, // Default icon for custom categories
                })
            .toList();

        setState(() {
          _categories = [..._categories, ...customCategories];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load custom categories: $e')),
      );
    }
  }

  Future<void> _fetchRecentExpenses() async {
    setState(() {
      _loadingExpenses = true;
    });

    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .order('date', ascending: false)
          .limit(5);

      setState(() {
        _recentExpenses = List<Map<String, dynamic>>.from(response);
        _loadingExpenses = false;
      });
    } catch (e) {
      setState(() {
        _loadingExpenses = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load recent expenses: $e')),
      );
    }
  }

  Future<void> _addNewCategory() async {
    if (_newCategoryController.text.trim().isEmpty) return;

    final newCategory = {
      'name': _newCategoryController.text.trim(),
      'icon': Icons.category,
    };

    try {
      // Add to Supabase
      await _supabase.from('custom_categories').insert({
        'name': newCategory['name'],
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update UI
      setState(() {
        _categories.add(newCategory);
        _selectedCategory = newCategory['name'] as String;
      });

      _newCategoryController.clear();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom category added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add category: $e')),
      );
    }
  }

  Future<void> _addMonthlyIncome() async {
    if (_incomeController.text.trim().isEmpty) return;

    try {
      final amount = double.parse(_incomeController.text.trim());

      // Add to Supabase
      await _supabase.from('monthly_income').insert({
        'amount': amount,
        'month': DateFormat('MMMM yyyy').format(DateTime.now()),
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monthly income added successfully!')),
      );

      setState(() {
        _showIncomeField = false;
        _incomeController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add income: $e')),
      );
    }
  }

  Future<void> _addExpense() async {
    if (_amountController.text.trim().isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter an amount and select a category')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text.trim());
      final now = DateTime.now();

      // Add to Supabase
      await _supabase.from('expenses').insert({
        'amount': amount,
        'category': _selectedCategory,
        'date': now.toIso8601String(),
      });

      // Add the new expense to the local list
      final newExpense = {
        'amount': amount,
        'category': _selectedCategory,
        'date': now.toIso8601String(),
      };

      setState(() {
        _recentExpenses.insert(0, newExpense);
        if (_recentExpenses.length > 5) {
          _recentExpenses.removeLast();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully!')),
      );

      // Clear the form
      _amountController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add expense: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: _newCategoryController,
          decoration: const InputDecoration(
            hintText: 'Category name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addNewCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Add Expenses',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
            onPressed: () {
              setState(() {
                _showIncomeField = !_showIncomeField;
              });
            },
            tooltip: 'Add Monthly Income',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              if (_showIncomeField) _buildIncomeInput(),
              if (_showIncomeField) const SizedBox(height: 20),
              _buildAmountInput(),
              const SizedBox(height: 20),
              _buildExpenseCategorySelector(),
              const SizedBox(height: 30),
              _buildAddExpenseButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enter monthly income',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()),
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _incomeController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '₹ 50000',
              hintStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addMonthlyIncome,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Income',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enter expense amount',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '₹ 1000',
              hintStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCategorySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _showAddCategoryDialog,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: primaryColor,
                  size: 16,
                ),
                label: Text(
                  'Add New',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Fixed height container for categories
          SizedBox(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category['name'] == _selectedCategory;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected ? primaryColor.withOpacity(0.1) : null,
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['name'] as String;
                      });
                    },
                    leading: Icon(
                      category['icon'] as IconData,
                      color: isSelected ? primaryColor : Colors.grey,
                    ),
                    title: Text(
                      category['name'] as String,
                      style: TextStyle(
                        color: isSelected ? primaryColor : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: primaryColor)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddExpenseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _addExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Add Expense',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
