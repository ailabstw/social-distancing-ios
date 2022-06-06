//
//  TableViewCellViewModel.swift
//  COVID19
//
//  Created by Shiva Huang on 2020/5/28.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import CoreKit
import Foundation

protocol TableViewCellViewModel {
    var title: String { get }
}

class TogglableCellViewModel: TableViewCellViewModel {
    enum State {
        case on
        case off
        case processing
    }
    
    let title: String
    
    @Observed(queue: .main)
    var state: State = .off
    
    @Observed(queue: .main)
    var isEnabled: Bool = true
    
    init(title: String, state: State) {
        self.title = title
        self.state = state
    }
    
    func toggle() {
        switch state {
        case .off:
            state = .on
            
        default:
            state = .off
        }
    }
}

protocol TappableCellViewModel: TableViewCellViewModel {
    var tapHandler: (() -> ())? { get set }
}

class SettingTappableCellViewModel: TappableCellViewModel {
    let title: String
    let type: SettingType
    var tapHandler: (() -> ())?
    
    init(title: String, type: SettingType) {
        self.title = title
        self.type = type
    }
}

enum SettingType {
    case introduction
    case dataProtection
    case faq
    case replayHints
}
