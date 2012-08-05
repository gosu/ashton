# Use dev version, not gem.
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ashton"

require 'texplay'

DESCRIPTION_WIDTH = 30

$window = Gosu::Window.new 1022, 1022, false

def benchmark(description, repeats, &block)
  raise unless block_given?
  noop = lambda {}

  GC.start
  GC.disable

  # Actual test.
  t = Time.now
  repeats.times { block.call }
  elapsed = Time.now - t

  GC.enable
  GC.start
  GC.disable

  # Control (noop loop).
  t = Time.now
  repeats.times { noop.call }
  elapsed -= Time.now - t

  GC.enable

  puts "    #{description.ljust(DESCRIPTION_WIDTH)} %*.5f" % [9, (elapsed / repeats * 1_000)]
end