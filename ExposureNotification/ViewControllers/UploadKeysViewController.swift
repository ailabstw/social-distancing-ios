//
//  UploadKeysViewController.swift
//  COVID19
//
//  Created by Shiva Huang on 2020/5/18.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import SnapKit
import UIKit

class UploadKeysViewController: UIViewController, SpinnerShowable {
    private enum EditingField {
        case `none`
        case startDate
        case endDate
        case passcode
    }

    private var editingField: EditingField = .none {
        didSet {
            switch (oldValue, editingField) {
            case (.none, .startDate), (.startDate, .none), (.startDate, .passcode):
                UIView.animate(withDuration: 0.3) { [unowned self] in
                    self.startDatePicker.isHidden.toggle()
                    self.startDatePicker.alpha = self.startDatePicker.isHidden ? 0.0 : 1.0
                }

            case (.none, .endDate), (.endDate, .none), (.endDate, .passcode):
                UIView.animate(withDuration: 0.3) { [unowned self] in
                    self.endDatePicker.isHidden.toggle()
                    self.endDatePicker.alpha = self.endDatePicker.isHidden ? 0.0 : 1.0
                }

            case (.passcode, .none):
                view.endEditing(true)

            case (.startDate, .endDate), (.endDate, .startDate):
                UIView.animate(withDuration: 0.3) { [unowned self] in
                    self.startDatePicker.isHidden.toggle()
                    self.endDatePicker.isHidden.toggle()
                    self.startDatePicker.alpha = self.startDatePicker.isHidden ? 0.0 : 1.0
                    self.endDatePicker.alpha = self.endDatePicker.isHidden ? 0.0 : 1.0
                }

            case (.passcode, .startDate):
                UIView.animate(withDuration: 0.3) { [unowned self] in
                    self.view.endEditing(true)
                    self.startDatePicker.isHidden.toggle()
                    self.startDatePicker.alpha = self.startDatePicker.isHidden ? 0.0 : 1.0
                }

            case (.passcode, .endDate):
                UIView.animate(withDuration: 0.3) { [unowned self] in
                    self.view.endEditing(true)
                    self.endDatePicker.isHidden.toggle()
                    self.endDatePicker.alpha = self.endDatePicker.isHidden ? 0.0 : 1.0
                }

            case (.none, .passcode), (.passcode, .passcode), (.endDate, .endDate), (.startDate, .startDate), (.none, .none):
                break
            }
        }
    }

    private let viewModel: UploadKeysViewModel

    private lazy var dateSpanTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Localizations.UploadKeysView.dateSpanTitleLabel
        label.font = Font.title
        label.textColor = Color.title
        label.numberOfLines = 0

        return label
    }()

    private lazy var startDateButton: UIButton = {
        let button = UIButton()

        button.backgroundColor = Color.inputBackground
        button.layer.borderColor = Color.inputBorder.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 2
        button.clipsToBounds = true
        button.setTitleColor(Color.inputText, for: .normal)
        button.titleLabel?.font = Font.inputText
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        button.setTitle(Localizations.UploadKeysView.beginDateTitleLabel, for: .normal)
        button.addTarget(self, action: #selector(toggleStartDatePicker(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()

        picker.datePickerMode = .date
        //FIXME: .inline will conflict with tap gesture.
//        if #available(iOS 14, *) {
//            picker.preferredDatePickerStyle = .inline
//        } else if #available(iOS 13.4, *) {
//            picker.preferredDatePickerStyle = .wheels
//        }
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }

        picker.date = viewModel.minimumStartDate
        picker.minimumDate = viewModel.minimumStartDate
        picker.maximumDate = viewModel.maximumEndDate - 1
        picker.isHidden = true
        picker.setContentCompressionResistancePriority(.required, for: .vertical)
        picker.addTarget(self, action: #selector(startDateDidChange(_:)), for: .valueChanged)

        return picker
    }()

    private lazy var endDateButton: UIButton = {
        let button = UIButton()

        button.backgroundColor = Color.inputBackground
        button.layer.borderColor = Color.inputBorder.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 2
        button.clipsToBounds = true
        button.setTitleColor(Color.inputText, for: .normal)
        button.titleLabel?.font = Font.inputText
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        button.setTitle(Localizations.UploadKeysView.endDateTitleLabel, for: .normal)
        button.addTarget(self, action: #selector(toggleEndDatePicker(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()

        picker.datePickerMode = .date
        //FIXME: .inline will conflict with tap gesture.
//        if #available(iOS 14, *) {
//            picker.preferredDatePickerStyle = .inline
//        } else if #available(iOS 13.4, *) {
//            picker.preferredDatePickerStyle = .wheels
//        }
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        
        picker.date = viewModel.maximumEndDate - 1
        picker.minimumDate = viewModel.minimumStartDate
        picker.maximumDate = viewModel.maximumEndDate  - 1
        picker.isHidden = true
        picker.setContentCompressionResistancePriority(.required, for: .vertical)
        picker.addTarget(self, action: #selector(endDateDidChange(_:)), for: .valueChanged)

        return picker
    }()
    
    private lazy var passcodeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Localizations.UploadKeysView.passcodeTitleLabel
        label.font = Font.title
        label.textColor = Color.title
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var passcodeField: UITextField = {
        let field = UITextField()

        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8.5, height: 10))
        field.leftViewMode = .always
        field.backgroundColor = Color.inputBackground
        field.layer.borderColor = Color.inputBorder.cgColor
        field.layer.borderWidth = 0.5
        field.layer.cornerRadius = 2
        field.clipsToBounds = true
        field.textColor = Color.inputText
        field.font = Font.inputText
        field.placeholder = Localizations.UploadKeysView.passcodeFieldPlaceholder
        field.clearButtonMode = .whileEditing
        field.autocorrectionType = .no
        field.delegate = self
        field.addTarget(self, action: #selector(passcodeFieldDidBeginEditing(_:)), for: .editingDidBegin)
        field.addTarget(self, action: #selector(passcodeFieldDidChange(_:)), for: .editingChanged)
        field.addTarget(self, action: #selector(passcodeFieldDidFinish(_:)), for: .editingDidEndOnExit)
        field.returnKeyType = .done
        field.keyboardType = .numberPad
        
        return field
    }()
    
    private lazy var requestVerificationCodeButton: UIButton = {
        let button = UIButton()
        
        button.setTitle(Localizations.UploadKeysView.requestVerificationButton, for: .normal)
        button.setTitleColor(Color.requestVerificationButtonTitle, for: .normal)
        button.titleLabel?.font = Font.requestVerificationButton
        button.layer.borderColor = Color.requestVerificationButtonBorder.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapRequestCodeButton(_:)), for: .touchUpInside)
                         
        return button
    }()
    
    private lazy var introductionTextView: UITextView = {
        let view = UITextView()

        view.textAlignment = .justified
        view.font = Font.introductionText
        view.textColor = Color.introductionText
        view.text = Localizations.UploadKeysView.introductionMessage
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        view.isSelectable = false
        view.isEditable = false
        
        return view
    }()
    
    private lazy var submitButton: StyledButton = {
        let button = StyledButton(style: .major)

        if viewModel.exposureNotificationEnabled {
            button.setTitle(Localizations.Alert.Button.submit, for: .normal)
            button.addTarget(self, action: #selector(didTapSubmitButton(_:)), for: .touchUpInside)
        } else {
            button.setTitle(Localizations.UploadKeysView.exposureNotificationNotEnabled, for: .normal)
        }
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        
        
        return button
    }()
    
    init(viewModel: UploadKeysViewModel) {
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
        let stackView: UIStackView = {
            let _view = UIStackView()
            
            _view.axis = .vertical
            _view.alignment = .center
            _view.distribution = .fill
            _view.spacing = 12

            _view.addArrangedSubview(dateSpanTitleLabel)
            _view.addArrangedSubview(startDateButton)
            _view.addArrangedSubview(startDatePicker)
            _view.addArrangedSubview(endDateButton)
            _view.addArrangedSubview(endDatePicker)
            _view.addArrangedSubview(passcodeTitleLabel)
            _view.addArrangedSubview(passcodeField)
            if viewModel.exposureNotificationEnabled {
                _view.addArrangedSubview(requestVerificationCodeButton)
            }
            _view.addArrangedSubview(introductionTextView)
            _view.addArrangedSubview(submitButton)
            _view.setCustomSpacing(4, after: dateSpanTitleLabel)
            _view.setCustomSpacing(19, after: endDateButton)
            _view.setCustomSpacing(4, after: passcodeTitleLabel)
            _view.setCustomSpacing(12, after: passcodeField)
            _view.setCustomSpacing(35, after: requestVerificationCodeButton)

            dateSpanTitleLabel.snp.makeConstraints {
                $0.leading.trailing.equalTo(passcodeField)
            }

            startDateButton.snp.makeConstraints {
                $0.size.equalTo(passcodeField)
            }

            endDateButton.snp.makeConstraints {
                $0.size.equalTo(passcodeField)
            }

            passcodeTitleLabel.snp.makeConstraints {
                $0.leading.trailing.equalTo(passcodeField)
            }
            
            passcodeField.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(50)
                $0.height.equalTo(34)
            }
            
            requestVerificationCodeButton.snp.makeConstraints {
                $0.width.equalTo(240)
                $0.height.equalTo(48)
            }
            
            introductionTextView.snp.makeConstraints {
                $0.width.equalToSuperview().offset(-100)
            }
            
            submitButton.snp.makeConstraints {
                $0.width.equalTo(240)
                $0.height.equalTo(48)
            }
            
            return _view
        }()
        
        view.backgroundColor = Color.background
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-79)
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
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
                self.passcodeField.isEnabled = true
                self.submitButton.isEnabled = false
                self.stopSpinner()
                
            case .ready:
                self.passcodeField.isEnabled = true
                self.submitButton.isEnabled = true
                self.stopSpinner()
                
            case .uploading:
                self.passcodeField.isEnabled = false
                self.submitButton.isEnabled = false
                self.startSpinner()
                
            case .uploaded(let result):
                self.passcodeField.isEnabled = false
                self.submitButton.isEnabled = false
                self.stopSpinner()
                
                let message: String = {
                    switch result {
                    case .success:
                        return Localizations.Alert.Message.uploadSucceed
                    case .otherAPIFailed:
                        return Localizations.Alert.Message.uploadFailed
                    case .verifyAPIFailed:
                        return Localizations.Alert.Message.verifyAPIFailed
                    }
                }()
                
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Localizations.Alert.Button.ok, style: .default) { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                })
                self.present(alert, animated: true, completion: nil)
                
            case .waitForRetry(let reason):
                self.passcodeField.isEnabled = false
                self.submitButton.isEnabled = true
                self.stopSpinner()
                
                let message: String = {
                    switch reason {
                    case .userDenied:
                        return Localizations.Alert.Message.userDenied
                    case .couldNotGetKeys:
                        return Localizations.Alert.Message.missingKeyData
                    }
                }()
                
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Localizations.Alert.Button.ok, style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }

        viewModel.$startDate { [weak self] (date) in
            self?.startDateButton.setTitle("\(date.displayDateDescription)", for: .normal)
            self?.startDatePicker.date = date
        }

        viewModel.$endDate { [weak self] (date) in
            self?.endDateButton.setTitle("\((date - 1).displayDateDescription)", for: .normal)
            self?.endDatePicker.date = date - 1
        }
        
    }

    @objc private func toggleStartDatePicker(_ sender: UIButton) {
        editingField = editingField == .startDate ? .none : .startDate
    }

    @objc private func startDateDidChange(_ sender: UIDatePicker) {
        viewModel.startDate = Calendar.current.startOfDay(for: sender.date)
        logger.info("StartDate: \(viewModel.startDate)")
    }

    @objc private func endDateDidChange(_ sender: UIDatePicker) {
        viewModel.endDate = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: sender.date)!)
        logger.info("EndDate: \(viewModel.endDate)")
    }

    @objc private func toggleEndDatePicker(_ sender: UIButton) {
        editingField = editingField == .endDate ? .none : .endDate
    }

    @objc private func didTapSubmitButton(_ sender: StyledButton) {
        viewModel.uploadKeys()
    }
    
    @objc private func dismissKeyboard() {
        editingField = .none
    }
    
    @objc private func didTapRequestCodeButton(_ sender: UIButton) {
        guard let navigation = navigationController else { return }
        RequestVerificationCodeRouter.push(navigation)
    }
}

extension UploadKeysViewController: UITextFieldDelegate {
    @objc private func passcodeFieldDidBeginEditing(_ sender: UITextField) {
        editingField = .passcode
    }

    @objc private func passcodeFieldDidFinish(_ sender: UITextField) {
        dismissKeyboard()
    }
    
    @objc private func passcodeFieldDidChange(_ sender: UITextField) {
        viewModel.passcode = sender.text ?? ""
    }
}

extension UploadKeysViewController {
    enum Font {
        static let title = UIFont(name: "PingFangTC-Regular", size: 17.0)!
        static let inputLabel = UIFont(name: "PingFangTC-Regular", size: 17.0)!
        static let inputText = UIFont(name: "PingFangTC-Regular", size: 17.0)!
        static let introductionText = UIFont(name: "PingFangTC-Regular", size: 17.0)!
        static let privacyText = UIFont(name: "PingFangTC-Regular", size: 13.0)!
        static let requestVerificationButton = UIFont(name: "PingFangTC-Regular", size: 17.0)!
    }
    
    enum Color {
        static let background = UIColor.init(red: (235/255.0), green: (235/255.0), blue: (235/255.0), alpha: 1)
        static let title = UIColor(red: 73.0/255.0, green: 97.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        static let inputLabel = UIColor(red: 73.0/255.0, green: 97.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        static let inputBackground = UIColor.white
        static let inputBorder = UIColor(red: 159.0/255.0, green: 159.0/255.0, blue: 159.0/255.0, alpha: 1.0)
        static let inputText = UIColor.init(red: (73/255.0), green: (97/255.0), blue: (94/255.0), alpha: 1)
        static let introductionText = UIColor(red: 73.0/255.0, green: 97.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        static let text = UIColor(red: 73.0/255.0, green: 97.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        static let link = UIColor(red: 46.0/255.0, green: 182.0/255.0, blue: 169.0/255.0, alpha: 1.0)
        static let requestVerificationButtonTitle = UIColor(red: 73.0/255.0, green: 97.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        static let requestVerificationButtonBorder = UIColor(red: 73.0/255.0, green: 97.0/255.0, blue: 94.0/255.0, alpha: 1.0)
    }
}

extension Localizations {
    enum UploadKeysView {
        static let dateSpanTitleLabel = NSLocalizedString("UploadKeysView.DateSpanTitleLabel",
                                                          value: "Please Enter Start and End Dates",
                                                          comment: "The label text on upload keys view to inform user inputs the date span to upload")
        static let beginDateTitleLabel = NSLocalizedString("UploadKeysView.BeginDateTitleLabel",
                                                           value: "Start Date",
                                                           comment: "The label text on upload keys view to inform user inputs the start date to upload")
        static let endDateTitleLabel = NSLocalizedString("UploadKeysView.EndDateTitleLabel",
                                                         value: "End Date",
                                                         comment: "The label text on upload keys view to inform user inputs the end date to upload")
        static let passcodeTitleLabel = NSLocalizedString("UploadKeysView.PasscodeTitleLabel",
                                                          value: "Please Enter Verification Code",
                                                          comment: "The label text on upload keys view to inform user inputs their verification code to upload keys")
        static let passcodeFieldPlaceholder = NSLocalizedString("UploadKeysView.PasscodeFieldPlaceholder",
                                                                value: "Verification Code",
                                                                comment: "The text field placeholder text on upload keys view to inform user to input their verification code to upload keys here")
        static let introductionMessage = NSLocalizedString("UploadKeysView.IntroductionMessage",
                                                           value: "Please enter the verification code provided by the local Department of Health. After submitting, your anonymous IDs will be uploaded. These data will be stored by the Taiwan Centers for Disease Control and will be automatically deleted after 10 days.",
                                                           comment: "The message body on upload keys view for introduction")
        
        static let requestVerificationButton = NSLocalizedString("UploadKeysView.requestVerificationButton",
                                                                 value: "Get Verification Code",
                                                                 comment: "The button to request verification code")
        
        static let exposureNotificationNotEnabled = NSLocalizedString("UploadKeysView.exposureNotificationNotEnabled",
                                                                      value: "Exposure Notification Disabled",
                                                                      comment: "The Exposure Notification is not enabled")
    }
}
