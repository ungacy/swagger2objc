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
          description: description,
          type: type
        }
      end
    end
  end
end
