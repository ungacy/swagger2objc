$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'swagger2objc'

base_uri = 'http://192.168.1.100:9855/mk/api-docs'
# base_uri = 'http://192.168.1.250:9855/api-docs'
filter = '/affair-controller'
# filter = nil
parser = Swagger2objc::Parser.new(base_uri, filter)
parser.result
