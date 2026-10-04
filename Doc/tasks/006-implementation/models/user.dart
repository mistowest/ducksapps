/// Modelo de usuário baseado na análise do app (Doc/analysis/04-usuarios.md).
class User {
  final String? id;
  final String? email;
  final String? role;
  final DateTime? createdAt;
  final bool? isDucksPlus;
  final String? duckId;

  const User({
    this.id,
    this.email,
    this.role,
    this.createdAt,
    this.isDucksPlus,
    this.duckId,
  });

  /// Cria um usuário vazio para estados não autenticados
  factory User.empty() => const User(
        id: null,
        email: null,
        role: 'anon',
        createdAt: null,
        isDucksPlus: false,
        duckId: null,
      );

  /// Cria um usuário a partir de um JSON (geralmente da resposta da API)
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String?,
        email: json['email'] as String?,
        role: json['role'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        isDucksPlus: json['is_ducks_plus'] as bool?,
        duckId: json['duck_id'] as String?,
      );

  /// Converte o usuário para um JSON (para armazenamento ou envio)
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        'created_at': createdAt?.toIso8601String(),
        'is_ducks_plus': isDucksPlus,
        'duck_id': duckId,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          role == other.role &&
          createdAt == other.createdAt &&
          isDucksPlus == other.isDucksPlus &&
          duckId == other.duckId;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      role.hashCode ^
      createdAt.hashCode ^
      isDucksPlus.hashCode ^
      duckId.hashCode;

  @override
  String toString() {
    return 'User{id: $id, email: $email, role: $role, createdAt: $createdAt, '
        'isDucksPlus: $isDucksPlus, duckId: $duckId}';
  }
}