require 'swagger2objc/struct/parameter'

module Swagger2objc
  module Struct
    class Operation < Base
      attr_reader :consumes
      attr_reader :deprecated
      attr_reader :format
      attr_reader :method
      attr_reader :nickname
      attr_reader :notes
      attr_reader :parameters
      attr_reader :produces
      attr_reader :responseMessages
      attr_reader :summary
      attr_reader :type

      def setup
        parameters.map! { |item| Parameter.new(item) }
        responseMessages.select! { |item| item['code'] == '200' }
        # NO responseMessages
        if responseMessages.count == 0
          @response_model = type
        else
          @response_model = responseMessages.first[responseModel]
        end
        if @response_model == 'integer'
          @response_model = format
        end
        raise 'No response model' if @response_model.nil?
        oc_type = Swagger2objc::Generator::Type::OC_MAP[@response_model]
        if oc_type.nil?
          @response_model = Swagger2objc::Utils.class_name_formatter(@response_model)
        else
          @response_model = oc_type
        end
      end

      def result
        parameter_result = []
        parameters.each { |item| parameter_result << item.result }
        hash = {
          method: method,
          notes: notes.sub('<', '[').sub('>', ']'),
          summary: summary,
          type: type,
          param: parameter_result,
        }
        class_prefix = Swagger2objc::Configure.config[Swagger2objc::Config::CLASS_PREFIX][Swagger2objc::Config::MODEL]
        if @response_model.start_with?(class_prefix)
          hash[:response] = @response_model
        end
        hash
      end

      def output
        info = "\n/**\n"
        info << " method    : #{method}\n"
        info << " notes     : #{notes}\n"
        info << " summary   : #{summary}\n"
        info << " type      : #{type}\n"
        if format
          info << " format    : #{format}\n"
        end
        info << " response  : #{@response_model}\n"
        info << "*/"
      end

    end
  end
end
