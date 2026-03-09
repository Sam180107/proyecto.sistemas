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
      // Simply get all books first
      final querySnapshot = await _firestore.collection('libros').get();

      if (isClosed) return;

      // Filter in memory to avoid index issues
      final allDocs = querySnapshot.docs;
      
      final filteredDocs = allDocs.where((doc) {
        final data = doc.data();
        // Check for 'estado' field, default to 'Disponible' if missing
        final estado = data['estado'] as String? ?? 'Disponible';
        return estado != 'Vendido' && estado != 'Eliminado';
      }).toList();

      // Sort by creation date in memory
      filteredDocs.sort((a, b) {
        final dataA = a.data();
        final dataB = b.data();
        // Handle potential missing or different type for fechaCreacion
        Timestamp? dateA; 
        if (dataA['fechaCreacion'] is Timestamp) {
            dateA = dataA['fechaCreacion'];
        }
        Timestamp? dateB;
        if (dataB['fechaCreacion'] is Timestamp) {
            dateB = dataB['fechaCreacion'];
        }

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1; // Null dates go last
        if (dateB == null) return -1;
        return dateB.compareTo(dateA); // Descending order
      });

      emit(SearchLoaded(filteredDocs));
    } catch (e) {
      if (!isClosed) {
        emit(SearchError('Error al cargar publicaciones: $e'));
      }
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
      
      // Filter in memory to avoid index issues
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
