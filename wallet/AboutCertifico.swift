//
//  AboutCertifico.swift
//  certificates
//
//  Created by Sergio Quintero on 12/17/20.
//  Copyright © 2020 Fluid Chains Inc. All rights reserved.
//

import UIKit

class AboutCertifico: UIViewController {

    @IBOutlet weak var lblAboutCertifico: LabelC3T5S!
    @IBOutlet weak var lblVersionBuild: LabelC7T4S!
    
    @IBOutlet weak var lblContactInfo: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblAboutCertifico.text = Localizations.AboutCertifico
        
        let version = getVersion()
        let build = getBuildVersion()
        lblVersionBuild.text = "Version: \(version) Build: \(build)"
        
        lblContactInfo.text = Localizations.ContactInfo
        
        

        
        // Do any additional setup after loading the view.
    }
    
    func getVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    func getBuildVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
