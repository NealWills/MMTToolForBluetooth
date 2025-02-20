#
# Be sure to run `pod lib lint MMTToolForBluetooth.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MMTToolForBluetooth'
  s.version          = '0.9.1'
  s.summary          = 'A short description of MMTToolForBluetooth.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A Bluetooth Tool For MMT Base
                       DESC

  s.homepage         = 'https://github.com/NealWills/MMTToolForBluetooth'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NealWills' => 'nealwills93@gmail.com' }
  s.source           = { :git => 'https://github.com/NealWills/MMTToolForBluetooth.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'MMTToolForBluetooth/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MMTToolForBluetooth' => ['MMTToolForBluetooth/Assets/*.png']
  # }

  s.frameworks = 'CoreBluetooth'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
