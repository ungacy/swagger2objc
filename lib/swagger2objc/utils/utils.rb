
module Swagger2objc
  class Utils
    def self.class_name_formatter(class_name)
      return if class_name.start_with?('HashMap')
      type = Swagger2objc::Config::MODEL
      trim = Swagger2objc::Configure.config[Swagger2objc::Config::TRIM]
      class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX][type]
      result = class_name.clone
      trim.each do |key, value|
        result.sub!(key, value)
      end
      mapping = Swagger2objc::Configure.config[Swagger2objc::Config::MAPPING]
      if mapping[result]
        result = mapping[result]
      end
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
        result.sub!(category.downcase + '_', '')
      end
      hate.each do |key|
        result.sub!('/' + key, '')
      end
      result.gsub!(/[\/\_]\w/) { |match| match[1].upcase }
      result.gsub!(/\/\{\w+\}/, '')

      # if result != class_name
      #   puts "Rename [#{class_name}] to [#{result}]"
      # end
      class_prefix + category + result
    end
  end
end
