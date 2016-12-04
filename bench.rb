time = Benchmark.measure { StrategicPlan.current.eager_loaded_associations.first.to_json }
puts time.to_s

time = Benchmark.measure { StrategicPlan.load_sql }
puts time.to_s

