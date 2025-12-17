Pod::Spec.new do |s|
  s.name         = "DatadogApollo"
  s.version      = "1.0.1"
  s.summary      = "Datadog Integration for Apollo iOS GraphQL Client."

  s.homepage     = "https://www.datadoghq.com"
  s.social_media_url   = "https://twitter.com/datadoghq"

  s.license            = { :type => "Apache", :file => 'LICENSE' }
  s.authors            = { 
    "Barbora Plasovska" => "barbora.plasovska@datadoghq.com",
  }

  s.swift_version = '5.9'
  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'
  s.watchos.deployment_target = '7.0'
  s.osx.deployment_target = '12.0'

  s.source = { :git => "https://github.com/DataDog/dd-sdk-ios-apollo-interceptor.git", :tag => s.version.to_s }

  s.source_files = "Sources/DatadogApollo/**/*.swift"

  s.dependency 'Apollo', '~> 1.0'

end
