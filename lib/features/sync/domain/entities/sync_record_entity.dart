class SyncRecordEntity {
  const SyncRecordEntity({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.createdAt,
    this.syncedAt,
  });

  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final DateTime createdAt;
  final DateTime? syncedAt;
}
