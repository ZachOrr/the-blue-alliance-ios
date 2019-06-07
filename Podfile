platform :ios, '11.0'

inhibit_all_warnings!

if ENV['TRAVIS']
  install! 'cocoapods', :share_schemes_for_development_pods => true
end

target 'The Blue Alliance' do
  use_frameworks!

  # Deps
  pod 'BFRImageViewer'
  pod 'PINRemoteImage', '3.0.0-beta.13'
  pod 'PureLayout'
  pod 'XCDYouTubeKit', '~> 2.7'
  pod 'Zip', '~> 1.1'

  # Local Deps
  pod 'MyTBAKit', :path => 'Frameworks/MyTBAKit', :testspecs => ['Tests']
  pod 'TBAKit', :path => 'Frameworks/TBAKit', :testspecs => ['Tests']
  pod 'TBAOperation', :path => 'Frameworks/TBAOperation', :testspecs => ['Tests']

  # Debugging

  target 'tba-unit-tests' do
    inherit! :search_paths

    pod 'iOSSnapshotTestCase', '4.0.1' # TODO: Update to 6.0
    pod 'MyTBAKitTesting', :path => 'Frameworks/MyTBAKit'
    pod 'TBAKitTesting', :path => 'Frameworks/TBAKit'
    pod 'TBATestingMocks', :path => 'Frameworks/TBATestingMocks'
    pod 'TBAOperationTesting', :path => 'Frameworks/TBAOperation'
  end
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-The Blue Alliance/Pods-The Blue Alliance-acknowledgements.plist',
  'the-blue-alliance-ios/Settings.bundle/Acknowledgements.plist', :remove_destination => true)

  installer.pods_project.targets.each do |target|
    if "#{target}" == "AppAuth"
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.3'
      end
    end
  end
end
