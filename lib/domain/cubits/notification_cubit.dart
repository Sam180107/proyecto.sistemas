import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notification_repository.dart';

// --- State ---
class NotificationState {
  final List<Map<String, dynamic>> unreadReports;
  final List<Map<String, dynamic>> pendingOrders;
  final bool isLoading;

  const NotificationState({
    this.unreadReports = const [],
    this.pendingOrders = const [],
    this.isLoading = false,
  });

  int get totalUnread => unreadReports.length + pendingOrders.length;

  NotificationState copyWith({
    List<Map<String, dynamic>>? unreadReports,
    List<Map<String, dynamic>>? pendingOrders,
    bool? isLoading,
  }) {
    return NotificationState(
      unreadReports: unreadReports ?? this.unreadReports,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// --- Cubit ---
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;
  StreamSubscription? _reportsSub;
  StreamSubscription? _ordersSub;

  NotificationCubit({NotificationRepository? repository})
    : _repository = repository ?? NotificationRepository(),
      super(const NotificationState()) {
    _listen();
  }

  void _listen() {
    print("NotificationCubit: Initializing listeners...");
    _reportsSub = _repository.unreadReportsStream().listen(
      (reports) {
        print("NotificationCubit: Received ${reports.length} reports");
        if (!isClosed) emit(state.copyWith(unreadReports: reports));
      },
      onError: (error) {
        print("NotificationCubit: Error in reports stream: $error");
        // Additional error handling for reports stream if needed
      },
    );
    _ordersSub = _repository.newSellerOrdersStream().listen(
      (orders) {
        print("NotificationCubit: Received ${orders.length} orders");
        if (!isClosed) emit(state.copyWith(pendingOrders: orders));
      },
      onError: (error) {
        print("NotificationCubit: Error in orders stream: $error");
        // Additional error handling for orders stream if needed
      },
    );
  }

  Future<void> markReportAsRead(String reportId) async {
    await _repository.markReportAsRead(reportId);
  }

  @override
  Future<void> close() {
    _reportsSub?.cancel();
    _ordersSub?.cancel();
    return super.close();
  }
}
