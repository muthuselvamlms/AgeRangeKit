Pod::Spec.new do |s|
  s.name             = 'AgeRangeKit'
  s.version          = '1.0.0'
  s.summary          = 'A hybrid compatibility wrapper and mock implementation for Apple’s DeclaredAgeRange framework.'
  s.description      = <<-DESC
    AgeRangeKit provides a drop-in replacement for Apple’s DeclaredAgeRange API,
    supporting Simulator, older iOS, and VisionOS, while automatically using
    the native API when available.
  DESC

  s.homepage         = 'https://github.com/<your-username>/AgeRangeKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muthu' => 'you@example.com' }
  s.source           = { :git => 'https://github.com/<your-username>/AgeRangeKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '12.0'
  s.swift_version    = '5.9'

  s.source_files     = 'Sources/AgeRangeKit/**/*.{swift}'
  s.frameworks       = 'Foundation', 'SwiftUI'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/AgeRangeKitTests/**/*.{swift}'
  end
end
