module Swagger2objc
  class Utils
    def self.class_name_formatter(class_name, service)
      return if class_name.start_with?('HashMap')

      type = Swagger2objc::Config::MODEL
      trim = Swagger2objc::Configure.config[Swagger2objc::Config::TRIM]
      class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX][type]
      result = class_name.clone
      dupicated_model_config = Swagger2objc::Configure.config[Swagger2objc::Config::DUPICATED_MODEL]
      dupicated_model = dupicated_model_config[service]
      if dupicated_model
        some = dupicated_model[result]
        result = some if some
      end
      trim.each do |key, value|
        result = result.sub(key, value)
      end
      mapping = Swagger2objc::Configure.config[Swagger2objc::Config::MAPPING]

      result = mapping[result] if mapping[result]
      if result == ''

      end

      if service == '/chat' && !result.start_with?('Chat')
        result = 'Chat' + result
      end
      service_prefix = Swagger2objc::Configure.config['service_prefix']
      service_prefix = {} if service_prefix.nil?
      prefix = service_prefix[service]
      if prefix && !result.include?(prefix)
        result = prefix + result
        result.sub!(prefix + prefix, prefix)
      end
      # result.sub!('ItemItem', 'ItemVO') if result.end_with?('ItemItem')
      class_prefix + result
    end

    def self.sdk_name_formatter(operation, controller, type)
      class_name = operation.path
      operationid = operation.operationId
      category =  controller.category
      hate = Swagger2objc::Configure.config[Swagger2objc::Config::HATE]
      class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX][type]
      result = class_name.clone
      unless result.include?('and') || category == 'Role' || result.end_with?(category.downcase)
        result = result.sub(category.downcase + '_', '')
      end
      hate.each do |key|
        result = result.sub('/' + key, '')
      end

      root_path = controller.service
      some = category[0].downcase + category[1..-1]
      result.sub!(root_path, '') if root_path != '/material' && root_path != '/announcement' && root_path != '/fund' && root_path != '/workflow'
      result.sub!('api/external', some)
      result.sub!('api', some)

      result.gsub!(%r{[/\_]\w}) { |match| match[1].upcase }
      result.gsub!(%r{[/[\_\-]]\w}) { |match| match[1].upcase }
      result.gsub!(%r{/\{\w+\}}, '')

      # if result != class_name
      #   puts "Rename [#{class_name}] to [#{result}]"
      # end
      if (root_path != '/chat' && category == 'Message') || category == 'Permission' || category == 'Audit' || category == 'DataAccess'
        short_name = operationid[0].capitalize + operationid[1..-1]
        short_name.gsub!(/By.*/, '')
        short_name.sub!(/Using.*/, '')

        return class_prefix + category + short_name
      end
      result.sub!('ChatGroupChatGroup', 'ChatGroup') if category == 'ChatGroup'
      if root_path == '/chat' && category == 'Message'
        result.sub!('Message', '')
        result = 'Chat' + result
      end
      if root_path == '/affair' && !result.start_with?('Affair')
        result = category + result
        result.sub!('MemberMember', 'Member')
      end
      service_prefix = Swagger2objc::Configure.config['service_prefix']
      service_prefix = {} if service_prefix.nil?
      prefix = service_prefix[root_path]
      result = prefix + result if prefix && !result.include?(prefix)
      result.sub!(category + category, category)
      # puts 'result : ' + result
      #
      specific_name_for_path = Swagger2objc::Configure.config['specific_name_for_path']
      if specific_name_for_path && specific_name_for_path[operation.path]
        result = specific_name_for_path[operation.path]
      end
      class_prefix + result
    end

    def self.all_ref_of_ref(refs, definitions, exclude = nil)
      all_ref = refs.dup
      model_in_properties = Set.new
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
              if exclude && exclude.include?(result)
              else
                model_in_properties << result
              end

            else
              all_ref << result
            end

          end
        end
      end
      if model_in_properties.count > 0
        all_ref += all_ref_of_ref(model_in_properties.to_a, definitions, refs)
      end
      all_ref
    end
  end
end
