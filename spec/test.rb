$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'swagger2objc'

# 全服务更新

# base_uri = 'https://api.superid.org:1443'
# path = '/services'
# Swagger2objc::Parser.new(base_uri, path)

# 单服务更新
#

# [
# {"name":"web","location":"/web/v2/api-docs","swaggerVersion":"2.0"},
# {"name":"user","location":"/user/v2/api-docs","swaggerVersion":"2.0"},
# {"name":"file","location":"/file/v2/api-docs","swaggerVersion":"2.0"},
# {"name":"tss","location":"/tss/v2/api-docs","swaggerVersion":"2.0"},
# {"name":"notice","location":"/notice/api/swagger.json","swaggerVersion":"2.0"},
# {"name":"msg","location":"/msg/api/swagger.json","swaggerVersion":"2.0"},
# {"name":"auth","location":"/permission/api/swagger.json","swaggerVersion":"2.0"},
# {"name":"audit","location":"/audit/swagger.json","swaggerVersion":"2.0"}
# ]

only = ['workflow']
base_uri = 'https://api.superid.org:1443'
path = '/services'
Swagger2objc::Parser.new(base_uri, path, only)
