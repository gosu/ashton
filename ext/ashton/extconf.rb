require 'mkmf'

RUBY_VERSION =~ /(\d+.\d+)/
extension_name = "ashton/#{$1}/ashton"

dir_config(extension_name)

# 1.9 compatibility
$CFLAGS << ' -DRUBY_19' if RUBY_VERSION =~ /^1.9/

# let's use a nicer C (rather than C90)
$CFLAGS << " -std=gnu99"

$CFLAGS << " -I#{File.expand_path "../vendor/gl/include", __FILE__}"

# Make it possible to use a debugger.
#$CFLAGS << " -g -O0"

# Stop getting annoying warnings for valid C99 code.
$warnflags.gsub!('-Wdeclaration-after-statement', '') if $warnflags

ok = true

ok &&= have_library('opengl32.lib', 'glVertex3d') ||
       have_library('opengl32')

ok &&= have_header('GL/gl.h') ||
       have_header('OpenGL/gl.h') # OSX

#have_header 'stdint.h'
#have_header 'inttypes.h'
#have_type 'int64_t', 'stdint.h'
#have_type 'uint64_t', 'stdint.h'

if ok then
  create_header
  create_makefile extension_name
end
