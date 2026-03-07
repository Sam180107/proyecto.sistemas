import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  // In a real app, you would inject a repository here to fetch data from Firebase
  // final YourRepository _repository;

  void search({
    String? query,
    String? carrera,
    String? materia,
    String? transaccion,
  }) async {
    try {
      emit(SearchLoading());
      // Here you would perform the query to Firebase Firestore
      // For example:
      // final results = await _repository.searchBooks(
      //   query: query,
      //   carrera: carrera,
      //   materia: materia,
      //   transaccion: transaccion,
      // );
      // emit(SearchLoaded(results));

      // For now, we'll just simulate a delay and an empty result
      await Future.delayed(const Duration(seconds: 1));
      emit(const SearchLoaded([])); // Assuming empty list for now

    } catch (e) {
      emit(SearchError('Failed to perform search: ${e.toString()}'));
    }
  }
}
