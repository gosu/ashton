require_relative "helper.rb"

# Iterate for different number of times, depending on the speed of the operation, so benchmarks don't take all day!
REPEAT = 10000 # < 1ms
SLOW_REPEAT = 250 # < 10ms
VERY_SLOW_REPEAT = 25 # < 100ms
GLACIAL_REPEAT = 3 # otherwise

texture = Ashton::Texture.new 1022, 1022 # Largest Gosu image size.
texture.clear color: Gosu::Color::RED
image = texture.to_image
blob = image.to_blob
pixel_cache = texture.cache

t = Time.now

puts "Benchmarks for Ashton"
puts "====================="
puts "(results in milliseconds per call, operating on a image/texture of size 1022x1022)"
puts

puts
puts "Ashton::PixelCache"
puts "------------------"

benchmark("PixelCache#to_image", VERY_SLOW_REPEAT)      { pixel_cache.to_image }
puts
benchmark("PixelCache#refresh", SLOW_REPEAT)       { pixel_cache.refresh; pixel_cache.transparent? 0, 0 }
benchmark("PixelCache#to_blob", SLOW_REPEAT)       { pixel_cache.to_blob  }
benchmark("PixelCache#[x,y]", REPEAT)              { pixel_cache[0, 0] }
benchmark("PixelCache#rgba(x,y)", REPEAT)          { pixel_cache.rgba(0, 0) }
benchmark("PixelCache#red(x,y)", REPEAT)           { pixel_cache.red 0, 0 }
benchmark("PixelCache#transparent?(x, y)", REPEAT) { pixel_cache.transparent? 0, 0 }


puts
puts "Ashton::Texture"
puts "---------------"

benchmark("Texture#to_image", VERY_SLOW_REPEAT) { texture.to_image }
benchmark("Image#to_texture", VERY_SLOW_REPEAT) { image.to_texture }
puts

benchmark("Texture.new(w,h)", VERY_SLOW_REPEAT) { Ashton::Texture.new 1022, 1022 }
benchmark("- TP TexPlay.create_image(w,h)", VERY_SLOW_REPEAT) { TexPlay.create_image $window, 1022, 1022 }
puts

benchmark("Texture.new(blob,w,h)", VERY_SLOW_REPEAT) { Ashton::Texture.new blob, 1022, 1022 }
benchmark("- TexPlay Image.new(ImageStub)", VERY_SLOW_REPEAT) { Gosu::Image.new $window, TexPlay::ImageStub.new(blob, 1022, 1022) }
puts

benchmark("Texture#refresh_cache", SLOW_REPEAT) { texture.refresh_cache; texture.transparent? 0, 0 }
benchmark("- TP Image#refresh_cache", SLOW_REPEAT){ image.refresh_cache }
puts

benchmark("Texture#to_blob", VERY_SLOW_REPEAT) { texture.to_blob  }
benchmark("- TP Image#to_blob", VERY_SLOW_REPEAT) { image.to_blob }
puts

benchmark("Texture#dup", GLACIAL_REPEAT) { texture.dup }
benchmark("- TP Image#dup", GLACIAL_REPEAT) { image.dup }
puts

benchmark("Texture#[x,y]", REPEAT)              { texture[0, 0] }
benchmark("- TP Image#[x,y]", REPEAT)           { image[0, 0] }
puts

benchmark("Texture#rgba(x,y)", REPEAT)          { texture.rgba(0, 0) }
benchmark("- TP Image#[x,y]", REPEAT)           { image[0, 0] }
puts

benchmark("Texture#red(x,y)", REPEAT)           { texture.red 0, 0 }
benchmark("- TP Image#[x,y][0]", REPEAT)        { image[0, 0][0] }
puts

benchmark("Texture#transparent?(x, y)", REPEAT) { texture.transparent? 0, 0 }
benchmark("- TP Image#[x,y][3] == 0.0", REPEAT) { image[0, 0][3] == 0.0 }
puts

benchmark("Texture#draw(x,y,z)", REPEAT) { texture.draw(0, 0, 0); $window.flush }
benchmark("- Gosu Image#draw_rot(x,y,z,a)", REPEAT) { image.draw_rot_without_hash(0, 0, 0, 0); $window.flush }
puts

benchmark("Texture#render {}", SLOW_REPEAT) { texture.render {} }
benchmark("- TP Window#render_to_image {}", SLOW_REPEAT) { $window.render_to_image(image) {} }

puts "\n\nBenchmarks completed in #{"%.2f" % (Time.now - t)}s"