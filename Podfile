# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'certificates' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  # use_frameworks!
  use_modular_headers!

  # Pods for wallet
  #pod 'CoreBitcoin', :podspec => 'https://raw.github.com/oleganza/CoreBitcoin/master/CoreBitcoin.podspec', :inhibit_warnings => true
  pod 'HDWalletKit', :podspec => 'https://raw.github.com/FluidChains/HDWallet/master/HDWalletKit.podspec', :inhibit_warnings => true
  pod 'OpenSans'
  pod 'lottie-ios', '2.5.0'
  pod 'AppLocker'
#  pod 'Bugsee'

  target 'certificatesTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'certificatesUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
