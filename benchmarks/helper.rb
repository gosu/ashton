# Use dev version, not gem.
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ashton"

require 'texplay'

DESCRIPTION_WIDTH = 30

$window = Gosu::Window.new 1022, 1022, false

def benchmark(description, repeats)

  t = Time.now
  GC.disable
  repeats.times { yield }
  GC.enable
  GC.start
  elapsed = Time.now - t

  puts "    #{description.ljust(DESCRIPTION_WIDTH)} %*.5f" % [9, (elapsed / repeats * 1_000)]
end