require 'yaml'

module Swagger2objc
  module Config
    AUTHOR = 'author'.freeze
    COMPANY = 'company'.freeze
    PROJECT = 'project'.freeze
    CLASS_PREFIX = 'class_prefix'.freeze
    IGNORE = 'ignore'.freeze
    MAPPING = 'mapping'.freeze
    TRIM = 'trim'.freeze
    AVOID = 'avoid'.freeze
    OUTPUT = 'output'.freeze
    MODEL = 'model'.freeze
    SDK = 'sdk'.freeze
  end

  class Configure
    @@output = {}
    def self.output(type)
      if @@output.count == 0
        @@output = self.config[Swagger2objc::Config::OUTPUT]
        puts "Current config is #{self.config}"
      end
      result = @@output[type]
      unless result.end_with?('/')
        result << '/'
      end
      result
    end

    def self.parse_yaml(file)
      YAML.safe_load(File.open(File.join(Dir.pwd, file)))
    end

    def self.setup
      if @@config.count == 0
        @@config = parse_yaml('.s2oconfig')
      end
      @@config
    end
    @@config = {}
    def self.config
      @@config
    end

    def config
      @@config
    end

    def initialize; end
  end
end
