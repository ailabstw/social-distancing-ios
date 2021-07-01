//
//  UploadKeysViewController.swift
//  COVID19
//
//  Created by Shiva Huang on 2020/5/18.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import SnapKit
import UIKit

class UploadKeysViewController: UIViewController {
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

        button.setTitle(Localizations.Alert.Button.submit, for: .normal)
        button.addTarget(self, action: #selector(didTapSubmitButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()

        spinner.style = {
            if #available(iOS 13.0, *) {
                return .large
            } else {
                return .whiteLarge
            }
        }()
        
        return spinner
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
            _view.addArrangedSubview(introductionTextView)
            _view.addArrangedSubview(submitButton)
            _view.setCustomSpacing(4, after: dateSpanTitleLabel)
            _view.setCustomSpacing(19, after: endDateButton)
            _view.setCustomSpacing(4, after: passcodeTitleLabel)
            _view.setCustomSpacing(35, after: passcodeField)

            dateSpanTitleLabel.snp.makeConstraints {
                $0.leading.equalTo(introductionTextView)
            }

            startDateButton.snp.makeConstraints {
                $0.size.equalTo(passcodeField)
            }

            endDateButton.snp.makeConstraints {
                $0.size.equalTo(passcodeField)
            }

            passcodeTitleLabel.snp.makeConstraints {
                $0.leading.equalTo(introductionTextView)
            }
            
            passcodeField.snp.makeConstraints {
                $0.width.equalTo(240)
                $0.height.equalTo(34)
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
        view.addSubview(spinner)
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-79)
        }
        
        spinner.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
                self.spinner.stopAnimating()
                
            case .ready:
                self.passcodeField.isEnabled = true
                self.submitButton.isEnabled = true
                self.spinner.stopAnimating()
                
            case .uploading:
                self.passcodeField.isEnabled = false
                self.submitButton.isEnabled = false
                self.spinner.startAnimating()
                
            case .uploaded(let success):
                self.passcodeField.isEnabled = false
                self.submitButton.isEnabled = false
                self.spinner.stopAnimating()

                let alert = UIAlertController(title: nil, message: "\(success ? Localizations.Alert.Message.uploadSucceed : Localizations.Alert.Message.uploadFailed)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Localizations.Alert.Button.ok, style: .default) { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                })
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
    }
}
