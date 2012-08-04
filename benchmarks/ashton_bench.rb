require_relative "helper.rb"

t = Time.now

puts "Benchmarks for Ashton"
puts "====================="
puts "(results in milliseconds per call, operating on a image/texture of size 1022x1022)"
puts

puts
puts "Ashton"
puts "------"

puts "Actually only faster because it deals in gosu degrees, not radians"
benchmark("Ashton#fast_sin", 100_000) { Ashton.fast_sin 99.0 }
benchmark("Ashton#fast_cos", 100_000) { Ashton.fast_cos 99.0 }
puts
benchmark("Math#sin", 100_000) { Math.sin (99.0 - 90.0) * Math::PI / 180.0 }
benchmark("Math#cos", 100_000) { Math.cos 99.0.gosu_to_radians }

puts "\n\nBenchmarks completed in #{"%.2f" % (Time.now - t)}s"