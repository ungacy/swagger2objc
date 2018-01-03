$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'swagger2objc'

only = nil
base_uri = 'http://superid.org:18000'
path = '/services'
parser = Swagger2objc::Parser.new(base_uri, path, only)
