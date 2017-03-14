require 'swagger2objc/generator/template_replacer'
require 'swagger2objc/generator/file_generator'
require 'swagger2objc/struct/model'
require 'swagger2objc/generator/type'
require 'swagger2objc/constants'
require 'swagger2objc/config'

module Swagger2objc
  module Generator
    class AbstractGenerator
      attr_reader :category
      attr_reader :author
      attr_reader :company
      attr_reader :project
      attr_reader :model

      def self.clear
        FileGenerator.clear(Swagger2objc::Config::MODEL)
        FileGenerator.clear(Swagger2objc::Config::SDK)
      end

      def initialize(category = nil, model)
        config = Configure.config
        @author = config[Swagger2objc::Config::AUTHOR]
        @company = config[Swagger2objc::Config::COMPANY]
        @project = config[Swagger2objc::Config::PROJECT]
        @category = category
        @model = model
      end

      def generate; end
    end
  end
end
