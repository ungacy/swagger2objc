require 'swagger2objc/generator/abstract_generator'
require 'nokogiri-plist'

module Swagger2objc
  module Generator
    class SDKGenerator < AbstractGenerator

      def generate
        result = {}
        model.each {|controller|
          controller.apis.each {|request|
            hash = request.operation.result
            hash["path"] = request.path
            class_name = Swagger2objc::Utils.sdk_name_formatter(request.path)
            result[class_name] = hash

          }
        }
        puts result.to_plist_xml
      end

    end
  end
end
