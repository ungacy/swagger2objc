module Swagger2objc
  module Generator
    class Type
      OC_MAP = {
        'int32' => 'int32_t',
        'int64' => 'int64_t',
        'boolean' => 'BOOL',
        'double' => 'double',
        'string' => 'NSString',
        'object' => 'id',
        'Timestamp' => 'float'
      }.freeze
    end
  end
end
