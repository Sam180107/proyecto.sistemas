import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SearchCubit() : super(SearchInitial()) {
    fetchInitialPublications();
  }

  void fetchInitialPublications() async {
    try {
      emit(SearchLoading());
      final querySnapshot = await _firestore
          .collection('libros')
          .orderBy('fechaCreacion', descending: true)
          .limit(10)
          .get();

      if (isClosed) return;
      emit(SearchLoaded(querySnapshot.docs));
    } on FirebaseException catch (e) {
      if (isClosed) return;
      if (e.code == 'permission-denied') {
        emit(
          const SearchError(
            'Error de permisos. Revisa las reglas de seguridad de Firestore.',
          ),
        );
      } else {
        emit(SearchError('Error de Firestore: ${e.message}'));
      }
    } catch (e) {
      if (isClosed) return;
      emit(SearchError('Failed to load initial publications: ${e.toString()}'));
    }
  }

  void search({
    String? query,
    String? carrera,
    String? materia,
    String? transaccion,
  }) async {
    try {
      emit(SearchLoading());

      Query collectionQuery = _firestore.collection('libros');

      if (carrera != null && carrera.isNotEmpty) {
        collectionQuery = collectionQuery.where('carrera', isEqualTo: carrera);
      }
      if (materia != null && materia.isNotEmpty) {
        collectionQuery = collectionQuery.where('materia', isEqualTo: materia);
      }
      if (transaccion != null &&
          transaccion.isNotEmpty &&
          transaccion != 'Todos') {
        collectionQuery = collectionQuery.where(
          'tipoTransaccion',
          isEqualTo: transaccion,
        );
      }

      final querySnapshot = await collectionQuery.get();
      List<QueryDocumentSnapshot> results = querySnapshot.docs;

      if (query != null && query.isNotEmpty) {
        String searchQuery = query.toLowerCase();
        results = results.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final titulo = (data['titulo'] as String? ?? '').toLowerCase();
          final autor = (data['autor'] as String? ?? '').toLowerCase();

          return titulo.contains(searchQuery) || autor.contains(searchQuery);
        }).toList();
      }

      if (isClosed) return;
      emit(SearchLoaded(results));
    } on FirebaseException catch (e) {
      if (isClosed) return;
      if (e.code == 'permission-denied') {
        emit(
          const SearchError(
            'Error de permisos. Revisa las reglas de seguridad de Firestore.',
          ),
        );
      } else {
        emit(SearchError('Error de Firestore: ${e.message}'));
      }
    } catch (e) {
      if (isClosed) return;
      emit(SearchError('Failed to perform search: ${e.toString()}'));
    }
  }
}
