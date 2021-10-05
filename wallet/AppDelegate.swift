//
//  AppDelegate.swift
//  wallet
//
//  Created by Chris Downie on 10/4/16.
//  Copyright © 2016 Learning Machine, Inc. All rights reserved.
//

import UIKit
import JSONLD
import HDWalletKit


private let sampleCertificateResetKey = "resetSampleCertificate"
private let enforceStrongOwnershipKey = "enforceStrongOwnership"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let tag = String(describing: AppDelegate.self)
    
    static var instance = UIApplication.shared.delegate as! AppDelegate
    
    var window: UIWindow?
    
    // MARK: - UIApplicationDelegate
    
    // The app has launched normally
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Logger.main.tag(tag).info("Application was launched!")
        InformationLogger.logInfo()
        
        
        let configuration = ArgumentParser().parse(arguments: ProcessInfo.processInfo.arguments)
        do {
            try ConfigurationManager().configure(with: configuration)
        } catch KeychainErrors.invalidPassphrase {
            fatalError("Attempted to launch with invalid passphrase.")
        } catch {
            fatalError("Attempted to launch from command line with unknown error: \(error)")
        }
        
        Logger.main.tag(tag).debug("Managed issuers list url: \(Paths.managedIssuersListURL)")
        
        setupApplication()
        
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidChange), name:UserDefaults.didChangeNotification, object: nil)
        
        return true
    }
    
    // The app has launched from a universal link
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        Logger.main.tag(tag).info("Application was launched from a user activity.")
        InformationLogger.logInfo()
        
        setupApplication()
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            Logger.main.tag(tag).info("launched with this url: \(url)")
            return importState(from: url)
        }
        
        return true
    }
    
    
    //AppLocker
    func applicationWillEnterForeground(_ application: UIApplication) {
        Logger.main.info("Validating passcode")
        var options = ALOptions()
        options.isSensorsEnabled = true
        options.color = Style.Color.C3
        options.image = UIImage(named: "Logo")
        if (Keychain.hasPassCode()) {
            AppLocker.present(with: .validate, and: options)
        } else {
            AppLocker.present(with: .create, and: options)
        }
        
    }
    
    
    
    // The app is launching with a document
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        Logger.main.tag(tag).info("Application was launched with a document at \(url)")
        InformationLogger.logInfo()
        
        setupApplication()
        launchAddCertificate(at: url, showCertificate: true, animated: false)
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Logger.main.tag(tag).info("Application entered the background.")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Logger.main.tag(tag).info("Application will terminate.")
    }
    
    // MARK: - Application specific
    
    func setupApplication() {
        self.window?.addSubview(JSONLD.shared.webView)
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        UserDefaults.standard.register(defaults: [
            sampleCertificateResetKey : false
        ])
        
        // Reset state if needed
        resetSampleCertificateIfNeeded()
    }
    
    @objc func settingsDidChange() {
        resetSampleCertificateIfNeeded()
        enforceStrongOwnershipIfNeeded()
    }
    
    func resetSampleCertificateIfNeeded() {
        guard UserDefaults.standard.bool(forKey: sampleCertificateResetKey) else {
            return
        }
        defer {
            UserDefaults.standard.set(false, forKey: sampleCertificateResetKey)
        }
        
        guard let sampleCertURL = Bundle.main.url(forResource: "SampleCertificate.json", withExtension: nil) else {
            Logger.main.tag(tag).warning("Unable to load the sample certificate.")
            return
        }
        
        _ = launchAddCertificate(at: sampleCertURL)
    }
    
    func enforceStrongOwnershipIfNeeded() {
        guard UserDefaults.standard.bool(forKey: enforceStrongOwnershipKey) else {
            return
        }
        
        let issuerCollection = popToIssuerCollection()
        issuerCollection?.reloadCollectionView()
    }
    
    
    func importState(from url: URL) -> Bool {
        Logger.main.tag(tag).debug("checking import state with url: \(url)")
        
        var pathComponents = url.pathComponents
        guard pathComponents.count >= 3 else {
            return false
        }
        Logger.main.tag(tag).debug("PathComponent: \(pathComponents)")
        
        var commandName = pathComponents.removeFirst()
        
        if commandName == "/" && pathComponents.count >= 1 {
            commandName = pathComponents.removeFirst()
        }
        if commandName == "api" && pathComponents.count >= 1 {
            commandName = pathComponents.removeFirst()
        }
        if commandName == "client-links" && pathComponents.count >= 1 {
            commandName = pathComponents.removeFirst()
        }
        
        Logger.main.tag(tag).debug("command name for import: \(commandName)")
        switch commandName {
        case "import-certificate":
            guard pathComponents.count >= 1 else {
                Logger.main.tag(tag).warning("false import")
                return false
            }
            let encodedCertificateURL = url.absoluteString;
            Logger.main.tag(tag).debug("encoded certificate url: \(encodedCertificateURL)")
            if let decodedCertificateString = encodedCertificateURL.removingPercentEncoding,
                let certificateURL = URL(string: decodedCertificateString) {
                Logger.main.tag(tag).debug("decoded certificate url: \(certificateURL)")
                launchAddCertificate(at: certificateURL, showCertificate: true, animated: true)
                return true
            } else {
                Logger.main.tag(tag).warning("failed to decode url")
                return false
            }
            
        case "add-issuer":
            guard let query = url.query else {
                return false
            }
            var pathComponents = query.components(separatedBy: "&")
            guard pathComponents.count >= 2 else {
                Logger.main.tag(tag).debug("false import")
                return false
            }
            let absoluteURL = pathComponents.removeFirst()
            var dividedURL = absoluteURL.components(separatedBy: "=")
            let encodedURL = dividedURL.removeLast()
            Logger.main.tag(tag).debug("encoded identification url: \(encodedURL)")
            
            let absoluteOTC = pathComponents.removeFirst()
            var dividedOTC = absoluteOTC.components(separatedBy: "=")
            let encodedOTC = dividedOTC.removeLast()
            Logger.main.tag(tag).debug("encoded nonce url: \(encodedOTC)")
            
            let absoluteChain = pathComponents.removeFirst()
            var divideChain = absoluteChain.components(separatedBy: "=")
            let encodeChain = divideChain.removeLast()
            Logger.main.tag(tag).debug("encoded chain: \(encodeChain)")
            
            if let decodedIdentificationString = encodedURL.removingPercentEncoding,
               let identificationURL = URL(string: decodedIdentificationString),
               let chain = encodeChain.removingPercentEncoding,
               let nonce = encodedOTC.removingPercentEncoding {
                Logger.main.tag(tag).debug("decoded identification url: \(identificationURL)")
                Logger.main.tag(tag).debug("decoded nonce: \(nonce)")
                
                launchAddIssuer(at: identificationURL, with: nonce, chain: chain)
                return true
            } else {
                Logger.main.tag(tag).warning("failed to decode url")
                return false
            }
            
        default:
            return false
        }
    }
    
    func launchAddIssuer(at introductionURL: URL, with nonce: String, chain: String) {
        Logger.main.tag(tag).debug("launching add issuer with chain: \(chain), url: \(introductionURL) and nonce: \(nonce)")
        let rootController = window?.rootViewController as? UINavigationController
        let issuerCollection = rootController?.viewControllers.first as? IssuerCollectionViewController
        
        issuerCollection?.autocompleteRequest = .addIssuer(identificationURL: introductionURL, nonce: nonce, chain: chain)
    }
    
    func launchAddCertificate(at url: URL, showCertificate: Bool = false, animated: Bool = true) {
        Logger.main.tag(tag).debug("launching add certificate with url: \(url)")
        let rootController = window?.rootViewController as? UINavigationController
        let issuerCollection = rootController?.viewControllers.first as? IssuerCollectionViewController
        
        issuerCollection?.autocompleteRequest = .addCertificate(certificateURL: url, silently: !showCertificate, animated: animated)
    }
    
    func popToIssuerCollection() -> IssuerCollectionViewController? {
        let rootController = window?.rootViewController as? UINavigationController
        
        rootController?.presentedViewController?.dismiss(animated: false, completion: nil)
        _ = rootController?.popToRootViewController(animated: false)
        
        return rootController?.viewControllers.first as? IssuerCollectionViewController
    }
    
    func resetData() {
        // Delete all certificates
        do {
            for certificateURL in try FileManager.default.contentsOfDirectory(at: Paths.certificatesDirectory, includingPropertiesForKeys: nil, options: []) {
                try FileManager.default.removeItem(at: certificateURL)
            }
        } catch {
        }
        
        // Delete Issuers, Certificates folder, and everything else in documents directory.
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let allFiles = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
            for fileURL in allFiles {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            
        }
        
    }
}
