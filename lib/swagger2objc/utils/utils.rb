module Swagger2objc
  class Utils
    def self.class_name_formatter(class_name)
      return if class_name.start_with?('HashMap')
      type = Swagger2objc::Config::MODEL
      trim = Swagger2objc::Configure.config[Swagger2objc::Config::TRIM]
      class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX][type]
      result = class_name.clone
      trim.each do |key, value|
        result = result.sub(key, value)
      end
      mapping = Swagger2objc::Configure.config[Swagger2objc::Config::MAPPING]
      result = mapping[result] if mapping[result]
      if result != class_name
        # puts "Rename [#{class_name}] to [#{result}]"
      end
      class_prefix + result
    end

    def self.sdk_name_formatter(operation, controller, type)
      class_name = operation.path
      operationid = operation.operationId
      category =  controller.category
      hate = Swagger2objc::Configure.config[Swagger2objc::Config::HATE]
      router_map = Swagger2objc::Configure.config[Swagger2objc::Config::ROUTER]
      class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX][type]
      result = class_name.clone
      unless result.include?('and') || category == 'Role' || result.end_with?(category.downcase)
        result = result.sub(category.downcase + '_', '')
      end
      hate.each do |key|
        result = result.sub('/' + key, '')
      end

      root_path = controller.root_path
      some = category[0].downcase + category[1..-1]
      result.sub!(root_path, '')
      result.sub!('api/external', some)
      result.sub!('api', some)
      result.sub!('external/notification', 'notification')

      result.gsub!(/[\/\_]\w/) { |match| match[1].upcase }
      result.gsub!(/[\/[\_\-]]\w/) { |match| match[1].upcase }
      result.gsub!(/\/\{\w+\}/, '')

      # if result != class_name
      #   puts "Rename [#{class_name}] to [#{result}]"
      # end
      if category == 'Message' || category == 'Permission' || category == 'Audit'
        short_name = operationid[0].capitalize + operationid[1..-1]
        short_name.gsub!(/By.*/, '')
        return class_prefix + category + short_name
      end
      # puts 'result : ' + result
      class_prefix + result
    end

    def self.all_ref_of_ref(refs, definitions)
      all_ref = refs.dup
      refs.each do |ref|
        model = definitions[ref]
        next if model.nil?
        properties = model['properties']
        next if properties.nil?
        properties.each do |_name, property|
          result = ''
          definition = property['$ref']
          if definition
            definition = definition.sub('#/definitions/', '')
            result = definition if definition != 'Timestamp'
          else
            type = property['type']
            if type == 'List' || type == 'Array' || type == 'array'
              # puts property
              definition = property['items']['$ref']
              if definition
                definition = definition.sub('#/definitions/', '')
                result = definition if definition != 'Timestamp'
              end
            end
          end
          additionalProperties = property['additionalProperties']
          if additionalProperties && additionalProperties['items'] && additionalProperties['items']['$ref']
            some = additionalProperties['items']['$ref']
            result = some.sub('#/definitions/', '') if some
          end
          if result != ''
            if !all_ref.include?(result)
              all_ref += all_ref_of_ref([result], definitions)
            else
              all_ref << result
            end

          end
        end
      end
      all_ref
    end
  end
end
