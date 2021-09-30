//
//  CertificateMetadataViewController.swift
//  wallet
//
//  Created by Chris Downie on 4/4/17.
//  Copyright © 2017 Learning Machine, Inc. All rights reserved.
//

import UIKit
import Blockcerts

// MARK: - Table Cell View Model

protocol TableCellModel {
    static var cellClass: AnyClass { get }
    static var reuseIdentifier: String { get }
    var reuseIdentifier: String { get }
    func decorate(_ cell: UITableViewCell)
}

extension TableCellModel {
    var reuseIdentifier: String {
        return type(of: self).reuseIdentifier
    }
}

struct InfoCell : TableCellModel {
    static let cellClass: AnyClass = InformationTableViewCell.self
    static let reuseIdentifier = "InformationTableViewCell"
    
    let title: String
    let detail: String
    let url: URL?
    
    func decorate(_ cell: UITableViewCell) {
        guard let cell = cell as? InformationTableViewCell else { return }
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = detail
        cell.isTappable = url != nil
        cell.selectionStyle = cell.isTappable ? .default : .none
    }
}

struct DeleteCell : TableCellModel {
    static let cellClass: AnyClass = DeleteTableViewCell.self
    static let reuseIdentifier = "DeleteTableViewCell"
    
    func decorate(_ cell: UITableViewCell) {
        cell.selectionStyle = .none
    }
}


// Mark: - Custom UITableViewCells
private let InformationCellReuseIdentifier = "InformationTableViewCell"
private let DeleteCellReuseIdentifier = "DeleteTableViewCell"

class InformationTableViewCell : UITableViewCell {
    
    var isTappable = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        guard let textLabel = textLabel, let detailTextLabel = detailTextLabel else {
            return
        }

        contentView.translatesAutoresizingMaskIntoConstraints = false

        textLabel.font = Style.Font.T2B
        textLabel.textColor = Style.Color.C5
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        detailTextLabel.font = Style.Font.T3R
        detailTextLabel.textColor = Style.Color.C6
        detailTextLabel.numberOfLines = 0
        detailTextLabel.lineBreakMode = .byWordWrapping
        detailTextLabel.translatesAutoresizingMaskIntoConstraints = false
        detailTextLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        trailingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 20).isActive = true
        
        detailTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        trailingAnchor.constraint(equalTo: detailTextLabel.trailingAnchor, constant: 20).isActive = true
        detailTextLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 4).isActive = true
        contentView.bottomAnchor.constraint(equalTo: detailTextLabel.bottomAnchor, constant: 0).isActive = true
        
        contentView.topAnchor.constraint(equalTo: topAnchor)
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class DeleteTableViewCell : UITableViewCell {
    
    var button : UIButton
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        button = DangerButton(frame: .zero)
        button.setTitle(Localizations.DeleteCredential, for: .normal)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 64).isActive = true
        contentView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 24).isActive = true
        button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        contentView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 20).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - View Controller

class BaseMetadataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var data = [TableCellModel]()
    
    public var delegate : CertificateViewControllerDelegate?
    private var tableView : UITableView!

    let dateFormatter = { formatter -> (DateFormatter) in
        formatter.dateStyle = .medium
        return formatter
    }(DateFormatter())

    init() {
        tableView = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = UIView()
        
        
        let tableView : UITableView = UITableView(frame: .zero, style: .plain)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.register(InfoCell.cellClass, forCellReuseIdentifier: InfoCell.reuseIdentifier)
        tableView.register(DeleteCell.cellClass, forCellReuseIdentifier: DeleteCell.reuseIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        self.tableView = tableView
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Localizations.CredentialInfo
        
        let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_close"), style: .done, target: self, action: #selector(dismissSelf))
        closeButton.accessibilityLabel = Localizations.Close
        navigationItem.rightBarButtonItem = closeButton

        tableView.separatorStyle = .none
        view.backgroundColor = Style.Color.C1
        tableView.backgroundColor = Style.Color.C1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let path = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: path, animated: true)
        }
    }

    @objc func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissSelfAfterDeletion() {
        guard let navigationController = presentingViewController as? UINavigationController, navigationController.viewControllers.count > 1 else { return }
        
        let depth = navigationController.viewControllers.count
        let popTo = depth > 2 ? navigationController.viewControllers[1] : navigationController.viewControllers.first!
        dismiss(animated: true, completion: { navigationController.popToViewController(popTo, animated: true) })
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? data.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0 else { return UITableViewCell() }

        let item = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier)!
        item.decorate(cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let cellData = data[indexPath.row] as? InfoCell,
            let url = cellData.url,
            UIApplication.shared.canOpenURL(url) else { return false }
        return cellData.url != nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellData = data[indexPath.row] as? InfoCell,
            let url = cellData.url,
            UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}


class CertificateMetadataViewController: BaseMetadataViewController {

    private let certificate : Certificate

    init(certificate: Certificate) {
        self.certificate = certificate
        super.init()
        
        let issuedOn = dateFormatter.string(from: certificate.assertion.issuedOn)
        let expirationDate = certificate.issuer.publicKeys.first?.expires
        let expiresOn = expirationDate.map { dateFormatter.string(from: $0) } ?? Localizations.Never
        
        data.append(InfoCell(title: Localizations.CredentialName, detail: certificate.title, url: nil))
        data.append(InfoCell(title: Localizations.DateIssued, detail: issuedOn, url: nil))
        data.append(InfoCell(title: Localizations.CredentialExpiration, detail: expiresOn, url: nil))
        data.append(InfoCell(title: Localizations.Description, detail: certificate.description, url: nil))
        
        let metadata : [TableCellModel] = certificate.metadata.visibleMetadata.map { metadata in
            let url : URL?
            switch metadata.type {
            case .uri:
                url = URL(string: metadata.value)
            case .email:
                url = URL(string: "mailto:\(metadata.value)")
            case .phoneNumber:
                url = URL(string: "tel:\(metadata.value)")
            default:
                url = nil
            }
            return InfoCell(title: metadata.label, detail: metadata.value, url: url)
        }
        data += metadata

        data.append(DeleteCell())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = Localizations.CredentialInfo
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let cell = cell as? DeleteTableViewCell {
            cell.button.onTouchUpInside { [weak self] in
                self?.promptForCertificateDeletion()
            }
        }
        return cell
    }

    func promptForCertificateDeletion() {
        Logger.main.info("User has tapped the delete button on this certificate.")
        let certificateToDelete = certificate
        let alert = AlertViewController.create(title: Localizations.Caution,
                                               message: Localizations.DeleteCredentialExplanation, icon: .warning)

        let okayButton = DialogButton(frame: .zero)
        okayButton.setTitle(Localizations.Delete, for: .normal)
        okayButton.onTouchUpInside { [weak self] in
            Logger.main.info("User has deleted certificate \(certificateToDelete.title) with id \(certificateToDelete.id)")
            self?.delegate?.delete(certificate: certificateToDelete)
            alert.dismiss(animated: false, completion: nil)
            self?.dismissSelfAfterDeletion()
        }
        
        let cancelButton = PrimaryButton(frame: .zero)
        cancelButton.titleLabel?.font = Style.Font.T2S
        cancelButton.setTitle(Localizations.Cancel, for: .normal)
        cancelButton.onTouchUpInside {
            Logger.main.info("User canceled the deletion of the certificate.")
            alert.dismiss(animated: false, completion: nil)
        }
        alert.set(buttons: [okayButton, cancelButton])

        present(alert, animated: false, completion: nil)
    }
    
}


class IssuerMetadataViewController : BaseMetadataViewController {
    
    private let issuer : ManagedIssuer
    
    init(issuer: ManagedIssuer) {
        self.issuer = issuer
        super.init()
        
        if let name = issuer.issuer?.name {
            data.append(InfoCell(title: Localizations.IssuerName, detail: name, url: nil))
        }
        
        if let chain = issuer.chain {
            data.append(InfoCell(title: "Chain", detail: chain, url: nil))
        }
        
        if let email = issuer.issuer?.email {
            data.append(InfoCell(title: Localizations.IssuerContactEmail, detail: email, url: URL(string: "mailto:\(email)")))
        }
        
        if let introducedOn = issuer.introducedOn {
            data.append(InfoCell(title: Localizations.IntroducedOn, detail: dateFormatter.string(from: introducedOn), url: nil))
        }
        
        if let address = issuer.introducedWithAddress {
            data.append(InfoCell(title: Localizations.SharedAddress, detail: address.scopedValue, url: nil))
        }
        
        if let urlIssuer = issuer.issuer?.id {
            data.append(InfoCell(title: "URL", detail: urlIssuer.absoluteString, url: URL(string: urlIssuer.absoluteString)))
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = Localizations.IssuerInfo
    }

}

