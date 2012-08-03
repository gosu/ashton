require_relative "helper.rb"


t = Time.now

def media_path(file); File.expand_path "../examples/media/#{file}", File.dirname(__FILE__) end
$window = Gosu::Window.new 10, 10, false
star = Gosu::Image.new $window, media_path("SmallStar.png"), true
emitter = Ashton::ParticleEmitter.new 450, 100, 0,
                                      image: star,
                                      scale: 0.2,
                                      speed: 20,
                                      friction: 2,
                                      gravity: 4,
                                      max_particles: 10_000,
                                      interval: Float::INFINITY, # Never create in update.
                                      fade: 1, # loses 1 alpha/s
                                      angular_velocity: -50..50

puts "Benchmarks for Ashton"
puts "====================="
puts "(results in milliseconds per call, operating on a image/texture of size 1022x1022)"
puts

puts
puts "Ashton::ParticleEmitter"
puts "-----------------------"

puts "For emitter limited to 10k particles"
puts

benchmark("#draw for 0 particles", 100_000) { emitter.draw  }
benchmark("#update for 0 particles", 100_000) { emitter.update 1.0 / 60.0 }
puts

emitter.emit
benchmark("#draw for 1 particle", 100_000) { emitter.draw  }
puts

benchmark("#emit creating particles", 100_000) { emitter.emit }
benchmark("#emit replacing particles", 100_000) { emitter.emit }
puts

benchmark("#draw for 10k particles", 100_000) { emitter.draw  }
benchmark("#update for 10k particles", 100) { emitter.update 1.0 / 60.0 }


puts "\n\nBenchmarks completed in #{"%.2f" % (Time.now - t)}s"