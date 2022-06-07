//
//  VaccinationCertificateDetailViewController.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/3/25.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreKit

class VaccinationCertificateDetailViewController: UIViewController, VaccinationCertifcateMenuShowable {
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = .zero
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(cellWithClass: VaccinationCertificateDetailCell.self)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    private lazy var goPrevButton: UIButton = {
        let button = StyledButton(style: .major)
        button.setImage(Image.prevArrow, for: .normal)
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(didTapPrev(_:)), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        return button
    }()
    
    private lazy var goNextButton: UIButton = {
        let button = StyledButton(style: .major)
        button.setImage(Image.nextArrow, for: .normal)
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(didTapNext(_:)), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
        return button
    }()
    
    private var observers: [NSObjectProtocol] = []
    private var brightness: CGFloat = 0.5
    private let viewModel: VaccinationCertificateDetailViewModel
    
    init(viewModel: VaccinationCertificateDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        observers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupBinding()
        
        observers.append(NotificationCenter.default.addObserver(forName: .didBecomeActiveNotification, object: nil, queue: nil) { [unowned self] (_) in
            self.brightness = UIScreen.main.brightness
            UIScreen.main.brightness = 0.9
        })
        
        observers.append(NotificationCenter.default.addObserver(forName: .willResignActiveNotification, object: nil, queue: nil) { [unowned self] (_) in
            UIScreen.main.brightness = self.brightness
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        brightness = UIScreen.main.brightness
        UIScreen.main.brightness = 0.9
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.scrollToItem(at: IndexPath(row: viewModel.currentCodeIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIScreen.main.brightness = brightness
    }
    
    private func setupViews() {
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = Localizations.VaccinationCertificateDetail.title
            label.adjustsFontSizeToFitWidth = true
            label.textColor = Color.barTitle
            label.font = Font.barTitle
            return label
        }()
        
        navigationItem.titleView = titleLabel
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Image.iconClose?.withRenderingMode(.alwaysOriginal),
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapClose(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Image.iconMenu?.withRenderingMode(.alwaysOriginal),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapMenu(_:)))
        
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        view.addSubview(goPrevButton)
        view.addSubview(goNextButton)
        
        checkDisplayMode()
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        goPrevButton.snp.makeConstraints { make in
            make.height.width.equalTo(35)
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(110)
        }
        
        goNextButton.snp.makeConstraints { make in
            make.height.width.equalTo(35)
            make.trailing.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(110)
        }
        
    }
    
    private func setupBinding() {
        viewModel.$hasNextCode { [weak self] hasNext in
            self?.goNextButton.isEnabled = hasNext
        }
        
        viewModel.$hasPrevCode { [weak self] hasPrev in
            self?.goPrevButton.isEnabled = hasPrev
        }
        
        viewModel.$event { [weak self] event in
            switch event {
            case .scrollToIndex(let index):
                self?.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
            case .itemRemoved(let index):
                self?.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                self?.checkDisplayMode()
            case .none:
                break
            }
        }
        
    }
    
    private func checkDisplayMode() {
        switch viewModel.displayMode {
        case .none:
            dismiss(animated: true, completion: nil)
        case .normal:
            goPrevButton.isHidden = false
            goNextButton.isHidden = false
        case .single:
            goPrevButton.isHidden = true
            goNextButton.isHidden = true
        }
    }
    
    @objc private func didTapClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapPrev(_ sender: UIButton) {
        viewModel.goPrevCode()
    }
    
    @objc private func didTapNext(_ sender: UIButton) {
        viewModel.goNextCode()
    }
    
    private func didTapDelete(_ model: VaccinationCertificateDetailModel) {
        let alert = UIAlertController(title: Localizations.VaccinationCertificateDetail.deleteAlertTitle,
                                      message: Localizations.VaccinationCertificateDetail.deleteAlertMessage(name: model.name),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localizations.Alert.Button.no, style: .default, handler: { _ in }))
        alert.addAction(UIAlertAction(title: Localizations.Alert.Button.yes, style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.deleteCode(model.qrCode)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func didTapMenu(_ sender: AnyObject) {
        showMenu()
    }
    
}

extension VaccinationCertificateDetailViewController {
    enum Font {
        static let barTitle = UIFont(size: 20, weight: .semibold)
    }
    
    enum Color {
        static let tintColor = UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)
        static let barTitle = UIColor(red: (73/255.0), green: (97/255.0), blue: (94/255.0), alpha: 1)
    }
    
    enum Image {
        static let iconClose = UIImage(named: "iconClose")
        static let iconMenu = UIImage(named: "iconMenu")
        static let prevArrow = UIImage(named: "iconArrowLeft")
        static let nextArrow = UIImage(named: "iconArrowRight")
    }
}

extension VaccinationCertificateDetailViewController: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let nearestIndex = Int(CGFloat(targetContentOffset.pointee.x) / scrollView.bounds.width)
        let clampedIndex = max(min(nearestIndex, viewModel.models.count - 1), 0)
        viewModel.didScrollToIndex(clampedIndex)
    }
}

extension VaccinationCertificateDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = viewModel.models[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withClass: VaccinationCertificateDetailCell.self, for: indexPath)
        cell.configure(model: model, properties: viewModel.buildVaccinationProperties(by: model))
        cell.deletionHandler = { [weak self] in
            self?.didTapDelete(model)
        }
        cell.layoutIfNeeded()
        return cell
    }
}

extension VaccinationCertificateDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension Localizations {
    enum VaccinationCertificateDetail {
        static let title = NSLocalizedString("VaccinationCertificate.title", value: "Vaccination Certificate", comment: "")
        static let deleteButton = NSLocalizedString("VaccinationCertificate.deleteButton", value: "Remove this vaccination certificate", comment: "")
        static let deleteAlertTitle = NSLocalizedString("VaccinationCertificateDetail.deleteAlertTitle", value: "Are you sure you want to remove it?", comment: "")
        
        static func deleteAlertMessage(name: String) -> String {
            return String(format: NSLocalizedString("VaccinationCertificateDetail.deleteAlertMessage", value: "Are you sure you wan to remove %@ vaccination certificate?", comment: ""), name)
        }
    }
}
