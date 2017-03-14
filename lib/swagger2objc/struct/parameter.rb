module Swagger2objc
  module Struct
    class Parameter < Base
      attr_reader :allowMultiple
      attr_reader :defaultValue
      attr_reader :description
      attr_reader :format
      attr_reader :name
      attr_reader :paramType
      attr_reader :required
      attr_reader :type

      def setup
        # puts '------------------Parameter----------------'
        # puts 'paramType : ' + paramType
        # puts 'description : ' + description
        # puts 'type : ' + type
      end

      def result
        {
          paramType: paramType,
          key: description,
          type: type,
          required: required,
          defaultValue: defaultValue ? defaultValue : ' ',
          format: format ? format : ''
        }
      end
    end
  end
end
