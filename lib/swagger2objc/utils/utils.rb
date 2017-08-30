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

    def self.sdk_name_formatter(class_name, category, type)
      hate = Swagger2objc::Configure.config[Swagger2objc::Config::HATE]
      class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX][type]
      result = class_name.clone
      unless result.include?('and') || category == 'Role' || result.end_with?(category.downcase)
        result = result.sub(category.downcase + '_', '')
      end
      hate.each do |key|
        result = result.sub('/' + key, '')
      end
      result.gsub!(/[\/\_]\w/) { |match| match[1].upcase }
      result.gsub!(/\/\{\w+\}/, '')

      # if result != class_name
      #   puts "Rename [#{class_name}] to [#{result}]"
      # end
      class_prefix + result
    end

    def self.all_ref_of_ref(refs, definitions)
      all_ref = refs.dup
      refs.each {|ref|
        model = definitions[ref]
        if model.nil?
          #puts ref
          next
        end
        properties = model['properties']
        next if properties.nil?
        properties.each {|name, property|
          result = ''
          definition = property['$ref']
          if definition
            definition =  definition.sub('#/definitions/', '')
            if definition != 'Timestamp'
              result = definition
            end
          else
            type = property['type']
            if type == 'List' || type == 'Array' || type == 'array'
              puts property
              definition = property['items']['$ref']
              if definition
                definition =  definition.sub('#/definitions/', '')
                if definition != 'Timestamp'
                  result = definition
                end
              end
            end
          end

          if result != ''
            if !all_ref.include?(result)
              all_ref += all_ref_of_ref([result], definitions)
            else
              all_ref << result
            end

          end
        }
      }
      all_ref
    end
  end
end
