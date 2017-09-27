
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'swagger2objc/version'

Gem::Specification.new do |spec|
  spec.name          = 'swagger2objc'
  spec.version       = Swagger2objc::VERSION
  spec.authors       = ['Ungacy']
  spec.email         = ['ungacy@126.com']

  spec.summary       = 'Swagger2objc'
  spec.description   = 'Swagger2objc custom from super id'
  spec.homepage      = 'https://github.com/ungacy'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'json', '~> 2.0'
  spec.add_development_dependency 'nokogiri-plist', '~> 0.5.0'
end
