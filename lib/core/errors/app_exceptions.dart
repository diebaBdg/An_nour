sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'Erreur de connexion réseau']);
}

final class PermissionException extends AppException {
  const PermissionException([super.message = 'Permission refusée']);
}

final class LocationException extends AppException {
  const LocationException([super.message = 'Impossible d\'obtenir la localisation']);
}

final class StorageException extends AppException {
  const StorageException([super.message = 'Erreur de stockage local']);
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Ressource introuvable']);
}
