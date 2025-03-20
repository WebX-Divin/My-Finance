import 'package:my_finance/features/home/domain/repository/home_repository.dart';

class GetMonthlyIncome {
  final HomeRepository repository;

  GetMonthlyIncome(this.repository);

  Future<double> execute() async {
    return await repository.getMonthlyIncome();
  }

  Stream<double> stream() {
    return repository.streamMonthlyIncome();
  }
}
