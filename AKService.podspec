#
# Be sure to run `pod lib lint AKService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AKService'
  s.version          = '0.1.0'
  s.summary          = 'AirKorea 미세먼지 요청 라이브러리'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
AirKorea 미세먼지 요청 라이브러리.
location과 placemark 기준으로 주변 측정소 미세먼지 정보를 요청할 수 있습니다.
                       DESC

  s.homepage         = 'https://github.com/ocworld/AKService'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ocworld' => 'ocworld@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/ocworld/AKService.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'AKService/Sources/**/*'
  
  s.swift_version = '4.1'
    
  # s.resource_bundles = {
  #   'AKService' => ['AKService/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Alamofire', '~> 4.7'
  
end
