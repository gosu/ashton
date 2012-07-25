require_relative "helper.rb"

# Iterate for different number of times, depending on the speed of the operation, so benchmarks don't take all day!
REPEAT = 10000
SLOW_REPEAT = 50

framebuffer = Ashton::Framebuffer.new 1022, 1022 # Largest Gosu image size.
framebuffer.clear color: Gosu::Color::RED
image = framebuffer.to_image
pixel_cache = framebuffer.cache

t = Time.now

puts "Benchmarks for Ashton"
puts "====================="
puts "(results in milliseconds per call, operating on a texture of size 1022x1022)"
puts

GC.disable

puts
puts "Ashton::PixelCache (#[] returns Gosu::Color, else Fixnum(s))"
puts "-----------------------------------------------------------"

benchmark("PixelCache#to_image", SLOW_REPEAT)      { pixel_cache.to_image }
puts
benchmark("PixelCache#refresh", SLOW_REPEAT)       { pixel_cache.refresh; pixel_cache.transparent? 0, 0 }
benchmark("PixelCache#to_blob", SLOW_REPEAT)       { pixel_cache.to_blob  }
benchmark("PixelCache#[x,y]", REPEAT)              { pixel_cache[0, 0] }
benchmark("PixelCache#rgba(x,y)", REPEAT)          { pixel_cache.rgba(0, 0) }
benchmark("PixelCache#red(x,y)", REPEAT)           { pixel_cache.red 0, 0 }
benchmark("PixelCache#transparent?(x, y)", REPEAT) { pixel_cache.transparent? 0, 0 }


puts
puts "Ashton::Framebuffer (#[] returns Gosu::Color, else Fixnum(s))"
puts "-----------------------------------------------------------"

benchmark("Framebuffer#to_image", SLOW_REPEAT) { framebuffer.to_image }
puts
benchmark("Framebuffer#refresh_cache", SLOW_REPEAT) { framebuffer.refresh_cache; framebuffer.transparent? 0, 0 }
benchmark("Framebuffer#to_blob", SLOW_REPEAT)       { framebuffer.to_blob  }
benchmark("Framebuffer#[x,y]", REPEAT)              { framebuffer[0, 0] }
benchmark("Framebuffer#rgba(x,y)", REPEAT)          { framebuffer.rgba(0, 0) }
benchmark("Framebuffer#red(x,y)", REPEAT)           { framebuffer.red 0, 0 }
benchmark("Framebuffer#transparent?(x, y)", REPEAT) { framebuffer.transparent? 0, 0 }


puts
puts "Gosu::Image - TexPlay equivalents (Float arrays)"
puts "----------------------------------"

benchmark("Image#refresh_cache", SLOW_REPEAT) { image.refresh_cache }
benchmark("Image#to_blob", SLOW_REPEAT)       { image.to_blob }
benchmark("Image#[x,y]", REPEAT)              { image[0, 0] }
benchmark("Image#[x,y]", REPEAT)              { image[0, 0] }
benchmark("Image#[x,y][0]", REPEAT)           { image[0, 0][0] }
benchmark("Image#[x,y][3] == 0.0", REPEAT)    { image[0, 0][3] == 0.0 }
GC.enable

puts "\n\nBenchmarks completed in #{"%.2f" % (Time.now - t)}s"