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
          .limit(100) // Aumentamos el límite para filtrar en memoria
          .get();

      if (isClosed) return;

      // Filtramos en memoria para incluir libros sin el campo 'estado' o con estado 'Pendiente'/'Disponible'
      // Solo excluimos los que explícitamente dicen 'Vendido'
      List<QueryDocumentSnapshot> docs = querySnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['estado'] != 'Vendido';
      }).toList();

      docs.sort((a, b) {
        final dataA = a.data() as Map<String, dynamic>;
        final dataB = b.data() as Map<String, dynamic>;
        final dateA = dataA['fechaCreacion'] as Timestamp?;
        final dateB = dataB['fechaCreacion'] as Timestamp?;

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });

      emit(SearchLoaded(docs));
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
    String? condicion,
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
      if (condicion != null && condicion.isNotEmpty && condicion != 'Todos') {
        collectionQuery = collectionQuery.where('condicion', isEqualTo: condicion);
      }

      final querySnapshot = await collectionQuery.get();
      
      // Filtrar en memoria para asegurar que se incluyan libros antiguos
      List<QueryDocumentSnapshot> results = querySnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['estado'] != 'Vendido';
      }).toList();

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
      emit(SearchLoaded(
        results,
        lastQuery: query,
        lastCarrera: carrera,
        lastMateria: materia,
        lastTransaccion: transaccion,
        lastCondicion: condicion,
      ));
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
