#
# Be sure to run `pod lib lint AKService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AKService'
  s.version          = '0.3.3'
  s.summary          = 'AirKorea 미세먼지 요청 라이브러리'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  AirKorea에서 제공하는 API를 iOS에서 사용하기 위한 라이브러리입니다.
  미세먼지 요청 기능을 중심으로 제공합니다.
                       DESC

  s.homepage         = 'https://github.com/ocworld/AKService'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Keunhyun Oh' => 'ocworld@gmail.com' }
  s.source           = { :git => 'https://github.com/ocworld/AKService.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'AKService/Sources/**/*'
  
  s.swift_version = '4.1'
 
  s.resources = 'AKService/Assets/*.plist'
  
  # s.resource_bundles = {
  #   'AKService' => ['AKService/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Alamofire', '~> 4.7'
  
end
