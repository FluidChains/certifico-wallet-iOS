//
//  Keychain.swift
//  wallet
//
//  Created by Chris Downie on 8/9/16.
//  Copyright © 2016 Digital Certificates Project.
//

import Foundation
import Security
import Blockcerts
import HDWalletKit

// reserved for backcompat
private var unusedKeyIndexKeyV1 = "io.certifico.unused-key-index"
private var unusedKeyIndexKey = "io.certifico.v2.unused-key-index"


public enum KeychainErrors : Error {
    case invalidPassphrase
}

class Keychain {
    public var seedPhrase : String {
        return mnemonic
    }
    private var unusedKeyIndex : UInt32 {
        didSet {
            UserDefaults.standard.set(Int(unusedKeyIndex), forKey: unusedKeyIndexKey)
        }
    }
    private let mnemonic : String
    // private let keychain :
    // private let accountKeychain : Wallet
    
    convenience init(seedPhrase: String) {
        // This lookup returns 0 if it can't be found.
        let index = UInt32(UserDefaults.standard.integer(forKey: unusedKeyIndexKey))
        self.init(seedPhrase: seedPhrase, unusedKeyIndex: index)
    }
    
    init(seedPhrase: String, unusedKeyIndex: UInt32) {
        
        self.mnemonic = seedPhrase
        self.unusedKeyIndex = unusedKeyIndex
        /* let words = seedPhrase.components(separatedBy: " ")
         guard let mnemonic = BTCMnemonic(words: words, password: "", wordListType: .english) else {
         fatalError("Can't start a Keychain with invalid phrase:\"\(seedPhrase)\"")
         }
         self.unusedKeyIndex = unusedKeyIndex
         self.mnemonic = mnemonic
         keychain = mnemonic.keychain
         accountKeychain = keychain.derivedKeychain(withPath: "m/44'/248'/0'/0") */
    }
    
    func generateMnemonic() -> String {
        let mnemonicGen = Mnemonic.create()
        return mnemonicGen
    }
    
    func nextPublicAddress(chain: Coin) -> String {
        
        let wallet = generateWallet(chain: chain)
        let address = wallet.generateAccount(at: unusedKeyIndex).address
        unusedKeyIndex += 1
        
        return address
        
        /* let key = accountKeychain.key(at: unusedKeyIndex)
         unusedKeyIndex += 1
         
         return key?.address.string ?? ""*/
    }
    
    func generateWallet(chain: Coin) -> Wallet {
        let seed = Mnemonic.createSeed(mnemonic: self.mnemonic)
        let wallet = Wallet(seed: seed, coin: chain)
        
        return wallet
    }
    
    
}

// MARK: Static methods for seed phrase generation
extension Keychain {
    static func generateSeedPhrase() -> String {
        return Mnemonic.create()
    }
    
    static func generateSeedPhrase(withRandomData randomData: Data) -> String {
        let mn = Mnemonic.create(entropy: randomData, language: .english)
        return mn
    }
}

// MARK: Singleton access, and loading/storing
extension Keychain {
    static private var seedPhraseKey = "io.certifico.seed-phrase"
    static private var _shared : Keychain? = nil
    static var shared : Keychain {
        if _shared == nil {
            // Implicitly unwrapped String, because it will either be loaded from memory or generated
            var seedPhrase : String! = loadSeedPhrase()
            if seedPhrase == nil {
                seedPhrase = generateSeedPhrase()
                save(seedPhrase: seedPhrase)
            }
            _shared = Keychain(seedPhrase: seedPhrase)
        }
        return _shared!
    }
    
    static func loadSeedPhrase() -> String? {
        let query : [String : Any] = [
            String(kSecClass): kSecClassGenericPassword,
            String(kSecAttrAccount): seedPhraseKey,
            String(kSecReturnData): kCFBooleanTrue,
            String(kSecMatchLimit): kSecMatchLimitOne
        ]
        
        var dataTypeRef : CFTypeRef?
        let result = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard result == noErr,
              let dataType = dataTypeRef as? Data else {
            return nil
        }
        
        return String(data:dataType, encoding: .utf8)
    }
    
    @discardableResult private static func save(seedPhrase: String) -> Bool {
        guard let data = seedPhrase.data(using: .utf8) else {
            return false;
        }
        
        let attributes : [String : Any] = [
            String(kSecClass) : kSecClassGenericPassword,
            String(kSecAttrAccount) : seedPhraseKey,
            String(kSecValueData) : data
        ]
        var returnValue : CFTypeRef?
        let result = SecItemAdd(attributes as CFDictionary, &returnValue)
        
        return result == noErr
    }
    
    private static func save(unusedKeyIndex: Int) {
        UserDefaults.standard.set(unusedKeyIndex, forKey: unusedKeyIndexKey)
    }
    
    public static func isValidPassphrase(_ passphrase: String) -> Bool {
        
        return true
    }
    
    public static func hasPassphrase() -> Bool {
        return loadSeedPhrase() != nil
    }
    
    
    public static func hasPassCode() -> Bool {
        let passCode = try? AppLocker.valet.string(forKey: ALConstants.kPincode)
        if (passCode != nil){
            return true
        } else {
            return false
        }
    }
    
    
    @discardableResult static func destroyShared() -> Bool {
        // Delete the seed phrase
        let query = [
            String(kSecClass) : kSecClassGenericPassword
        ]
        let result = SecItemDelete(query as CFDictionary)
        _shared = nil
        
        // Reset the unusedKeyIndex
        UserDefaults.standard.removeObject(forKey: unusedKeyIndexKey)
        UserDefaults.standard.synchronize()
        
        return result == noErr
    }
    
    static func updateShared(with seedPhrase: String, unusedIndex index: Int = 0) throws {
        // TODO: Do I need some kind of semaphore or something to make sure these two lines run one at a time?
        // If they don't, then it's possible we'll delete the key, the singleton will be recreated
        // with a random seed phrase, and the new seed phrase will be saved to the keychain. This will correct
        // itself when the app dies & is re-launched, but in the meantime the user might issue public keys
        // for a seed phrase he doesn't actually know.
        guard isValidPassphrase(seedPhrase) else {
            throw KeychainErrors.invalidPassphrase
        }
        destroyShared()
        save(seedPhrase: seedPhrase)
        save(unusedKeyIndex: index)
    }
}

