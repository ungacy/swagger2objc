module Swagger2objc
  class Utils
    def self.class_name_formatter(class_name)
      trim = Swagger2objc::Configure.config[Swagger2objc::Config::TRIM]
      class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX]
      result = class_name.clone
      trim.each do |key, value|
        result.sub!(key, value)
      end
      if result != class_name
        # puts "Rename [#{class_name}] to [#{result}]"
      end
      class_prefix + result
    end

    def self.sdk_name_formatter(class_name)
      hate = Swagger2objc::Configure.config[Swagger2objc::Config::HATE]
      class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX]
      result = class_name.clone

      result.gsub!(/[\/\_]\w/) { |match| match[1].upcase }
      result.gsub!(/\/\{\w+\}/,'')
      hate.each do |key|
        result.sub!(key, '')
      end
      if result != class_name
        # puts "Rename [#{class_name}] to [#{result}]"
      end
      class_prefix + result
    end

  end
end
