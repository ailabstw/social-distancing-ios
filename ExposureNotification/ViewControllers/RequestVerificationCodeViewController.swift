//
//  RequestVerificationCodeViewController.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/2/22.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import CoreKit
import Foundation
import PromiseKit
import UIKit

class RequestVerificationCodeRouter {
    static func push(_ navigation: UINavigationController, animated: Bool = true) {
        let viewModel = RequestVerificationCodeViewModel()
        let viewController = RequestVerificationCodeViewController(viewModel: viewModel)
        navigation.pushViewController(viewController, animated: animated)
    }
}

class RequestVerificationCodeViewController: UIViewController, SpinnerShowable {
    private lazy var phoneNumberTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.title
        label.font = Font.title
        label.text = Localizations.RequestVerificationCode.phoneNumberTitleLabel
        return label
    }()
    
    private lazy var phoneTextField: UITextField = {
        let field = UITextField()
        field.placeholder = Localizations.RequestVerificationCode.phoneTextFieldPlaceholder
        field.backgroundColor = Color.textFieldBackground
        field.layer.borderWidth = 0.5
        field.layer.borderColor = Color.textFieldBorder.cgColor
        field.layer.cornerRadius = 2
        field.keyboardType = .numberPad
        field.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0)
        return field
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Localizations.RequestVerificationCode.descriptionLabel
        label.textColor = Color.description
        label.font = Font.description
        label.numberOfLines = 0
        label.textAlignment = .justified
        return label
    }()
    
    private lazy var submitButton: StyledButton = {
        let button = StyledButton(style: .major)
        button.setTitle(Localizations.RequestVerificationCode.submitButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(didTapSubmitButton(_:)), for: .touchUpInside)
        return button
    }()
    
    #if DEBUG
    private lazy var clearCountButton: StyledButton = {
        let button = StyledButton(style: .urgent)
        button.setTitle("Clear", for: .normal)
        button.addTarget(self, action: #selector(didTapClearButton(_:)), for: .touchUpInside)
        return button
    }()
    #endif
    
    private let viewModel: RequestVerificationCodeViewModel
    
    init(viewModel: RequestVerificationCodeViewModel) {
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
    }
    
    private func setupViews() {
        title = Localizations.RequestVerificationCode.navigationTitle
        view.backgroundColor = Color.background
        
        view.addSubview(phoneNumberTitleLabel)
        view.addSubview(phoneTextField)
        view.addSubview(descriptionLabel)
        view.addSubview(submitButton)
        #if DEBUG
        view.addSubview(clearCountButton)
        #endif
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    }
    
    private func setupConstraints() {
        phoneNumberTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(50)
            make.bottom.equalTo(phoneTextField.snp.top).offset(-4)
        }
        
        phoneTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(34)
            make.leading.trailing.equalToSuperview().inset(50)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(50)
            make.top.equalTo(phoneTextField.snp.bottom).offset(20)
        }
        
        submitButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(48)
            make.width.equalTo(240)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(32)
        }
        
        #if DEBUG
        clearCountButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(48)
            make.width.equalTo(240)
            make.bottom.equalTo(submitButton.snp.top).offset(-32)
        }
        #endif
    }
    
    @objc func didTapView() {
        view.endEditing(true)
    }
    
    @objc func didTapSubmitButton(_ sender: StyledButton) {
        guard let phone = phoneTextField.text else { return }
        startSpinner()
        viewModel.didTapSubmitButton(phone)
            .done { [weak self] result in
                guard let self = self else { return }
                let alert = self.buildAlertController(result)
                self.present(alert, animated: true, completion: nil)
            }.ensure { [weak self] in
                self?.stopSpinner()
            }.catch { error in
                logger.error("Submit Failed, error: \(error)")
                let alert = self.buildAlertController(.failed)
                self.present(alert, animated: true, completion: nil)
            }
    }
    
    @objc func didTapClearButton(_ sender: UIButton) {
        viewModel.didTapClearButton()
    }
    
    private func buildAlertController(_ result: RequestVerificationCodeViewModel.SubmitResult) -> UIAlertController {
        let (alertTitle, message, shouldPopWhenButtonClicked): (String, String, Bool) = {
            switch result {
            case .succeed:
                return (Localizations.RequestVerificationCode.submitSucceedTitle,
                        Localizations.RequestVerificationCode.submitSucceedMessage,
                        true)
            case .failed:
                return (Localizations.RequestVerificationCode.submitFailedTitle,
                        Localizations.RequestVerificationCode.submitFailedMessage,
                        true)
            case .requestLimitExceeded:
                return (Localizations.RequestVerificationCode.submitFailedTitle,
                        Localizations.RequestVerificationCode.requestLimitExceededMessage,
                        true)
            case .invalidPhoneFormat:
                return (Localizations.RequestVerificationCode.submitFailedTitle,
                        Localizations.RequestVerificationCode.invalidPhoneFormatMessage,
                        false)
            }
        }()
        
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localizations.Alert.Button.ok, style: .default) { [weak self] _ in
            if shouldPopWhenButtonClicked {
                self?.navigationController?.popViewController(animated: true)
            }
        })
        return alert
    }
    
}

extension RequestVerificationCodeViewController {
    enum Font {
        static let title = UIFont(name: "PingFangTC-Regular", size: 17.0)
        static let description = UIFont(name: "PingFangTC-Regular", size: 17.0)
    }
    
    enum Color {
        static let title = UIColor(red: 73.0/255.0, green: 97.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        static let textFieldBackground = UIColor.white
        static let textFieldBorder = UIColor(red: 159.0/255.0, green: 159.0/255.0, blue: 159.0/255.0, alpha: 1.0)
        static let description = UIColor(red: 73.0/255.0, green: 97.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        static let background = UIColor(red: (235/255.0), green: (235/255.0), blue: (235/255.0), alpha: 1)
    }
}

extension Localizations {
    enum RequestVerificationCode {
        static let navigationTitle = NSLocalizedString("UploadKeysView.requestVerificationButton",
                                                       value: "Get Verification Code",
                                                       comment: "Title for request verification code page")
        static let phoneNumberTitleLabel = NSLocalizedString("RequestVerificationCode.phoneNumberTitleLabel",
                                                             value: "Please enter your mobile number",
                                                             comment: "Title for entering mobile number of request verification code page")
        
        static let phoneTextFieldPlaceholder = NSLocalizedString("RequestVerificationCode.phoneTextFieldPlaceholder",
                                                                 value: "Mobile Number",
                                                                 comment: "Placeholder for entering mobile number of request verification code page")
        
        static let descriptionLabel = NSLocalizedString("RequestVerificationCode.descriptionLabel",
                                                        value: "This allows user who is the COVID-19 confirmed case to receive verification code.",
                                                        comment: "Description for usage of entering mobile number")
        
        static let submitButtonTitle = NSLocalizedString("RequestVerificationCode.submitButtonTitle",
                                                         value: "Submit",
                                                         comment: "Title for submit button")
        
        static let submitSucceedTitle = NSLocalizedString("RequestVerificationCode.submitSucceedTitle",
                                                     value: "Entered mobile number successfully",
                                                     comment: "Title of alert for submission successful")
        
        static let submitFailedTitle = NSLocalizedString("RequestVerificationCode.submitFailedTitle",
                                                         value: "Enter mobile number failed",
                                                         comment: "Title of alert for submission failed")
        
        static let submitSucceedMessage = NSLocalizedString("RequestVerificationCode.submitSucceedMessage",
                                                            value: "Verification code will be sent to you via SMS in 5 minutes, please try again if you do not receive it.",
                                                            comment: "The message of alert for submission successful")
        
        static let submitFailedMessage = NSLocalizedString("RequestVerificationCode.submitFailedMessage",
                                                           value: "Connect error occurred, please try again later.",
                                                           comment: "The message of alert for submission failed when network issue occurred")
        
        static let requestLimitExceededMessage = NSLocalizedString("RequestVerificationCode.requestLimitExceededMessage",
                                                                   value: "Number of request exceeded limit, please try again tomorrow.",
                                                                   comment: "The message of alert for submission failed when request limit exceeded")
        
        static let invalidPhoneFormatMessage = NSLocalizedString("RequestVerificationCode.invalidPhoneFormatMessage",
                                                                 value: "Invalid mobile number, please re-enter.",
                                                                 comment: "The message of alert for submission failed when invalid phone format")
    }
}
