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
    HATE = 'hate'.freeze
    RENAME = 'rename'.freeze
    PRIMARY = 'primary'.freeze
    LINK = 'link'.freeze
    FILTER = 'filter'.freeze
    ROUTER = 'router'.freeze
  end

  class Configure
    @@output = {}

    def self.output(type)
      if @@output.count == 0
        @@output = config[Swagger2objc::Config::OUTPUT]
        # puts "Current config is #{config}"
      end
      result = @@output[type]
      result << '/' unless result.end_with?('/')
      result
    end

    def self.parse_yaml(file)
      YAML.safe_load(File.open(File.join(Dir.pwd, file)))
    end

    def self.setup
      @@config = parse_yaml('.s2oconfig') if @@config.count == 0
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
