require_relative "helper.rb"

t = Time.now

puts "Benchmarks for Ashton"
puts "====================="
puts "(results in milliseconds per call, operating on a image/texture of size 1022x1022)"
puts

puts
puts "Ashton"
puts "------"


benchmark("Ashton#fast_sin", 100_000) { Ashton.fast_sin 0 }
benchmark("Ashton#fast_cos", 100_000) { Ashton.fast_cos 0 }
puts
benchmark("Math#sin", 100_000) { Math.sin 0 }
benchmark("Math#sin", 100_000) { Math.cos 0 }

puts "\n\nBenchmarks completed in #{"%.2f" % (Time.now - t)}s"