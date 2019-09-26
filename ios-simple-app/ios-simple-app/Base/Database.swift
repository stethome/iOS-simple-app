//
//  Database.swift
//  ios-simple-app
//
//  Created by Maciej Jurgielanis on 25/09/2019.
//  Copyright © 2019 StethoMe. All rights reserved.
//

import Foundation
import StethoMeSDK

/// In real app you would want to use CoreData, Realm or similar 'real' databases, but for testing purposes, simple UserDefaults are enough.
class Database {
    private init() {}
    static let instance = Database()
    private let storage = UserDefaults.standard
    
    private let consentsModelKey = "consents_model_key"
    private let consentsDontShowAgainKey = "consents_dont_show_again_key"
    
}

// MARK: - Consents
extension Database {
    func getConsents() -> SMConsents? {
        //we get previously stored consents
        guard let stored = storage.data(forKey: consentsModelKey) else { return nil }
        //decode data into 'SMConsents' type
        guard let decodedConsents = try? JSONDecoder().decode(SMConsents.self, from: stored) else { return nil }
        return decodedConsents
    }
    
    func storeConsents(_ value: SMConsents) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        storage.set(data, forKey: consentsModelKey)
    }
    
    func getDontShowAgain() -> Bool {
        return storage.bool(forKey: consentsDontShowAgainKey)
    }
    
    func storeDontShowAgain(_ value: Bool) {
        storage.set(value, forKey: consentsDontShowAgainKey)
    }
}
