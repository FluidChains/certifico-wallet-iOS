//
//  PrivacyViewController.swift
//  wallet
//
//  Created by Chris Downie on 2/16/17.
//  Copyright © 2017 Learning Machine, Inc. All rights reserved.
//

import UIKit
import WebKit

class PrivacyViewController: UIViewController {
    var webView : WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        title = Localizations.PrivacyPolicy
        
        let locale = NSLocale.current.languageCode
        var privacyURL: URL
        
        switch locale {
        case "es":
            privacyURL = URL(string: "https://sun.certifico.io/es/mobile-privacy/mobile-es.html")!
        case "mt":
            privacyURL = URL(string: "https://sun.certifico.io/mt/mobile-privacy/mobile-mt.html")!
        case "it":
            privacyURL = URL(string: "https://sun.certifico.io/it/mobile-privacy/mobile-it.html")!
        case "ja":
            privacyURL = URL(string: "https://sun.certifico.io/mobile.html")!
        default:
            privacyURL = URL(string: "https://sun.certifico.io/mobile.html")!
        }
        
        let request = URLRequest(url: privacyURL)
        webView.load(request)
    }

}


class AboutPassphraseViewController: UIViewController {
    var webView : WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        title = Localizations.AboutPassphrases
        
        let locale = NSLocale.current.languageCode
        var url: URL
        
        switch locale {
        case "es":
            url = URL(string: "https://sun.certifico.io/es/about-passphrase/passphrase-es.html")!
        case "mt":
            url = URL(string: "https://sun.certifico.io/mt/about-passphrase/passphrase-mt.html")!
        case "it":
            url = URL(string: "https://sun.certifico.io/it/about-passphrase/passphrase-it.html")!
        case "ja":
            url = URL(string: "https://sun.certifico.io/mobile.html")!
        default:
            url = URL(string: "https://sun.certifico.io/passphrase.html")!
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
}
