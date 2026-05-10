import '../../../notes/domain/entities/note_entity.dart';

class SearchFilterEntity {
  const SearchFilterEntity({
    this.query = '',
    this.type,
    this.tagId,
    this.spaceId,
    this.pinnedOnly = false,
    this.includeArchived = false,
    this.includeDeleted = false,
  });

  final String query;
  final NoteType? type;
  final String? tagId;
  final String? spaceId;
  final bool pinnedOnly;
  final bool includeArchived;
  final bool includeDeleted;

  SearchFilterEntity copyWith({
    String? query,
    Object? type = _sentinel,
    Object? tagId = _sentinel,
    Object? spaceId = _sentinel,
    bool? pinnedOnly,
    bool? includeArchived,
    bool? includeDeleted,
  }) {
    return SearchFilterEntity(
      query: query ?? this.query,
      type: type == _sentinel ? this.type : type as NoteType?,
      tagId: tagId == _sentinel ? this.tagId : tagId as String?,
      spaceId: spaceId == _sentinel ? this.spaceId : spaceId as String?,
      pinnedOnly: pinnedOnly ?? this.pinnedOnly,
      includeArchived: includeArchived ?? this.includeArchived,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }
}

const Object _sentinel = Object();
