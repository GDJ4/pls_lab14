import 'package:lab14/storage.dart';

class FakeStorage extends CalorieStorage {
  StoredState stored = const StoredState.empty();

  @override
  Future<StoredState> load() async => stored;

  @override
  Future<void> save(StoredState state) async {
    stored = state;
  }
}
