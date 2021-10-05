//
//  CloudKitController.swift
//  certificates
//
//  Created by Sergio Quintero on 5/29/20.
//  Copyright © 2020 Learning Machine, Inc. All rights reserved.
//

import Foundation
import CloudKit

private var cloudKitContainer = CKContainer(identifier: "iCloud.org.fluidchains.demo-app")
private let managedIssuersArchiveURL = Paths.managedIssuersListURL
private let certificatesDirectory = Paths.certificatesDirectory

class CloudKitManager {   
    
    
    /*Return seed from iCloud*/
    func fetchSeedPhrase(completion: @escaping ([CKRecord]?, Error?) -> Void) {
        
        let query = CKQuery(recordType: "Seed", predicate: NSPredicate(value: true) )
        query.sortDescriptors = [NSSortDescriptor(key: "seed", ascending: true)]
        
        cloudKitContainer.privateCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) -> Void in
            guard error == nil else {
                return
            }
            completion(records,nil)
            
        })
    }
    
    func fetchIndex(completion: @escaping ([CKRecord]?, Error?) -> Void) {
        
        let query = CKQuery(recordType: "Index", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        
        cloudKitContainer.privateCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) -> Void in
            guard error == nil else {
                return
            }
            completion(records,nil)
        })
    }
    
    func addRecord(record: String) {
        let recordToSave = CKRecord(recordType: "Seed")
        
        recordToSave["seed"] = record as CKRecordValue?
        
        cloudKitContainer.privateCloudDatabase.save(recordToSave, completionHandler: { (recordToSave, error) in
            guard let _ = error else {
                return
            }            
        })
    }
    
    func saveIndex() {
        let indexToSave = CKRecord(recordType: "Index")
        let index = UInt32(UserDefaults.standard.integer(forKey: "org.fluidchains.v2.unused-key-index"))
        indexToSave["index"] = index as CKRecordValue?
        cloudKitContainer.privateCloudDatabase.save(indexToSave) { (indexToSave, error) in
            guard let _ = error else {
                return
            }
        }
    }
    
    func saveManagedIssuers() {
        let issuerToSave = CKRecord(recordType: "ManagedIssuers")
        let managedIssuers = CKAsset(fileURL: managedIssuersArchiveURL)
        issuerToSave["managedIssuers"] = managedIssuers as CKRecordValue?
        cloudKitContainer.privateCloudDatabase.save(issuerToSave) { (indexToSave, error) in
            guard let _ = error else {
                return
            }
        }
    }
    
    func saveCertificates() {
        let certificates =  try? FileManager.default.contentsOfDirectory(atPath: certificatesDirectory.path)
        let files = certificates ?? []
        guard files.count > 0 else {
            return
        }
        let certificateToSave = CKRecord(recordType: "Certificate")
        files.forEach { certificate in
            let certificateFile = CKAsset(fileURL: URL(fileURLWithPath: certificate))
                
                certificateToSave["certificate"] = certificate as CKRecordValue?
            cloudKitContainer.privateCloudDatabase.save(certificateToSave) { (certificateToSave, error) in
                guard let _ = error else {
                    return
                }
            }
        }
    }
    
    func saveAll() {
        saveIndex()
        saveCertificates()
        saveManagedIssuers()
    }
    
    
}
