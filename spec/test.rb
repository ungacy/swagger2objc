$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'swagger2objc'

# # Permission
# only = ['Permission']
# base_uri = 'http://192.168.1.100:9000/api/swagger.json'
# parser = Swagger2objc::Parser.new(base_uri, only)
# parser.sdk_result
# parser.model_result

#
# # Message
# only = ['Message']
# base_uri = 'http://192.168.1.200:9800/api/swagger.json'
# parser = Swagger2objc::Parser.new(base_uri, only)
# parser.sdk_result
# parser.model_result
#
# # Audit
# only = ['Audit']
# base_uri = 'http://192.168.1.233:9900/api/swagger.json'
# parser = Swagger2objc::Parser.new(base_uri, only)
# parser.sdk_result
# parser.model_result
#
# Default
base_uri = 'http://192.168.1.100:19999/v2/api-docs'
only = %w[
  Affair
  AffairMember
  Alliance
  AffairMember
  AllianceMember
  Announcement
  AnnouncementMember
  Chat
  Constant
  File
  Fund
  Material
  Message
  Notice
  Order
  Personnel
  Role
  Share
  Task
]
parser = Swagger2objc::Parser.new(base_uri, only)
parser.model_result
parser.sdk_result

# User
base_uri = 'http://192.168.1.100:19944/v2/api-docs'
only = nil
parser = Swagger2objc::Parser.new(base_uri, only)
parser.model_result
parser.sdk_result

# only = ['Message']
# base_uri = 'http://192.168.1.233:9800/api/swagger.json'
# parser = Swagger2objc::Parser.new(base_uri, filter, only)
# parser.sdk_result
# parser.model_result
# msg_uri = 'http://192.168.31.197:9800/api/swagger.json'
# parser = Swagger2objc::Parser.new(msg_uri, nil, nil)
