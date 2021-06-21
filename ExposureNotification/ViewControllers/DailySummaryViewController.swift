//
//  DailySummaryViewController.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/6/2.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import SnapKit
import UIKit

class DailySummaryViewController: UIViewController {
    private let viewModel: DailySummaryViewModel

    private lazy var lastCheckTimeLabel: UILabel = {
        let label = UILabel()

        label.font = Font.lastCheckTime
        label.textColor = Color.text
        
        return label
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView()

        view.dataSource = self
        view.backgroundColor = .clear
        view.tableFooterView = UIView()
        view.alwaysBounceVertical = false
        view.rowHeight = 60
        view.allowsSelection = false
        view.register(cellWithClass: DaySummaryCell.self)

        return view
    }()

    init(viewModel: DailySummaryViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(* ,unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background
        view.addSubview(lastCheckTimeLabel)
        view.addSubview(tableView)

        lastCheckTimeLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(lastCheckTimeLabel.snp.bottom).offset(15)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        viewModel.$title { [weak self] (title) in
            self?.title = title
        }

        viewModel.$updateTimeString { [weak self] (lastCheckTime) in
            self?.lastCheckTimeLabel.text = lastCheckTime
        }

        viewModel.$daySummaries { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
}

// MARK: - Table view data source
extension DailySummaryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.daySummaries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: DaySummaryCell.self, for: indexPath)

        cell.viewModel = viewModel.daySummaries[indexPath.row]

        return cell
    }
}

class DaySummaryCell: UITableViewCell {
    var viewModel: DaySummaryCellViewModel? {
        didSet {
            textLabel?.text = viewModel?.dateString
            exposureDurationLabel.text = viewModel?.exposureDurationString
            textLabel?.textColor = viewModel?.isRisky == true ? Color.warning : Color.normal
            exposureDurationLabel.textColor = viewModel?.isRisky == true ? Color.warning : Color.normal
        }
    }

    private lazy var exposureDurationLabel: UILabel = {
        let label = UILabel()

        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = .clear
        self.contentView.addSubview(exposureDurationLabel)

        exposureDurationLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(textLabel!)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DailySummaryViewController {
    enum Color {
        static let background = UIColor(red: (235/255.0), green: (235/255.0), blue: (235/255.0), alpha: 1)
        static let text = UIColor(red: (73/255.0), green: (97/255.0), blue: (94/255.0), alpha: 1)
    }

    enum Font {
        static let lastCheckTime = UIFont(name: "PingFangTC-Regular", size: 13.0)!
    }
}

extension DaySummaryCell {
    enum Color {
        static let warning = UIColor(red: (217/255.0), green: (115/255.0), blue: (115/255.0), alpha: 1)
        static let normal = UIColor(red: (73/255.0), green: (97/255.0), blue: (94/255.0), alpha: 1)
    }
}
