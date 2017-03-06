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
  end

  class Configure
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
