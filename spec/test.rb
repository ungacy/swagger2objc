$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'swagger2objc'

# base_uri = 'http://192.168.31.222:9855/v2/api-docs'
base_uri = 'http://58.213.85.35:11000/mk/v2/api-docs'
filter = ['/default/order-controller'] # only for test
filter = nil
only = ['Alliance']
only = nil
parser = Swagger2objc::Parser.new(base_uri, filter, only)
parser.sdk_result
parser.model_result

# only = ['Message']
# base_uri = 'http://58.213.85.35:9800/api/swagger.json'
# parser = Swagger2objc::Parser.new(base_uri, filter, only)
# parser.sdk_result
# parser.model_result
# msg_uri = 'http://192.168.31.197:9800/api/swagger.json'
# parser = Swagger2objc::Parser.new(msg_uri, nil, nil)
