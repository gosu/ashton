require 'mkmf'

RUBY_VERSION =~ /(\d+.\d+)/
extension_name = "ashton/#{$1}/ashton"

dir_config(extension_name)

# 1.9 compatibility
$CFLAGS += ' -DRUBY_19' if RUBY_VERSION =~ /^1.9/

# let's use a nicer C (rather than C90)
$CFLAGS += " -std=gnu99"

# Stop getting annoying warnings for valid C99 code.
$warnflags.gsub!('-Wdeclaration-after-statement', '') if $warnflags

create_makefile(extension_name)
