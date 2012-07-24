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

puts "Benchmarks for Ashton::Framebuffer"
puts "=================================="
puts

Benchmark.bm 28 do |x|
  # Since Framebuffer#refresh_cache is lazy, must read a pixel before it will update.
  puts "Ashton"
  puts "------"
  puts
  x.report("    Framebuffer refresh cache") { REFRESH_REPEAT.times { framebuffer.refresh_cache; framebuffer.transparent? 0, 0 } }
  x.report("    Framebuffer#[x,y]")         { REPEAT.times { framebuffer[0, 0] } }
  x.report("    Framebuffer#red(x,y)")      { REPEAT.times { framebuffer.red 0, 0 } }
  x.report("    Framebuffer#transparent?")  { REPEAT.times { framebuffer.transparent? 0, 0 } }

  puts
  puts "TexPlay equivalents"
  puts "-------------------"
  puts
  x.report("    Image refresh cache")       { REFRESH_REPEAT.times { image.refresh_cache } }
  x.report("    Image#[x,y]")               { REPEAT.times { image[0, 0] } }
  x.report("    Image#[x,y][0]")            { REPEAT.times { image[0, 0][0] } }
  x.report("    Image#[x,y][3] == 0.0")     { REPEAT.times { image[0, 0][3] == 0.0 } }
end


puts "\n\nBenchmarks completed in #{"%.3f" % (Time.now - t)} s"