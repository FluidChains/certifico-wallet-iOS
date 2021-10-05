//
//  BackupRestoreViewController.swift
//  certificates
//
//  Created by Sergio Quintero on 5/29/20.
//  Copyright © 2020 Learning Machine, Inc. All rights reserved.
//

import UIKit
import WebKit
import Blockcerts

class BackupRestoreViewController : UIViewController, ManagedIssuerDelegate {
    

//logger tag
    private let tag = String(describing: BackupRestoreViewController.self)
    private let certificateManager = CertificateManager()
    private let managedIssuersArchiveURL = Paths.managedIssuersListURL
    private let issuersArchiveURL = Paths.issuersNSCodingArchiveURL
    private let certificatesDirectory = Paths.certificatesDirectory
    
    
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var backupButton : SecondaryButton!
    @IBOutlet weak var restoreButton : SecondaryButton!
    @IBOutlet weak var deleteAllButton : PrimaryButton!
    @IBOutlet weak var viewContainer : UIView!
    
    var delegate: BackupRestoreViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Logger.main.tag(tag).info("view_did_load")
        
        title = "Backup & Restore"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        viewContainer.isAccessibilityElement = true
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
         Logger.main.tag(tag).info("view_will_appear")
         super.viewWillAppear(animated)
         navigationController?.styleDefault()
     }
    
    @IBAction func BackupNow() {
        CloudKitManager().saveAll()
        Logger.main.tag(tag).info("All Backup OK")
    }
    
    
    
}
protocol BackupRestoreViewDelegate : class {
       func added(managedIssuer: ManagedIssuer)
   }
