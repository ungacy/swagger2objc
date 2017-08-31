module Swagger2objc
  module Generator
    class Type
      OC_MAP = {
        'int32' => 'int32_t',
        'int64' => 'int64_t',
        'integer' => 'int64_t',
        'boolean' => 'BOOL',
        'double' => 'double',
        'float' => 'float',
        'string' => 'NSString',
        'object' => 'id',
        'File' => 'UIImage',
        'Timestamp' => 'double',
        'Null' => 'NSString',
        'array' => 'NSArray'
      }.freeze
    end
  end
end
