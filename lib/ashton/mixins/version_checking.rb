module Ashton
  module Mixins
    module VersionChecking
      # Check if a specific OpenGL version is supported on this machine.
      #
      # @raise NotSupportedError
      def check_opengl_version(version)
        unless GL.version_supported? version
          raise NotSupportedError, "OpenGL #{version} required to utilise #{self.class}"
        end
      end

      # Check if a specific OpenGL extension is supported on this machine.
      #
      # @raise NotSupportedError
      def check_opengl_extension(extension)
        unless GL.extension_supported? extension
          raise NotSupportedError, "OpenGL extension #{extension} required to utilise #{self.class}"
        end
      end
    end
  end
end