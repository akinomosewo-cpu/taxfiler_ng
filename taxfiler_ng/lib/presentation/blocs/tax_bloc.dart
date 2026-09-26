import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/tax_entities.dart';
import '../../domain/usecases/tax_calculator.dart';

// Events
abstract class TaxEvent extends Equatable {
  const TaxEvent();
  @override
  List<Object?> get props => [];
}

class TaxInitialized extends TaxEvent { const TaxInitialized(); }
class TaxYearChanged extends TaxEvent {
  final TaxYear year;
  const TaxYearChanged(this.year);
  @override List<Object?> get props => [year];
}
class IncomeAdded extends TaxEvent {
  final IncomeEntry entry;
  const IncomeAdded(this.entry);
  @override List<Object?> get props => [entry];
}
class IncomeDeleted extends TaxEvent {
  final String id;
  const IncomeDeleted(this.id);
  @override List<Object?> get props => [id];
}
class ExpenseAdded extends TaxEvent {
  final ExpenseEntry entry;
  const ExpenseAdded(this.entry);
  @override List<Object?> get props => [entry];
}
class ExpenseDeleted extends TaxEvent {
  final String id;
  const ExpenseDeleted(this.id);
  @override List<Object?> get props => [id];
}
class TaxCalculated extends TaxEvent { const TaxCalculated(); }
class DeductionToggled extends TaxEvent {
  final String key;
  final bool value;
  const DeductionToggled(this.key, this.value);
  @override List<Object?> get props => [key, value];
}

// States
abstract class TaxState extends Equatable {
  const TaxState();
  @override List<Object?> get props => [];
}

class TaxInitial extends TaxState { const TaxInitial(); }
class TaxLoading extends TaxState { const TaxLoading(); }

class TaxLoaded extends TaxState {
  final TaxYear selectedYear;
  final List<IncomeEntry> incomes;
  final List<ExpenseEntry> expenses;
  final TaxAssessment? assessment;
  final bool hasPension;
  final bool hasNhf;
  final bool hasNhi;

  const TaxLoaded({
    required this.selectedYear,
    required this.incomes,
    required this.expenses,
    this.assessment,
    required this.hasPension,
    required this.hasNhf,
    required this.hasNhi,
  });

  double get totalIncome => incomes.fold(0.0, (s, e) => s + e.amountNgn);
  double get totalExpenses => expenses.fold(0.0, (s, e) => s + e.amount);

  TaxLoaded copyWith({
    TaxYear? selectedYear,
    List<IncomeEntry>? incomes,
    List<ExpenseEntry>? expenses,
    TaxAssessment? assessment,
    bool clearAssessment = false,
    bool? hasPension,
    bool? hasNhf,
    bool? hasNhi,
  }) => TaxLoaded(
    selectedYear: selectedYear ?? this.selectedYear,
    incomes: incomes ?? this.incomes,
    expenses: expenses ?? this.expenses,
    assessment: clearAssessment ? null : (assessment ?? this.assessment),
    hasPension: hasPension ?? this.hasPension,
    hasNhf: hasNhf ?? this.hasNhf,
    hasNhi: hasNhi ?? this.hasNhi,
  );

  @override
  List<Object?> get props => [selectedYear, incomes, expenses, assessment, hasPension, hasNhf, hasNhi];
}

// BLoC
class TaxBloc extends Bloc<TaxEvent, TaxState> {
  TaxBloc() : super(const TaxInitial()) {
    on<TaxInitialized>(_onInit);
    on<TaxYearChanged>(_onYearChanged);
    on<IncomeAdded>(_onIncomeAdded);
    on<IncomeDeleted>(_onIncomeDeleted);
    on<ExpenseAdded>(_onExpenseAdded);
    on<ExpenseDeleted>(_onExpenseDeleted);
    on<TaxCalculated>(_onCalculated);
    on<DeductionToggled>(_onDeductionToggled);
  }

  void _onInit(TaxInitialized e, Emitter<TaxState> emit) {
    emit(const TaxLoaded(
      selectedYear: TaxYear.y2025,
      incomes: [],
      expenses: [],
      hasPension: false,
      hasNhf: false,
      hasNhi: false,
    ));
  }

  void _onYearChanged(TaxYearChanged e, Emitter<TaxState> emit) {
    if (state is TaxLoaded) {
      emit((state as TaxLoaded).copyWith(selectedYear: e.year, incomes: [], expenses: [], clearAssessment: true));
    }
  }

  void _onIncomeAdded(IncomeAdded e, Emitter<TaxState> emit) {
    if (state is TaxLoaded) {
      final s = state as TaxLoaded;
      emit(s.copyWith(incomes: [...s.incomes, e.entry], clearAssessment: true));
    }
  }

  void _onIncomeDeleted(IncomeDeleted e, Emitter<TaxState> emit) {
    if (state is TaxLoaded) {
      final s = state as TaxLoaded;
      emit(s.copyWith(incomes: s.incomes.where((i) => i.id != e.id).toList(), clearAssessment: true));
    }
  }

  void _onExpenseAdded(ExpenseAdded e, Emitter<TaxState> emit) {
    if (state is TaxLoaded) {
      final s = state as TaxLoaded;
      emit(s.copyWith(expenses: [...s.expenses, e.entry], clearAssessment: true));
    }
  }

  void _onExpenseDeleted(ExpenseDeleted e, Emitter<TaxState> emit) {
    if (state is TaxLoaded) {
      final s = state as TaxLoaded;
      emit(s.copyWith(expenses: s.expenses.where((i) => i.id != e.id).toList(), clearAssessment: true));
    }
  }

  void _onCalculated(TaxCalculated e, Emitter<TaxState> emit) {
    if (state is TaxLoaded) {
      final s = state as TaxLoaded;
      final assessment = TaxCalculator.calculate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        year: s.selectedYear,
        incomes: s.incomes,
        expenses: s.expenses,
        hasPension: s.hasPension,
        hasNhf: s.hasNhf,
        hasNhi: s.hasNhi,
      );
      emit(s.copyWith(assessment: assessment));
    }
  }

  void _onDeductionToggled(DeductionToggled e, Emitter<TaxState> emit) {
    if (state is TaxLoaded) {
      final s = state as TaxLoaded;
      emit(s.copyWith(
        hasPension: e.key == 'pension' ? e.value : s.hasPension,
        hasNhf: e.key == 'nhf' ? e.value : s.hasNhf,
        hasNhi: e.key == 'nhi' ? e.value : s.hasNhi,
        clearAssessment: true,
      ));
    }
  }
}
