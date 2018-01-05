require 'swagger2objc/struct/model'
module Swagger2objc
  module Struct
    class Root < Base
      attr_reader :basePath
      attr_reader :definitions
      attr_reader :common
      attr_reader :host
      attr_reader :tags
      attr_reader :info
      attr_accessor :paths
      attr_reader :swagger
      attr_accessor :only
      attr_reader :controllers

      def initialize(hash = {}, only)
        hash.each do |k, v|
          key = k.sub('$', '')
          instance_variable_set("@#{key}", v)
          self.class.send(:define_method, key, proc { instance_variable_get("@#{key}") })
          self.class.send(:define_method, "#{key}=", proc { |v| instance_variable_set("@#{key}", v) })
        end
        @only = only
        setup
      end

      def setup
        model_type = Swagger2objc::Config::MODEL
        model_class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX][model_type]
        router_map = Swagger2objc::Configure.config[Swagger2objc::Config::ROUTER]
        filter_array = Swagger2objc::Configure.config[Swagger2objc::Config::FILTER]
        filter_array = [] if filter_array.nil?
        if definitions
          definitions.delete('Null')
          definitions.delete('Timestamp')
        end
        controller_hash = {}
        @controllers = []
        @common = definitions.dup
        if @paths
          @paths.each do |path, dict|
            add_subfix = dict.keys.count > 1
            dict.each do |method, operation_hash|
              if operation_hash['tags']
                controller_key = operation_hash['tags'].first
                next if filter_array.include?(controller_key)
              else
                next
              end

              controller = controller_hash[controller_key]
              category = controller_key.sub('-controller', '').sub(' resource', '').sub('Resource', '')
              category = 'Audit' if category == 'AffairAudit' || category == 'AuditConfig'
              category = category[0].upcase + category[1..-1]
              category.gsub!(/\-\w/) { |match| match[1].upcase }
              next if filter_array.include?(category)
              category = 'File' if category == 'AppFile'
              next if @only && !@only.include?(category)
              # Swagger2objc::Generator::ModelGenerator.clear([category])
              # Swagger2objc::Generator::SDKGenerator.clear([category])
              operation_hash['method'] = method.upcase
              operation_hash['path'] = path
              router_prefix = router_map[category]
              router_prefix = if router_prefix.nil?
                                '/web'
                              else
                                '/' + router_prefix
                              end
              operation = Swagger2objc::Struct::Operation.new(operation_hash)
              operation.path = router_prefix + operation.path
              operation.add_subfix = add_subfix
              if controller.nil?
                controller = Swagger2objc::Struct::Controller.new
                controller.category = category
                @controllers << controller
                controller_hash[controller_key] = controller
              end
              controller.operations << operation

              all_ref = Swagger2objc::Utils.all_ref_of_ref(operation.all_ref, @common)
              controller.models += all_ref
              all_ref.each { |ref| @common.delete(ref) }
            end
          end
        end
        # raise "remain #{@common.count} for common" if @common.count != 0
      end

      def result
        paths.each do |item|
          puts item
        end
      end
    end
  end
end
