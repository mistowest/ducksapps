/// Abstração de armazenamento seguro para tokens e dados do usuário
abstract class SecureStorage {
  /// Lê um valor armazenado pela [key]
  Future<String?> read(String key);

  /// Escreve um valor associado à [key]
  Future<void> write(String key, String value);

  /// Remove o valor associado à [key]
  Future<void> delete(String key);

  /// Remove todos os valores armazenados
  Future<void> clear();
}