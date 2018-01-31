$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'swagger2objc'

# 全服务更新

base_uri = 'http://superid.org:18000'
path = '/services'
Swagger2objc::Parser.new(base_uri, path)

# 单服务更新
#
# [
#   {
#     "location": "/web/v2/api-docs",
#     "name": "web",
#     "swaggerVersion": "2.0"
#   },
#   {
#     "location": "/user/v2/api-docs",
#     "name": "user",
#     "swaggerVersion": "2.0"
#   },
#   {
#     "location": "/file/v2/api-docs",
#     "name": "file",
#     "swaggerVersion": "2.0"
#   },
#   {
#     "location": "/tss/v2/api-docs",
#     "name": "tss",
#     "swaggerVersion": "2.0"
#   },
#   {
#     "location": "/notice/api/swagger.json",
#     "name": "notice",
#     "swaggerVersion": "2.0"
#   },
#   {
#     "location": "/msg/api/swagger.json",
#     "name": "msg",
#     "swaggerVersion": "2.0"
#   },
#   {
#     "location": "/permission/api/swagger.json",
#     "name": "auth",
#     "swaggerVersion": "2.0"
#   },
#   {
#     "location": "/audit/swagger.json",
#     "name": "audit",
#     "swaggerVersion": "2.0"
#   }
# ]
#

# name = 'web'
# only = [name]
# base_uri = 'http://192.168.1.63:19999'
# path = '/v2/api-docs'
# Swagger2objc::Parser.new(base_uri, path, only, name)
