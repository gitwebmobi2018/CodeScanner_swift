//
//  UserStandardService.swift
//  CodeTaker
//
//  Created by Ivan.
//  Copyright © 2019 Ivan. All rights reserved.
//

import Foundation

final class UserStandardManager {
    
    let defaults = UserDefaults.standard
    
    enum Keys: String {
        case keyCodes           = "Scanned_Codes_Array"
        case keySettingUrl      = "Setting_URL"
    }
    
    private func saveToDefaults(_ data: Any, for key: String) {
        
        do {
            var jsonData = Data()
            
            switch key {
            case Keys.keyCodes.rawValue:
                let matchesArr = data as! [Code]
                jsonData = try JSONEncoder().encode(matchesArr)
            default:
                break
            }
            
            defaults.set(jsonData, forKey: key)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func loadFromDefaults(_ key: String) -> Data? {
        return defaults.data(forKey: key)
    }
    
    func saveCodes(_ codes: [Code]) {
        do {
            let jsonData = try JSONEncoder().encode(codes)
            defaults.set(jsonData, forKey: Keys.keyCodes.rawValue)
        } catch {
            print(error)
        }
    }
    
    func saveSettingUrl(_ url: String) {
        defaults.set(url, forKey: Keys.keySettingUrl.rawValue)
    }
//    
//    private func saveObject(_ codes: [Code]?, _ settingUrl: String?) {
//        do {
//            var jsonData = Data()
//            
//            if let codesArr = codes {
//                jsonData = try JSONEncoder().encode(codesArr)
//                defaults.set(jsonData, forKey: Keys.keyCodes.rawValue)
//            }
//            
//            if let setUrl = settingUrl {
//                defaults.set(setUrl, forKey: Keys.keySettingUrl.rawValue)
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
    
    func loadCodes() -> Data? {
        return loadFromDefaults(Keys.keyCodes.rawValue)
    }
    
    func loadAPI() -> String {
        return defaults.string(forKey: Keys.keySettingUrl.rawValue) ?? String()
    }
    
}
