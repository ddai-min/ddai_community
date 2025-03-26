import 'package:cloud_firestore/cloud_firestore.dart';

class PaginationModel<T> {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;

  PaginationModel({
    required this.items,
    this.isLoading = false,
    this.hasMore = true,
    this.lastDocument,
  });

  PaginationModel<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? hasMore,
    DocumentSnapshot? lastDocument,
  }) {
    return PaginationModel<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }
}
