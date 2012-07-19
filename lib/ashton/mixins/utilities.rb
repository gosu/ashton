module Ashton
  module Mixins
    module Utilities
      def check_opengl(version)
        unless GL.version_supported? version
          raise NotSupportedError, "OpenGL #{version} required to utilise #{self.class}"
        end
      end
    end
  end
end