class AppSettingsEntity {
  const AppSettingsEntity({
    required this.useMarkdownPreview,
    required this.showWordCount,
    required this.confirmBeforeDelete,
    required this.useTrueBlack,
    required this.defaultSpaceId,
    required this.lastOpenedAt,
  });

  factory AppSettingsEntity.defaults() {
    return AppSettingsEntity(
      useMarkdownPreview: false,
      showWordCount: true,
      confirmBeforeDelete: true,
      useTrueBlack: true,
      defaultSpaceId: '',
      lastOpenedAt: DateTime.now(),
    );
  }

  final bool useMarkdownPreview;
  final bool showWordCount;
  final bool confirmBeforeDelete;
  final bool useTrueBlack;
  final String defaultSpaceId;
  final DateTime lastOpenedAt;

  AppSettingsEntity copyWith({
    bool? useMarkdownPreview,
    bool? showWordCount,
    bool? confirmBeforeDelete,
    bool? useTrueBlack,
    String? defaultSpaceId,
    DateTime? lastOpenedAt,
  }) {
    return AppSettingsEntity(
      useMarkdownPreview: useMarkdownPreview ?? this.useMarkdownPreview,
      showWordCount: showWordCount ?? this.showWordCount,
      confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
      useTrueBlack: useTrueBlack ?? this.useTrueBlack,
      defaultSpaceId: defaultSpaceId ?? this.defaultSpaceId,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }
}
