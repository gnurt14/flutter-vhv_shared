abstract class TracePerformanceBase{
  Future<void> start(String traceKey);
  Future<void> stop(String traceKey);
  Future<T> tracePerformance<T>(String name, Future<T> Function() block);
  void dispose();
}