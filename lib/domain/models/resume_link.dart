import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'json_utils.dart';
import 'section_item.dart';

class ResumeLink extends Equatable implements SectionItem {
  const ResumeLink({
    required this.id,
    this.type = LinkType.other,
    this.title = '',
    this.url = '',
  });

  @override
  final String id;

  final LinkType type;
  final String title;
  final String url;

  bool get isEmpty => url.trim().isEmpty;

  ResumeLink copyWith({LinkType? type, String? title, String? url}) {
    return ResumeLink(
      id: id,
      type: type ?? this.type,
      title: title ?? this.title,
      url: url ?? this.url,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type.name,
    'title': title,
    'url': url,
  };

  factory ResumeLink.fromJson(Map<String, dynamic> json) => ResumeLink(
    id: readRequiredString(json, 'id'),
    type: LinkType.fromName(readString(json, 'type')),
    title: readRequiredString(json, 'title'),
    url: readRequiredString(json, 'url'),
  );

  @override
  List<Object?> get props => <Object?>[id, type, title, url];
}
