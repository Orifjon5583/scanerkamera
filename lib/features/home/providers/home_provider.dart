import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan_ai/models/document_model.dart';
import 'package:smartscan_ai/services/document_service.dart';
import 'package:smartscan_ai/repositories/folder_repository.dart';
import 'package:smartscan_ai/models/folder_model.dart';

/// Provider for the document service instance.
final documentServiceProvider = Provider<DocumentService>((ref) {
  return DocumentService();
});

/// Provider for the folder repository instance.
final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepository();
});

/// Provider for all documents list.
final documentsProvider = FutureProvider<List<DocumentModel>>((ref) async {
  final service = ref.read(documentServiceProvider);
  return service.getAllDocuments();
});

/// Provider for recent documents.
final recentDocumentsProvider = FutureProvider<List<DocumentModel>>((ref) async {
  final service = ref.read(documentServiceProvider);
  return service.getRecentDocuments(limit: 10);
});

/// Provider for favorite documents.
final favoriteDocumentsProvider = FutureProvider<List<DocumentModel>>((ref) async {
  final service = ref.read(documentServiceProvider);
  return service.getFavoriteDocuments();
});

/// Provider for folders.
final foldersProvider = FutureProvider<List<FolderModel>>((ref) async {
  final repo = ref.read(folderRepositoryProvider);
  return repo.getAllFolders();
});

/// Provider for search results.
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<DocumentModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  final service = ref.read(documentServiceProvider);
  return service.searchDocuments(query);
});

/// Provider for view mode (grid or list).
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.grid);

/// Provider for selected category filter.
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// View modes for document list.
enum ViewMode { grid, list }

/// Home screen state notifier for managing complex state.
class HomeNotifier extends StateNotifier<HomeState> {
  final DocumentService _documentService;
  final FolderRepository _folderRepository;

  HomeNotifier(this._documentService, this._folderRepository)
      : super(const HomeState()) {
    loadData();
  }

  /// Loads all home screen data.
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);

    try {
      final documents = await _documentService.getAllDocuments();
      final recentDocs = await _documentService.getRecentDocuments(limit: 10);
      final favorites = await _documentService.getFavoriteDocuments();
      final folders = await _folderRepository.getAllFolders();

      state = state.copyWith(
        isLoading: false,
        documents: documents,
        recentDocuments: recentDocs,
        favoriteDocuments: favorites,
        folders: folders,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refreshes the document list.
  Future<void> refresh() async {
    await loadData();
  }

  /// Deletes a document.
  Future<void> deleteDocument(String documentId) async {
    await _documentService.deleteDocument(documentId);
    await loadData();
  }

  /// Toggles document favorite status.
  Future<void> toggleFavorite(String documentId) async {
    await _documentService.toggleFavorite(documentId);
    await loadData();
  }

  /// Searches documents.
  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }
    final results = await _documentService.searchDocuments(query);
    state = state.copyWith(searchResults: results);
  }
}

/// Provider for the home notifier.
final homeNotifierProvider =
    StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final documentService = ref.read(documentServiceProvider);
  final folderRepo = ref.read(folderRepositoryProvider);
  return HomeNotifier(documentService, folderRepo);
});

/// State class for the home screen.
class HomeState {
  final bool isLoading;
  final List<DocumentModel> documents;
  final List<DocumentModel> recentDocuments;
  final List<DocumentModel> favoriteDocuments;
  final List<DocumentModel> searchResults;
  final List<FolderModel> folders;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.documents = const [],
    this.recentDocuments = const [],
    this.favoriteDocuments = const [],
    this.searchResults = const [],
    this.folders = const [],
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    List<DocumentModel>? documents,
    List<DocumentModel>? recentDocuments,
    List<DocumentModel>? favoriteDocuments,
    List<DocumentModel>? searchResults,
    List<FolderModel>? folders,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      documents: documents ?? this.documents,
      recentDocuments: recentDocuments ?? this.recentDocuments,
      favoriteDocuments: favoriteDocuments ?? this.favoriteDocuments,
      searchResults: searchResults ?? this.searchResults,
      folders: folders ?? this.folders,
      error: error,
    );
  }
}
