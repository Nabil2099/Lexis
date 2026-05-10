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
    );
  }
}
