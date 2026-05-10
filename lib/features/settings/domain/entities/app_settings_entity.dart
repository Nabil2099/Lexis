class AppSettingsEntity {
  const AppSettingsEntity({
    required this.useMarkdownPreview,
    required this.showWordCount,
    required this.confirmBeforeDelete,
    required this.useTrueBlack,
    required this.defaultSpaceId,
    required this.lastOpenedAt,
    required this.smartAssistEnabled,
    required this.smartAssistAutoTitle,
    required this.smartAssistAutoSummary,
    required this.smartAssistSuggestTags,
    required this.encryptionKeyReady,
    required this.appLockEnabled,
    required this.lockAfterMinutes,
    required this.syncEnabled,
    required this.syncLastSyncedAt,
  });

  factory AppSettingsEntity.defaults() {
    return AppSettingsEntity(
      useMarkdownPreview: false,
      showWordCount: true,
      confirmBeforeDelete: true,
      useTrueBlack: true,
      defaultSpaceId: '',
      lastOpenedAt: DateTime.now(),
      smartAssistEnabled: true,
      smartAssistAutoTitle: true,
      smartAssistAutoSummary: true,
      smartAssistSuggestTags: true,
      encryptionKeyReady: false,
      appLockEnabled: false,
      lockAfterMinutes: 5,
      syncEnabled: false,
      syncLastSyncedAt: null,
    );
  }

  final bool useMarkdownPreview;
  final bool showWordCount;
  final bool confirmBeforeDelete;
  final bool useTrueBlack;
  final String defaultSpaceId;
  final DateTime lastOpenedAt;
  final bool smartAssistEnabled;
  final bool smartAssistAutoTitle;
  final bool smartAssistAutoSummary;
  final bool smartAssistSuggestTags;
  final bool encryptionKeyReady;
  final bool appLockEnabled;
  final int lockAfterMinutes;
  final bool syncEnabled;
  final DateTime? syncLastSyncedAt;

  AppSettingsEntity copyWith({
    bool? useMarkdownPreview,
    bool? showWordCount,
    bool? confirmBeforeDelete,
    bool? useTrueBlack,
    String? defaultSpaceId,
    DateTime? lastOpenedAt,
    bool? smartAssistEnabled,
    bool? smartAssistAutoTitle,
    bool? smartAssistAutoSummary,
    bool? smartAssistSuggestTags,
    bool? encryptionKeyReady,
    bool? appLockEnabled,
    int? lockAfterMinutes,
    bool? syncEnabled,
    Object? syncLastSyncedAt = _sentinel,
  }) {
    return AppSettingsEntity(
      useMarkdownPreview: useMarkdownPreview ?? this.useMarkdownPreview,
      showWordCount: showWordCount ?? this.showWordCount,
      confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
      useTrueBlack: useTrueBlack ?? this.useTrueBlack,
      defaultSpaceId: defaultSpaceId ?? this.defaultSpaceId,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      smartAssistEnabled: smartAssistEnabled ?? this.smartAssistEnabled,
      smartAssistAutoTitle: smartAssistAutoTitle ?? this.smartAssistAutoTitle,
      smartAssistAutoSummary:
          smartAssistAutoSummary ?? this.smartAssistAutoSummary,
      smartAssistSuggestTags:
          smartAssistSuggestTags ?? this.smartAssistSuggestTags,
      encryptionKeyReady: encryptionKeyReady ?? this.encryptionKeyReady,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      lockAfterMinutes: lockAfterMinutes ?? this.lockAfterMinutes,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      syncLastSyncedAt: syncLastSyncedAt == _sentinel
          ? this.syncLastSyncedAt
          : syncLastSyncedAt as DateTime?,
    );
  }
}

const Object _sentinel = Object();
