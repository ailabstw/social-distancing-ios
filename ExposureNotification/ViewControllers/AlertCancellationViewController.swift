//
//  UploadKeysViewController.swift
//  COVID19
//
//  Created by Shiva Huang on 2020/5/18.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import SnapKit
import UIKit

class AlertCancellationViewController: UIViewController, SpinnerShowable {
    private let viewModel: AlertCancellationViewModel
    
    private lazy var confirmedCheckbox: Checkbox = {
        let checkBox = Checkbox()
        checkBox.tapHandler = { [weak self] isChecked in
            self?.viewModel.didTapCheckbox(isChecked)
        }
        return checkBox
    }()
    
    private lazy var confirmedLabel: UILabel = {
        let label = UILabel()
        label.font = Font.confirmedLabel
        label.textColor = Color.disabledConfirmedLabel
        label.text = Localizations.AlertCancellationView.checkboxLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var cancelAlertButton: UIButton = {
        let button = StyledButton(style: .major)
        button.setTitle(Localizations.AlertCancellationView.cancelAlertButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(didTapCancelAlertButton(_:)), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        return button
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        view.isSelectable = false
        view.isEditable = false
        view.delegate = self
        view.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.attributedText = formatDescription()
        return view
    }()
    
    init(viewModel: AlertCancellationViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureViewModel()
    }

    private func configureView() {
        
        view.backgroundColor = Color.background
        
        view.addSubview(descriptionTextView)
        view.addSubview(confirmedCheckbox)
        view.addSubview(confirmedLabel)
        view.addSubview(cancelAlertButton)
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(confirmedLabel.snp.top).offset(-20)
        }
        
        confirmedLabel.snp.makeConstraints { make in
            make.left.equalTo(confirmedCheckbox.snp.right).offset(10)
            make.right.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.bottom.equalTo(cancelAlertButton.snp.top).offset(-30)
        }
        
        confirmedCheckbox.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.width.equalTo(24)
            make.centerY.equalTo(confirmedLabel)
        }
        
        cancelAlertButton.snp.makeConstraints { make in
            make.width.equalTo(240)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    private func configureViewModel() {
        viewModel.$title { [weak self] (title) in
            self?.title = title
        }
        
        viewModel.$status { [weak self] (status) in
            guard let self = self else {
                return
            }
            
            switch status {
            case .notReady:
                self.cancelAlertButton.isEnabled = false
                self.stopSpinner()
                
            case .ready:
                self.cancelAlertButton.isEnabled = true
                self.stopSpinner()
                
            case .cancelled:
                self.cancelAlertButton.isEnabled = false
                self.stopSpinner()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @objc private func didTapCancelAlertButton(_ sender: StyledButton) {
        let alert = UIAlertController(title: Localizations.AlertCancellationView.confirmAlertTitle, message: "\(Localizations.AlertCancellationView.confirmAlertMessage)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localizations.Alert.Button.cancel, style: .default) { _ in })
        alert.addAction(UIAlertAction(title: Localizations.Alert.Button.ok, style: .default) { [weak self] _ in
            self?.viewModel.cancelAlert()
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    private func formatDescription() -> NSAttributedString {
        let originText = ServerConfigManager.shared.configuredText?.alertCancellationInfo ?? Localizations.AlertCancellationView.description
        let sentences = originText.split(separator: "\n")

        return sentences.enumerated()
            .map {
                let indexPrefix = "\($0.offset + 1). "
                return NSMutableAttributedString(string:"\(indexPrefix)\($0.element)", attributes: getAttributes(with: indexPrefix))
            }
            .reduce(into: NSMutableAttributedString()) { (result, element: NSMutableAttributedString) in
                if result.length != 0 {
                    result.append(NSAttributedString(string: "\n"))
                }
                result.append(element)
            }
    }
    
    private func getAttributes(with headString: String) -> [NSAttributedString.Key: Any] {
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = Font.descriptionText
        attributes[.foregroundColor] = Color.descriptionText
        attributes[.paragraphStyle] = {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.headIndent = (headString as NSString).size(withAttributes: attributes).width
            paragraphStyle.lineSpacing = 6
            paragraphStyle.alignment = .left
            return paragraphStyle
        }()
        return attributes
    }
}

extension AlertCancellationViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height - 20) {
            confirmedCheckbox.isEnabled = true
            confirmedLabel.textColor = Color.confirmedLabel
        } else {
            confirmedCheckbox.isEnabled = false
            confirmedLabel.textColor = Color.disabledConfirmedLabel
        }
    }
}

extension AlertCancellationViewController {
    enum Font {
        static let title = UIFont(name: "PingFangTC-Regular", size: 17.0)!
        static let confirmedLabel = UIFont(name: "PingFangTC-Regular", size: 17.0)!
        static let descriptionText = UIFont(name: "PingFangTC-Regular", size: 17.0)!
    }
    
    enum Color {
        static let background = UIColor(red: (235/255.0), green: (235/255.0), blue: (235/255.0), alpha: 1)
        static let title = UIColor(red: 73.0/255.0, green: 97.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        static let descriptionText = UIColor(red: 73.0/255.0, green: 97.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        static let confirmedLabel = UIColor(red: 73.0/255.0, green: 97.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        static let disabledConfirmedLabel = UIColor.lightGray
    }
}

extension Localizations {
    enum AlertCancellationView {
        static let checkboxLabel = NSLocalizedString("AlertCancellationView.checkboxLabel",
                                                     value: "",
                                                     comment: "The label text on alert cancellation view to ensure the infomation has read")
        static let cancelAlertButtonTitle = NSLocalizedString("AlertCancellationView.Title",
                                                              value: "",
                                                              comment: "The button title on alert cancellation view to execute cancellation")
        static let confirmAlertTitle = NSLocalizedString("AlertCancellationView.Title",
                                                         value: "",
                                                         comment: "The title on alert to confirm alert cancellation")
        static let confirmAlertMessage = NSLocalizedString("AlertCancellationView.confirmAlertMessage",
                                                           value: "",
                                                           comment: "The message on alert to confirm alert cancellation")
        static let cancelledAlertTitle = NSLocalizedString("AlertCancellationView.cancelledAlertTitle",
                                                           value: "",
                                                           comment: "The title on alert to indicate the alert is cancelled")
        static let description = NSLocalizedString("AlertCancellationView.description",
                                                    value: "Please enter the verification code provided by the local Department of Health. After submitting, the warning will be disabled.",
                                                    comment: "The introduction text on alert cancellation view to inform user what this view is for")
    }
}
