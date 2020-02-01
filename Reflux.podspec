#
# Be sure to run `pod lib lint Reflux.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Reflux'
  s.version          = '0.1.1'
  s.summary          = 'A swift implementation of flux pattern.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A swift implementation of flux pattern.
                       DESC

  s.homepage         = 'https://github.com/guangmingzizai/Reflux'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'guangmingzizai' => 'guangmingzizai@qq.com' }
  s.source           = { :git => 'https://github.com/guangmingzizai/Reflux.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Reflux/Classes/**/*'
  s.swift_version = '4.2'
  
  # s.resource_bundles = {
  #   'Reflux' => ['Reflux/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
