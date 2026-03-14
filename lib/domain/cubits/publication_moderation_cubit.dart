import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/publication_moderation_repository.dart';

abstract class PublicationModerationState {}

class PublicationModerationInitial extends PublicationModerationState {}

class PublicationModerationLoading extends PublicationModerationState {}

class PublicationModerationSuccess extends PublicationModerationState {
  final String message;
  PublicationModerationSuccess(this.message);
}

class PublicationModerationError extends PublicationModerationState {
  final String error;
  PublicationModerationError(this.error);
}

class PublicationModerationCubit extends Cubit<PublicationModerationState> {
  final PublicationModerationRepository _repository;

  PublicationModerationCubit({PublicationModerationRepository? repository})
    : _repository = repository ?? PublicationModerationRepository(),
      super(PublicationModerationInitial());

  Future<void> freezePublication(String docId, bool freeze) async {
    emit(PublicationModerationLoading());
    try {
      await _repository.freezePublication(docId, freeze);
      emit(
        PublicationModerationSuccess(
          freeze ? 'Publicación congelada.' : 'Publicación reactivada.',
        ),
      );
    } catch (e) {
      emit(PublicationModerationError('Error al congelar: $e'));
    }
  }

  Future<void> reportPublication({
    required String docId,
    required String userId,
    required String titulo,
    required String mensaje,
  }) async {
    emit(PublicationModerationLoading());
    try {
      print(
        "PublicationModerationCubit: Sending report to userId: $userId for book: $titulo",
      );
      await _repository.reportPublication(
        docId: docId,
        userId: userId,
        titulo: titulo,
        mensaje: mensaje,
      );
      emit(PublicationModerationSuccess('Reporte enviado al vendedor.'));
    } catch (e) {
      emit(PublicationModerationError('Error al enviar reporte: $e'));
    }
  }

  Future<void> eliminarPublicacion(String docId) async {
    emit(PublicationModerationLoading());
    try {
      await _repository.deletePublication(docId);
      emit(PublicationModerationSuccess('Publicación eliminada.'));
    } catch (e) {
      emit(PublicationModerationError('Error al eliminar: $e'));
    }
  }
}
