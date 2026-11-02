// import 'package:flutter/foundation.dart';
// import 'package:uuid/uuid.dart';
//
// import '../feature/todo/data/models/todo_model.dart';
// import '../feature/todo/data/repositories/todo_repository.dart';
//
// enum TodoFilter { all, active, completed }
//
// class TodoProvider extends ChangeNotifier {
//   final TodoRepository _repository;
//   final Uuid _uuid = const Uuid();
//
//   TodoProvider(this._repository);
//
//   List<TodoModel> _todos = [];
//   TodoFilter _filter = TodoFilter.all;
//   String _searchQuery = '';
//   bool _isLoading = false;
//
//   List<TodoModel> get todos => List.unmodifiable(_todos);
//   TodoFilter get filter => _filter;
//   bool get isLoading => _isLoading;
//
//   int get completedCount => _todos.where((todo) => todo.isCompleted).length;
//   int get activeCount => _todos.length - completedCount;
//
//   List<TodoModel> get visibleTodos {
//     return _todos.where((todo) {
//       final matchesFilter = switch (_filter) {
//         TodoFilter.all => true,
//         TodoFilter.active => !todo.isCompleted,
//         TodoFilter.completed => todo.isCompleted,
//       };
//       final query = _searchQuery.trim().toLowerCase();
//       final matchesSearch = query.isEmpty ||
//           todo.title.toLowerCase().contains(query) ||
//           todo.description.toLowerCase().contains(query);
//       return matchesFilter && matchesSearch;
//     }).toList();
//   }
//
//   Future<void> loadTodos() async {
//     _isLoading = true;
//     notifyListeners();
//     _todos = _repository.getTodos();
//     _isLoading = false;
//     notifyListeners();
//   }
//
//   Future<void> addTodo({
//     required String title,
//     required String description,
//     required String user,
//     required String email,
//     required String password,
//   }) async {
//     final todo = TodoModel(
//       id: _uuid.v4(),
//       title: title.trim(),
//       description: description.trim(),
//       user: user.trim(),
//       email: email.trim(),
//       password: password.trim(),
//       createdAt: DateTime.now(),
//     );
//     await _repository.addTodo(todo);
//     _todos = _repository.getTodos();
//     notifyListeners();
//   }
//
//   Future<void> editTodo(
//     TodoModel oldTodo, {
//     required String title,
//     required String description,
//   }) async {
//     final updated = oldTodo.copyWith(
//       title: title.trim(),
//       description: description.trim(),
//     );
//     await _repository.updateTodo(updated);
//     _todos = _repository.getTodos();
//     notifyListeners();
//   }
//
//   Future<void> toggleTodo(TodoModel todo) async {
//     await _repository.updateTodo(
//       todo.copyWith(isCompleted: !todo.isCompleted),
//     );
//     _todos = _repository.getTodos();
//     notifyListeners();
//   }
//
//   Future<void> deleteTodo(String id) async {
//     await _repository.deleteTodo(id);
//     _todos = _repository.getTodos();
//     notifyListeners();
//   }
//
//   void setFilter(TodoFilter filter) {
//     _filter = filter;
//     notifyListeners();
//   }
//
//   void setSearchQuery(String query) {
//     _searchQuery = query;
//     notifyListeners();
//   }
// }
