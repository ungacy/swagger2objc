$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'swagger2objc'

base_uri = 'http://192.168.1.100:9855/mk/api-docs'
base_uri = 'http://192.168.31.222:9855/api-docs'
filter = ['/default/order-controller'] # only for test
filter = nil
only = ['Affair']
parser = Swagger2objc::Parser.new(base_uri, filter, only)
parser.sdk_result
parser.model_result
