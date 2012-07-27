require_relative "helper.rb"

# Iterate for different number of times, depending on the speed of the operation, so benchmarks don't take all day!
REPEAT = 10000
SLOW_REPEAT = 50

texture = Ashton::Texture.new 1022, 1022 # Largest Gosu image size.
texture.clear color: Gosu::Color::RED
image = texture.to_image
pixel_cache = texture.cache

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
puts "Ashton::Texture (#[] returns Gosu::Color, else Fixnum(s))"
puts "-----------------------------------------------------------"

benchmark("Texture#to_image", SLOW_REPEAT) { texture.to_image }
puts
benchmark("Texture#refresh_cache", SLOW_REPEAT) { texture.refresh_cache; texture.transparent? 0, 0 }
benchmark("Texture#to_blob", SLOW_REPEAT)       { texture.to_blob  }
benchmark("Texture#dup", SLOW_REPEAT)           { texture.dup }
benchmark("Texture#[x,y]", REPEAT)              { texture[0, 0] }
benchmark("Texture#rgba(x,y)", REPEAT)          { texture.rgba(0, 0) }
benchmark("Texture#red(x,y)", REPEAT)           { texture.red 0, 0 }
benchmark("Texture#transparent?(x, y)", REPEAT) { texture.transparent? 0, 0 }
benchmark("Texture#draw(x,y,z)", REPEAT)        { texture.draw(0, 0, 0); $window.flush }
benchmark("Texture#render {}", SLOW_REPEAT)     { texture.render {} }


puts
puts "TexPlay equivalents (Float arrays)"
puts "----------------------------------"

benchmark("Image#refresh_cache", SLOW_REPEAT)  { image.refresh_cache }
benchmark("Image#to_blob", SLOW_REPEAT)        { image.to_blob }
benchmark("Image#dup", 1)                      { image.dup }
benchmark("Image#[x,y]", REPEAT)               { image[0, 0] }
benchmark("Image#[x,y]", REPEAT)               { image[0, 0] }
benchmark("Image#[x,y][0]", REPEAT)            { image[0, 0][0] }
benchmark("Image#[x,y][3] == 0.0", REPEAT)     { image[0, 0][3] == 0.0 }
benchmark("Image#draw(x,y,z)", REPEAT)         { image.draw(0, 0, 0); $window.flush }
benchmark("Window#render_to_image {}", SLOW_REPEAT) { $window.render_to_image(image) {} }

GC.enable

puts "\n\nBenchmarks completed in #{"%.2f" % (Time.now - t)}s"