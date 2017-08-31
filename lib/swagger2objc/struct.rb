module Swagger2objc
  module Struct
    class Base
      def self.init_with_hash(_hash = {}); end

      def setup; end

      # @return [HASH]
      def result; end
    end
  end
end

require 'swagger2objc/struct/controller'
require 'swagger2objc/struct/root'
require 'swagger2objc/struct/parameter'
require 'swagger2objc/struct/operation'
