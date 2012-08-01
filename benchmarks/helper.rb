# Use dev version, not gem.
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ashton"

require 'texplay'

DESCRIPTION_WIDTH = 30

$window = Gosu::Window.new 1022, 1022, false

def benchmark(description, repeats)
  GC.disable

  t = Time.now
  repeats.times { yield }
  elapsed = Time.now - t

  GC.enable
  GC.start

  puts "    #{description.ljust(DESCRIPTION_WIDTH)} %*.5f" % [9, (elapsed / repeats * 1_000)]
end