#
# Be sure to run `pod lib lint BSAutocomplete.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BSAutocomplete'
  s.version          = '0.1.1'
  s.summary          = 'BSAutocomplete is the fullscreen autocomplete!'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'BSAutocomplete can give you amazing things like a fullscreen-autocomplete!!!!!!!!'

  s.homepage         = 'https://github.com/boraseoksoon/BSAutocomplete'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'boraseoksoon@gmail.com' => 'boraseoksoon@gmail.com' }
  s.source           = { :git => 'https://github.com/boraseoksoon/BSAutocomplete.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version = '4.2'

  s.source_files = 'BSAutocomplete/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BSAutocomplete' => ['BSAutocomplete/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
