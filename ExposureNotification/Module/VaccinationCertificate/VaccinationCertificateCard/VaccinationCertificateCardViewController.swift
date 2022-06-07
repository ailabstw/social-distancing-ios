//
//  VaccinationCertificateCardViewController.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/3/17.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import CoreKit
import Foundation
import SafariServices
import UIKit

protocol VaccinationCertifcateMenuShowable where Self: UIViewController {
    func showMenu()
}

extension VaccinationCertifcateMenuShowable {
    func showMenu() {
        let alert = UIAlertController(title: Localizations.VaccinationCertificateCard.menu, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: Localizations.VaccinationCertificateCard.apply, style: .default) { [weak self] action in
            self?.present(SFSafariViewController(viewModel: .applyVaccinationCertificate), animated: true, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: Localizations.VaccinationCertificateCard.appointment, style: .default) { [weak self] action in
            self?.present(SFSafariViewController(viewModel: .bookingVaccination), animated: true, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: Localizations.VaccinationCertificateCard.faq, style: .default) { [weak self] action in
            self?.present(SFSafariViewController(viewModel: .vaccinationCertificateFAQ), animated: true, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: Localizations.Alert.Button.cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

class VaccinationCertificateCardViewController: UIViewController, VaccinationCertifcateMenuShowable {
    private let viewModel: VaccinationCertificateCardViewModel
    private lazy var emptyView = VaccinationCertificateEmptyView()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = .zero
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }()
    
    private let cardContentInset: CGFloat = 30
    private lazy var cardCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(cellWithClass: VaccinationCertificateCardCell.self)
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast
        collectionView.contentInset = UIEdgeInsets(top: 0, left: cardContentInset, bottom: 0, right: cardContentInset)
        collectionView.decelerationRate = .fast
        return collectionView
    }()
    
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = Localizations.VaccinationCertificateCard.hint
        label.textColor = Color.hintLabel
        label.font = Font.hintLabel
        label.isHidden = true
        return label
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = Color.pageControlIndicator
        pageControl.addTarget(self, action: #selector(pageControlIndexDidChange(_:)), for: .valueChanged)
        pageControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        return pageControl
    }()
    
    private lazy var openListButton: UIButton = {
        let button = UIButton()
        button.setImage(Image.iconList, for: .normal)
        button.backgroundColor = Color.openListButtonBackground
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(didTapListButton(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var openScannerButton: UIButton = {
        let button = UIButton()
        button.setImage(Image.iconQRCodeAdd, for: .normal)
        button.backgroundColor = Color.openScannerButtonBackground
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(didTapScannerButton(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private var cardSize: CGSize = .zero
    
    init(viewModel: VaccinationCertificateCardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        setupConstraints()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
        pageControl.layoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardSize = CGSize(width: cardCollectionView.bounds.width - 60, height: cardCollectionView.bounds.height)
    }
    
    private func setupNavigation() {
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = Localizations.VaccinationCertificateCard.title
            label.adjustsFontSizeToFitWidth = true
            label.textColor = Color.barTitle
            label.font = Font.barTitle
            return label
        }()
        
        navigationItem.titleView = titleLabel
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Image.iconClose?.withRenderingMode(.alwaysOriginal),
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapClose(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Image.iconMenu?.withRenderingMode(.alwaysOriginal),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapMenu(_:)))
    }
    
    private func setupViews() {
        view.backgroundColor = Color.background
        
        view.addSubview(cardCollectionView)
        view.addSubview(hintLabel)
        view.addSubview(pageControl)
        view.addSubview(openListButton)
        view.addSubview(openScannerButton)
        
    }
    
    private func setupConstraints() {
        cardCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(38)
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(cardCollectionView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        openListButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.height.width.equalTo(35)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
        }
        
        openScannerButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.height.width.equalTo(35)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
        }
    }
    
    private func setupBinding() {
        viewModel.$state { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .empty:
                self.view.addSubview(self.emptyView)
                self.emptyView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                self.emptyView.delegate = self
                self.hintLabel.isHidden = true
                self.openListButton.isHidden = true
                self.openScannerButton.isHidden = true
            case .normal:
                self.emptyView.removeFromSuperview()
                self.emptyView.delegate = nil
                self.pageControl.numberOfPages = self.viewModel.cardModels.count
                self.hintLabel.isHidden = false
                self.openListButton.isHidden = false
                self.openScannerButton.isHidden = false
            }
        }
        
        viewModel.$event { [weak self] event in
            switch event {
            case .none:
                break
            case .scrollToIndex(let index):
                self?.cardCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
                self?.pageControl.currentPage = index
            case .refreshCards:
                self?.cardCollectionView.reloadData()
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
    
    @objc private func didTapListButton(_ sender: UIButton) {
        VaccinationCertificateRouter.presentListPage(self)
    }
    
    @objc private func didTapScannerButton(_ sender: UIButton) {
        presentQRCodeScanner()
    }
    
    @objc private func pageControlIndexDidChange(_ sender: UIPageControl) {
        cardCollectionView.scrollToItem(at: IndexPath(row: pageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    private func presentQRCodeScanner() {
        guard viewModel.isCardLimitAvailable else {
            let alert = UIAlertController(title: Localizations.VaccinationCertificateCard.cardsLimitExceeded, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Localizations.Alert.Button.ok, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        CameraService.shared.requestAuthorizationIfNeeded(completion: { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .authorized:
                VaccinationCertificateRouter.presentQRCodeScanner(self)
            case .unauthorized:
                let alert = UIAlertController(title: Localizations.AccessCameraAlert.title,
                                              message: Localizations.AccessCameraAlert.message,
                                              preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: Localizations.Alert.Button.notAllow,
                                              style: .cancel,
                                              handler: nil))
                alert.addAction(UIAlertAction(title: Localizations.Alert.Button.ok,
                                              style: .default,
                                              handler: { _ in
                                                AppCoordinator.shared.openSettingsApp()
                                              }))

                self.present(alert, animated: true, completion: nil)
            case .unsupported:
                break
            }
        })
    }
}

extension VaccinationCertificateCardViewController: VaccinationCertificateEmptyViewDelegate {
    func handleAddAction() {
        presentQRCodeScanner()
    }
}

extension VaccinationCertificateCardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cardModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cardModel = viewModel.cardModels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withClass: VaccinationCertificateCardCell.self, for: indexPath)
        cell.configure(by: cardModel)
        cell.layoutIfNeeded()
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let nearestIndex = Int(CGFloat(targetContentOffset.pointee.x) / cardSize.width + 0.5)
        let clampedIndex = max(min(nearestIndex, viewModel.cardModels.count - 1), 0)
        pageControl.currentPage = clampedIndex
        let xOffset = CGFloat(clampedIndex) * cardSize.width
        targetContentOffset.pointee.x = xOffset - cardContentInset
    }
    
}

extension VaccinationCertificateCardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = viewModel.cardModels[indexPath.row]
        VaccinationCertificateRouter.presentDetailPage(self, code: model.qrCode)
    }
}

extension VaccinationCertificateCardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cardSize
    }
}

extension VaccinationCertificateCardViewController {
    enum Font {
        static let hintLabel = UIFont(size: 13, weight: .regular)
        static let barTitle = UIFont(size: 20, weight: .semibold)
    }
    
    enum Color {
        static let background = UIColor(red: (235/255.0), green: (235/255.0), blue: (235/255.0), alpha: 1)
        static let hintLabel = UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)
        static let pageControlIndicator = UIColor(red: 46/255, green: 182/255, blue: 169/255, alpha: 1)
        static let openListButtonBackground = UIColor(red: 46/255, green: 182/255, blue: 169/255, alpha: 1)
        static let openScannerButtonBackground = UIColor(red: 46/255, green: 182/255, blue: 169/255, alpha: 1)
        static let barTitle = UIColor(red: (73/255.0), green: (97/255.0), blue: (94/255.0), alpha: 1)
    }
    
    enum Image {
        static let iconList = UIImage(named: "iconList")
        static let iconClose = UIImage(named: "iconClose")
        static let iconMenu = UIImage(named: "iconMenu")
        static let iconQRCodeAdd = UIImage(named: "iconQRCodeAdd")
    }
}

extension Localizations {
    enum VaccinationCertificateCard {
        static let title = NSLocalizedString("VaccinationCertificate.title", value: "Vaccination Certificate", comment: "")
        static let hint = NSLocalizedString("VaccinationCertificate.hint", value: "Valid in combination with a government issued ID", comment: "")
        static let menu = NSLocalizedString("RiskStatusView.MoreActionSheet.Title", value: "More", comment: "")
        static let faq = NSLocalizedString("VaccinationCertificateCard.faq", value: "FAQ", comment: "")
        static let appointment = NSLocalizedString("VaccinationCertificateCard.appointment", value: "Vaccination Appointment", comment: "")
        static let apply = NSLocalizedString("VaccinationCertificateCard.apply", value: "Apply for vaccination certificate", comment: "")
        static let cardsLimitExceeded = NSLocalizedString("VaccinationCertificateCard.cardsLimitExceeded", value: "Exceeded vaccination certificates limits.", comment: "")
    }
}
