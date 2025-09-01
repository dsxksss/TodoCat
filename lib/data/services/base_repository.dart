abstract class BaseRepository<T> {
  Future<void> initialize(String boxName);
  Future<T?> get(String key);
  Future<List<T>> getAll();
  Future<void> save(String key, T value);
  Future<void> update(String key, T value);
  Future<void> delete(String key);
  Future<void> clear();
  bool has(String key);
}
