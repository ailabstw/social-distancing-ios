//
//  VaccinationCertificateListCell.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/3/24.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import UIKit

class VaccinationCertificateListCell: UITableViewCell {
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.name
        label.font = Font.name
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var doseDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.doseDate
        label.font = Font.doseDate
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(doseDateLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(doseDateLabel.snp.leading).offset(-6).priority(.low)
        }
        
        doseDateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(by model: VaccinationCertificateListModel) {
        nameLabel.text = model.displayname
        doseDateLabel.text = "\(Localizations.VaccinationCertificateListCell.doseDate)\(model.doseDate)"
    }
}

extension VaccinationCertificateListCell {
    enum Color {
        static let doseDate = UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)
        static let name = UIColor(red: 0/255, green: 0/255, blue: 94/255, alpha: 1)
    }
    
    enum Font {
        static let doseDate = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        static let name = UIFont(size: 17, weight: .regular)
    }
}

extension Localizations {
    enum VaccinationCertificateListCell {
        static let doseDate = NSLocalizedString("VaccinationCertificateListCell.doseDate", comment: "")
    }
}
