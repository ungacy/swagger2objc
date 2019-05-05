require 'swagger2objc/struct/model'
module Swagger2objc
  module Struct
    class Service < Base
      # json中对应的键值
      attr_reader :basePath
      attr_reader :definitions
      attr_reader :host
      attr_reader :info
      attr_reader :paths # 每个path会生成一个Operation,存在下面的controllers中
      attr_reader :swagger
      attr_reader :tags

      # custom
      attr_reader :only
      attr_reader :controllers # Resources or Controllers
      # [{"name":"web","location":"/web/v2/api-docs","swaggerVersion":"2.0"}
      attr_reader :name # from #{url}/servers structs

      attr_reader :common
      def initialize(hash = {}, only, name)
        hash.each do |k, v|
          key = k.sub('$', '')
          instance_variable_set("@#{key}", v)
          self.class.send(:define_method, key, proc { instance_variable_get("@#{key}") })
          self.class.send(:define_method, "#{key}=", proc { |v| instance_variable_set("@#{key}", v) })
        end
        @only = only
        @name = name
        setup
      end

      def setup
        router_map = Swagger2objc::Configure.config[Swagger2objc::Config::ROUTER]
        path_map = Swagger2objc::Configure.config[Swagger2objc::Config::PATH_MAP]
        path_map = {} if path_map.nil?
        ignore_category = Swagger2objc::Configure.config[Swagger2objc::Config::IGNORE_CATEGORY]
        ignore_category = [] if ignore_category.nil?
        exclude_service_category = Swagger2objc::Configure.config['exclude_service_category']
        exclude_path = Swagger2objc::Configure.config['exclude_path']
        exclude_service_category = [] if exclude_service_category.nil?
        merge_category_into_server = Swagger2objc::Configure.config['merge_category_into_server']
        merge_category_into_server = {} if merge_category_into_server.nil?
        if definitions
          definitions.delete('Null')
          definitions.delete('Timestamp')
          definitions.delete('JSONObject')
        end
        controller_hash = {}
        @controllers = []
        @common = definitions.dup
        if @paths
          @paths.each do |path, dict|
            # 同一个path有多个请求,POST/GET.需要加前缀Submit/Query
            add_subfix = dict.keys.count > 1
            dict.each do |method, operation_hash|
              if operation_hash['tags']
                controller_key = operation_hash['tags'].first
                next if ignore_category.include?(controller_key)
              else
                next
              end

              # 获取类别 目前格式 [XX--controller]   [XX resource] [XXResource]
              category = controller_key.sub('-controller', '').sub(' resource', '').sub('Resource', '')

              # 首字母大写
              category = category[0].upcase + category[1..-1]
              # xx-aa-bb -> xxAaBb
              category.gsub!(/\-\w/) { |match| match[1].upcase }
              next if ignore_category.include?(category)
              next if path.include?('/inner/')

              exclude_category = exclude_service_category[@name]
              next if exclude_category && exclude_category.include?(category)

              # #合并所有XXX到一个类别中
              merge_category = merge_category_into_server[name]
              category = merge_category if merge_category
              # 有only,则只解析only列表中的
              next if @only && !@only.include?(category)

              # get/ post 大写
              operation_hash['method'] = method.upcase
              operation_hash['path'] = path

              # auth: permission/api
              # msg: msg/api
              # 上面比较特殊.需要加/api
              service = router_map[name]
              # 一般的[/xx] 就好, 比如[/web]
              service = '/' + name if service.nil?
              operation_hash['service'] = service
              # 某个请求称之为operation
              operation = Swagger2objc::Struct::Operation.new(operation_hash)
              next if operation.deprecated

              operation.path = service + operation.path if category != 'Collector'
              next if exclude_path && exclude_path.include?(operation.path)

              mapped_path = path_map[operation.path]
              next if mapped_path

              operation.add_subfix = add_subfix
              controller = controller_hash[controller_key]
              if controller.nil?
                controller = Swagger2objc::Struct::Controller.new
                controller.category = category
                controller.service = service
                @controllers << controller
                controller_hash[controller_key] = controller
              end
              puts category.center(20, '-') + ' : ' + operation.path
              controller.operations << operation
              controller.service = service
              @all_ref = Swagger2objc::Utils.all_ref_of_ref(operation.all_ref, @common)
              controller.models += @all_ref
              # @all_ref.each { |ref| @common.delete(ref) }
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
