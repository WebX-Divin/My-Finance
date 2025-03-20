import 'package:my_finance/features/home/domain/entities/monthly_data.dart';
import 'package:my_finance/features/home/domain/repository/home_repository.dart';

class GetMonthlyData {
  final HomeRepository repository;

  GetMonthlyData(this.repository);

  Future<List<MonthlyData>> execute() async {
    return await repository.getMonthlyData();
  }
}
