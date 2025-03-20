// ignore_for_file: deprecated_member_use

import 'package:my_finance/core/utils/constants.dart';
import 'package:my_finance/export.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_finance/features/home/presentation/providers/home_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override

  /// Returns a Scaffold with a colored background and an AppBar with a title, search button and notification button.
  ///
  /// The body of the Scaffold is a Consumer that listens to the HomeProvider and displays either a loading indicator or
  /// the dashboard view depending on the state of the provider.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: const Text(
          'MyFinance',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildDashboardView(context, provider);
        },
      ),
    );
  }

  /// Builds the dashboard view of the HomeScreen.
  ///
  /// This widget contains the following components:
  /// - A RefreshIndicator that triggers data loading when pulled down.
  /// - A SingleChildScrollView with padding for scrolling the content.
  /// - A Column that includes:
  ///   - A balance card displaying financial summary.
  ///   - An income and expense chart.
  ///   - A spending overview section.
  ///   - A section for recent transactions with a header and transaction list.
  ///
  /// The function takes a [BuildContext] and a [HomeProvider] as parameters
  /// to manage and display the necessary data.

  Widget _buildDashboardView(BuildContext context, HomeProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(provider),
            const SizedBox(height: 20),
            _buildIncomeExpenseChart(provider),
            const SizedBox(height: 20),
            _buildSpendingOverview(provider),
            const SizedBox(height: 20),
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildRecentTransactions(provider),
          ],
        ),
      ),
    );
  }

  /// Builds a Container widget that displays a monthly financial summary.
  ///
  /// The card is divided into three sections:
  /// 1. Income section
  /// 2. Expenses section
  /// 3. Net Balance section
  ///
  /// Each section is represented by a Row widget with two children:
  /// - A Text widget with the category name
  /// - A Text widget with the value
  ///   - For income and expenses, a positive value is shown in green,
  ///     and a negative value is shown in red.
  ///   - For net balance, a positive value is shown in green,
  ///     and a negative value is shown in red.
  ///     The font size is 20 and the fontWeight is FontWeight.w600.
  ///
  /// The card is wrapped in a Container with white background, rounded
  /// corners and a shadow effect.
  Widget _buildBalanceCard(HomeProvider provider) {
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Summary',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Income row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Income',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                currencyFormat.format(provider.monthlyIncome),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Expenses row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expenses',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                currencyFormat.format(provider.monthlyExpenses),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),

          // Divider
          Divider(thickness: 1, color: Colors.grey[200]),
          const SizedBox(height: 12),

          // Net Balance row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Net Balance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                currencyFormat.format(provider.netBalance),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: provider.netBalance >= 0
                      ? Colors.green[700]
                      : Colors.red[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a widget that displays a bar chart comparing monthly income and
  /// expenses. It uses data from the provided [HomeProvider] to generate
  /// the chart, setting the maximum Y-axis value based on the highest income
  /// or expense value multiplied by 1.2 to ensure proper data display. The
  /// chart includes titles for each month on the X-axis and currency formatted
  /// values on the Y-axis. Additionally, it includes a legend to differentiate
  /// between income and expenses.

  Widget _buildIncomeExpenseChart(HomeProvider provider) {
    // Fix to ensure proper data display in the chart
    final monthlyData = provider.monthlyData;
    final maxValue = monthlyData.isEmpty
        ? 10000.0
        : [
              monthlyData.map((d) => d.income).reduce((a, b) => a > b ? a : b),
              monthlyData
                  .map((d) => d.expenses)
                  .reduce((a, b) => a > b ? a : b),
            ].reduce((a, b) => a > b ? a : b) *
            1.2;

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
          const Text(
            'Income vs Expenses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < monthlyData.length) {
                          return SideTitleWidget(
                            angle: 0,
                            meta: meta,
                            child: Text(
                              monthlyData[value.toInt()].month,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return SideTitleWidget(
                          angle: 0,
                          meta: meta,
                          child: const Text(''),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        if (value % 2000 == 0) {
                          text = currencyFormat.format(value).split('.')[0];
                        }
                        return SideTitleWidget(
                          angle: 0,
                          meta: meta,
                          child: Text(
                            text,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                groupsSpace: 16,
                barGroups: List.generate(
                  monthlyData.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: monthlyData[index].income,
                        color: primaryColor,
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                      BarChartRodData(
                        toY: monthlyData[index].expenses,
                        color: Colors.red,
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegendItem('Income', primaryColor),
              const SizedBox(width: 20),
              _buildChartLegendItem('Expenses', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns a widget that displays a color indicator and a label side by side.
  ///
  /// This is used in the chart legend to display a color and a label for each type of data.
  ///
  /// The color is displayed as a circle with the given color and a size of 12.
  /// The label is displayed as a text widget with the given label and a style with a font size of 12
  /// and a font weight of 500.
  ///
  /// A 4 pixel wide SizedBox is used to separate the color indicator and the label.
  Widget _buildChartLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Builds a spending overview widget with a pie chart and a list of categories.
  ///
  /// The pie chart is divided into sections based on the top 5 categories by amount,
  /// or fewer if there are less than 5 categories. A section is added for any remaining
  /// amount, and is given a grey color.
  ///
  /// The list of categories is shown to the right of the pie chart, with a color indicator
  /// and a label for each category. The label includes the category name and the percentage
  /// of the total amount it represents.
  ///
  /// If there are no categories, a message is shown instead of the list.
  Widget _buildSpendingOverview(HomeProvider provider) {
    // Convert the expense map to a list of entries sorted by amount
    final categoryData = provider.expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 5 categories or fewer if there are less than 5
    final topCategories = categoryData.take(5).toList();

    // Calculate total for percentage calculation
    final totalAmount =
        topCategories.fold(0.0, (sum, item) => sum + item.value);

    // Map categories to pie chart sections
    final sections = [
      for (int i = 0; i < topCategories.length; i++)
        PieChartSectionData(
          value: topCategories[i].value,
          color: _getCategoryColor(i),
          radius: 20,
          title: '',
        ),
    ];

    // If we have fewer than 5 categories, add empty section
    if (sections.isEmpty) {
      sections.add(
        PieChartSectionData(
          value: 1,
          color: Colors.grey.shade300,
          radius: 20,
          title: '',
        ),
      );
    }

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
          const Text(
            'Spending Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 60,
                      sections: sections,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < topCategories.length; i++) ...[
                      _buildCategoryIndicator(
                        topCategories[i].key,
                        _getCategoryColor(i),
                        totalAmount > 0
                            ? '${(topCategories[i].value / totalAmount * 100).toStringAsFixed(0)}%'
                            : '0%',
                      ),
                      const SizedBox(height: 8),
                    ],
                    // If there are no categories, show a message
                    if (topCategories.isEmpty)
                      const Text(
                        'No expense data',
                        style: TextStyle(fontSize: 10),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns a color from a predefined list of colors based on the given index.
  ///
  /// The function cycles through the color list using the modulo operation
  /// to ensure that the index provided always maps to a valid color.
  ///
  /// - Parameter index: The index for which a color needs to be retrieved.
  /// - Returns: A `Color` object from the predefined color list.

  Color _getCategoryColor(int index) {
    final colors = [
      primaryColor,
      accentColor,
      Colors.orange,
      Colors.indigo,
      Colors.red,
    ];

    return colors[index % colors.length];
  }

  /// Returns a Row widget that displays a color indicator, a label and a percentage.
  ///
  /// The color indicator is a circle of the given color.
  /// The label is the given text and is displayed in a Text widget with a fontSize of 10.
  /// The percentage is displayed in a Text widget with a fontSize of 10 and a fontWeight of bold.
  /// The label and the percentage are displayed side by side.
  /// The color indicator is displayed to the left of the label and percentage.
  ///
  /// - Parameter label: The label to be displayed
  /// - Parameter color: The color of the indicator
  /// - Parameter percentage: The percentage to be displayed
  /// - Returns: A Row widget with the given children
  Widget _buildCategoryIndicator(String label, Color color, String percentage) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Builds a widget that displays a list of recent transactions.
  ///
  /// If there are no recent transactions, a message is shown instead.
  ///
  /// The widget includes a container with a white background, rounded corners, and a shadow.
  /// For each transaction, a list tile is displayed with the following:
  /// - An icon indicating whether the transaction is an expense or income.
  /// - The transaction name and category.
  /// - The transaction amount, with a color indicating expense (red) or income (primary color).
  /// - The transaction date.
  ///
  /// - Parameter provider: The HomeProvider instance that provides the recent transactions data.
  /// - Returns: A widget displaying the recent transactions or a message if none exist.

  Widget _buildRecentTransactions(HomeProvider provider) {
    final recentTransactions = provider.recentTransactions;

    // If no transactions, show a message
    if (recentTransactions.isEmpty) {
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
        child: Center(
          child: Text(
            'No recent transactions',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Container(
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
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: recentTransactions.length,
        itemBuilder: (context, index) {
          final transaction = recentTransactions[index];
          final isExpense = transaction.amount < 0;

          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isExpense
                    ? Colors.red.withOpacity(0.1)
                    : primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                color: isExpense ? Colors.red : primaryColor,
                size: 20,
              ),
            ),
            title: Text(
              transaction.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              transaction.category,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(transaction.amount),
                  style: TextStyle(
                    color: isExpense ? Colors.red : primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  transaction.date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
