# Uncomment the next line to define a global platform for your project

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
    end
  end
end

target 'PerfectlyCreated' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PerfectlyCreated

pod 'Firebase/Auth'
pod 'GoogleMLKit/BarcodeScanning'
pod 'Firebase/Firestore'
pod 'FirebaseFirestoreSwift'
pod 'Kingfisher'
pod 'CombineExt'
pod 'CombineCocoa'
pod 'Firebase/Analytics'
pod 'Firebase/Storage'
pod 'SwiftLint'
end
