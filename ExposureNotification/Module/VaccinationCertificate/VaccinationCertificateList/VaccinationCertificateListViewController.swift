//
//  VaccinationCertificateListViewController.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/3/24.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import CoreKit
import Foundation
import UIKit

class VaccinationCertificateListViewController: UIViewController, VaccinationCertifcateMenuShowable {
    private let viewModel: VaccinationCertificateListViewModel
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(cellWithClass: VaccinationCertificateListCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isEditing = true
        tableView.backgroundColor = .white
        tableView.allowsSelectionDuringEditing = true
        return tableView
    }()
    
    init(viewModel: VaccinationCertificateListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupBindings()
    }
    
    private func setupViews() {
        title = Localizations.VaccinationCertificateList.title
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Image.iconClose?.withRenderingMode(.alwaysOriginal),
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapClose(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Image.iconMenu?.withRenderingMode(.alwaysOriginal),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapMenu(_:)))
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        viewModel.$event { [weak self] event in
            switch event {
            case .none:
                break
            case .removeItem:
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc private func didTapClose(_ sender: AnyObject) {
        viewModel.didTapClose()
        dismiss(animated: true)
    }
    
    @objc private func didTapMenu(_ sender: AnyObject) {
        showMenu()
    }
}

extension VaccinationCertificateListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
}

extension VaccinationCertificateListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = viewModel.listModels[indexPath.row]
        VaccinationCertificateRouter.presentDetailPage(self, code: model.qrCode)
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.listModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.listModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withClass: VaccinationCertificateListCell.self, for: indexPath)
        cell.configure(by: model)
        cell.layoutIfNeeded()
        return cell
    }
    
}

extension VaccinationCertificateListViewController {
    enum Color {
        static let tintColor = UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)
    }
    
    enum Image {
        static let iconClose = UIImage(named: "iconClose")
        static let iconMenu = UIImage(named: "iconMenu")
    }
}

extension Localizations {
    enum VaccinationCertificateList {
        static let title = NSLocalizedString("VaccinationCertificate.title", value: "Vaccination Certificate", comment: "")
    }
}
