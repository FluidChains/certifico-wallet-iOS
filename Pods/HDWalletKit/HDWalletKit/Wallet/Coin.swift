//
//  Coin.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 10/3/18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import Foundation

public enum Coin {
    case bitcoin
    case ethereum
    case litecoin
    case bitcoinCash
    case dash
    case dogecoin
    case exos
    case ruta
    
    //https://github.com/satoshilabs/slips/blob/master/slip-0132.md
    public var privateKeyVersion: UInt32 {
        switch self {
        case .litecoin:
            return 0x019D9CFE
        case .bitcoinCash: fallthrough
        case .bitcoin:
            return 0x0488ADE4
        case .dash:
            return 0x02FE52CC
        case .dogecoin:
            return 0x0488E1F4
        case .exos:
            return 0x0488ADE4
        case .ruta:
            return 0x0488ADE4
        default:
            fatalError("Not implemented")
        }
    }
    // P2PKH
    public var publicKeyHash: UInt8 {
        switch self {
        case .litecoin:
            return 0x30
        case .bitcoinCash: fallthrough
        case .bitcoin:
            return 0x00
        case .dash:
            return 0x4C
        case .dogecoin:
            return 0x1E
        case .exos:
            return 0x1C
        case .ruta:
            return 0x3C
        default:
            fatalError("Not implemented")
        }
    }
    
    // P2SH
    public var scriptHash: UInt8 {
        switch self {
        case .bitcoinCash: fallthrough
        case .litecoin: fallthrough
        case .bitcoin:
            return 0x05
        case .dash:
            return 0x10
        case .dogecoin:
            return 0x16
        case .exos:
            return 0x57
        case .ruta:
            return 0x7A
        default:
            fatalError("Not implemented")
        }
    }
    
    //https://www.reddit.com/r/litecoin/comments/6vc8tc/how_do_i_convert_a_raw_private_key_to_wif_for/
    public var wifAddressPrefix: UInt8 {
        switch self {
        case .dogecoin:
            return 0x9E
        case .bitcoinCash: fallthrough
        case .bitcoin:
            return 0x80
        case .litecoin:
            return 0xB0
        case .dash:
            return 0xCC
        case .exos:
            return 0x9C
        case .ruta:
            return 0xBC
        default:
            fatalError("Not implemented")
        }
    }
    
    public var addressPrefix:String {
        switch self {
        case .ethereum:
            return "0x"
        default:
            return ""
        }
    }
    
    public var uncompressedPkSuffix: UInt8 {
        return 0x01
    }
    
    
    public var coinType: UInt32 {
        switch self {
        case .bitcoin:
            return 0
        case .litecoin:
            return 2
        case .dash:
            return 5
        case .dogecoin:
            return 3
        case .ethereum:
            return 60
        case .bitcoinCash:
            return 145
        case .exos:
            return 248
        case .ruta:
            return 462
        
        }
    }
    
    public var scheme: String {
        switch self {
        case .bitcoin:
            return "bitcoin"
        case .litecoin:
            return "litecoin"
        case .bitcoinCash:
            return "bitcoincash"
        case .dogecoin:
            return "dogecoin"
        case .dash:
            return "dash"
        case .exos:
            return "exos"
        case .ruta:
            return "rutanio"
        default: return ""
        }
    }
    
    public var seedString: String {
        switch self {
        case .exos:
            return "CivX seed"
        case .ruta:
            return "Rutanio seed"
        default:
            return "Bitcoin seed"
        }
    }
}
