require 'benchmark'

# Use dev version, not gem.
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ashton"

require 'texplay'

t = Time.now

$window = Gosu::Window.new 100, 100, false

REPEAT = 10000

framebuffer = Ashton::Framebuffer.new 100, 100
framebuffer.clear color: Gosu::Color::RED
image = framebuffer.to_image

puts "Benchmarks for Ashton::Framebuffer (vs Texplay equivalents)"
puts

Benchmark.bm 24 do |x|
  x.report("Framebuffer#[]")            { REPEAT.times { framebuffer[0, 0] } }
  x.report("Framebuffer#transparent?")  { REPEAT.times { framebuffer.transparent? 0, 0 } }
  puts
  x.report("Texplay Image#[]")           { REPEAT.times { image[0, 0] } }
end


puts "\n\nBenchmarks completed in #{"%.3f" % (Time.now - t)} s"