require_relative "helper.rb"


t = Time.now

def media_path(file); File.expand_path "../examples/media/#{file}", File.dirname(__FILE__) end
star = Gosu::Image.new $window, media_path("SmallStar.png"), true
fading_emitter = Ashton::ParticleEmitter.new 450, 100, 0,
                                            image: star,
                                            scale: 0.2,
                                            speed: 20,
                                            friction: 2,
                                            gravity: 4,
                                            max_particles: 10_000,
                                            interval: Float::INFINITY, # Never create in update.
                                            fade: 0.001,
                                            angular_velocity: -50..50

nonfading_emitter = Ashton::ParticleEmitter.new 450, 100, 0,
                                             image: star,
                                             scale: 0.2,
                                             speed: 20,
                                             friction: 2,
                                             gravity: 4,
                                             max_particles: 10_000,
                                             interval: Float::INFINITY, # Never create in update.
                                             angular_velocity: -50..50

delta = 1.0 / 60.0

puts "Benchmarks for Ashton"
puts "====================="
puts "(results in milliseconds per call, operating on a image/texture of size 1022x1022)"
puts

puts
puts "Ashton::ParticleEmitter"
puts "-----------------------"

puts "For emitter limited to 10k particles"
puts

benchmark("#draw for 0 particles", 100_000) { fading_emitter.draw; $window.flush}
benchmark("#update for 0 particles", 100_000) { fading_emitter.update delta }
puts

fading_emitter.emit
benchmark("#draw for 1 particle", 1_000) { fading_emitter.draw; $window.flush }
benchmark("#update for 1 particle", 1_000) { fading_emitter.update delta }
puts

benchmark("#emit creating particles", 100_000) { fading_emitter.emit }
benchmark("#emit replacing particles", 100_000) { fading_emitter.emit }
puts

puts "for emitter with color-change (i.e fades)"
puts
benchmark("#draw for 10k particles", 1_000) { fading_emitter.draw; $window.flush  }
benchmark("#update for 10k particles", 100) { fading_emitter.update delta }
puts

puts "for emitter without color-change (i.e. doesn't fade)"
puts
10_000.times { nonfading_emitter.emit }
benchmark("#draw for 10k particles", 1_000) { nonfading_emitter.draw; $window.flush  }
benchmark("#update for 10k particles", 100) { nonfading_emitter.update delta }


puts "\n\nBenchmarks completed in #{"%.2f" % (Time.now - t)}s"