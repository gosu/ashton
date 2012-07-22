require 'benchmark'

# Use dev version, not gem.
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ashton"

require 'texplay'

t = Time.now

$window = Gosu::Window.new 100, 100, false

REPEAT = 10000
REFRESH_REPEAT = 100

framebuffer = Ashton::Framebuffer.new 1000, 1000
framebuffer.clear color: Gosu::Color::RED
image = framebuffer.to_image

puts "Benchmarks for Ashton::Framebuffer (vs Texplay equivalents)"
puts

Benchmark.bm 24 do |x|
  # Since Framebuffer#refresh_cache is lazy, must read a pixel before it will update.
  x.report("Framebuffer refresh cache") { REFRESH_REPEAT.times { framebuffer.refresh_cache; framebuffer.transparent? 0, 0 } }
  x.report("Framebuffer#[]")            { REPEAT.times { framebuffer[0, 0] } }
  x.report("Framebuffer#transparent?")  { REPEAT.times { framebuffer.transparent? 0, 0 } }

  puts
  puts "TexPlay equivalents"
  x.report("Image refresh cache")       { REFRESH_REPEAT.times { image.refresh_cache } }
  x.report("Image#[]")                  { REPEAT.times { image[0, 0] } }
  x.report("Image#[][3] == 0.0")        { REPEAT.times { image[0, 0][3] == 0.0 } }
end


puts "\n\nBenchmarks completed in #{"%.3f" % (Time.now - t)} s"