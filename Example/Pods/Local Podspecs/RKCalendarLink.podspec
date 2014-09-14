#
# Be sure to run `pod lib lint RKCalendarLink.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RKCalendarLink"
  s.version          = "0.1.0"
  s.summary          = "A short description of RKCalendarLink."
  s.description      = <<-DESC
                       An optional longer description of RKCalendarLink

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/samnung/RKCalendarLink"
  s.license          = 'MIT'
  s.author           = { "Roman Kříž" => "samnung@gmail.com" }
  s.source           = { :git => "https://github.com/samnung/RKCalendarLink.git", :tag => "v#{s.version}" }
  s.social_media_url = 'https://twitter.com/_samnung_'

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Foundation'

	s.dependency 'NSDateComponents-CalendarUnits', '0.0.2'
end
