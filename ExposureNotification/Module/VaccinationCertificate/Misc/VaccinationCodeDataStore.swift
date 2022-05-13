//
//  VaccinationCodeDataStore.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/3/24.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation

protocol VaccinationCodeDataStoreObserver: AnyObject, Hashable {}

class VaccinationCodeDataStoreProvider {
    static let shared = VaccinationCodeDataStore()
}

class VaccinationCodeDataStore {
    private let cardLimit = 16
    enum Event {
        case insert(String)
        case delete(String)
        case update
        case currentIndexUpdated(Int)
    }
    
    private let userDefaultKey = "VaccinationCodeDataStore.qrCodes"
    private(set) var qrCodes: [String] {
        didSet {
            UserDefaults.standard.set(qrCodes, forKey: userDefaultKey)
        }
    }
    
    var isCardLimitAvailable: Bool {
        return qrCodes.count < cardLimit
    }
    
    private var observers: [AnyHashable: (Event) -> Void] = [:]
    
    init() {
        qrCodes = UserDefaults.standard.object(forKey: userDefaultKey) as? [String] ?? []
    }
    
    func insert(_ code: String) -> Bool {
        if qrCodes.count >= cardLimit {
            return false
        }
        
        qrCodes.append(code)
        send(.insert(code))
        return true
    }
    
    func delete(code: String) {
        guard let index = find(by: code) else {
            assertionFailure("WHY????")
            return
        }
        
        delete(index: index)
    }
    
    func delete(index: Int) {
        guard index < qrCodes.count else {
            assertionFailure()
            return
        }
        let code = qrCodes[index]
        qrCodes.remove(at: index)
        
        send(.delete(code))
    }
    
    func find(by code: String) -> Int? {
        qrCodes.firstIndex(of: code)
    }
    
    // Override the qrCodes directly
    func update(qrCodes newList: [String]) {
        qrCodes = newList
    }
    
    func updateCurrentIndex(_ index: Int) {
        let clampedIndex = max(min(qrCodes.count - 1, index), 0)
        send(.currentIndexUpdated(clampedIndex))
    }
    
    func addObserver<T: VaccinationCodeDataStoreObserver>(_ observer: T, handler: @escaping (Event) -> Void) {
        observers[observer] = handler
    }
    
    func removeObserver<T: VaccinationCodeDataStoreObserver>(_ observer: T) {
        observers.removeValue(forKey: observer)
    }
    
    private func send(_ event: Event) {
        self.observers.forEach { $0.value(event) }
    }
}
