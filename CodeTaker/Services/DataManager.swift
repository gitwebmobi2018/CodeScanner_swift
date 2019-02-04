//
//  DataManager.swift
//  CodeTaker
//
//  Created by Ivan.
//  Copyright © 2019 Ivan. All rights reserved.
//

import Foundation
import UIKit

enum Updater {
    case old
    case new
    case replace
    case delete
}

protocol DataManagerDelegate: class {
    func didUpdateMatches(_ updateMode: Updater, _ updatedItem: Code?)
}

class DataManager {
    
    static let shared = DataManager()
    
    let userStandard = UserStandardManager()
    
    var apiString = String()
    
    init() {
        getApiString()
    }
    
    func getArchiveCodes() -> [Code] {
        return getCodes().filter { $0.isArchive }.sorted { $0.date > $1.date }
    }
    
    func getLatestCodes() -> [Code] {
        let codes = getCodes().sorted { $0.date > $1.date }
        var results = [Code]()
        for i in 0..<8 {
            if i < codes.count {
                results.append(codes[i])
            }
        }
        return results
    }
    
    func getActiveCodes() -> [Code] {
        return getCodes().filter { !$0.isArchive }
    }
    
    private func getCodes() -> [Code] {
        if let data = userStandard.loadCodes() {
            do {
                let codes = (try JSONDecoder().decode([Code].self, from: data))
                return codes
            } catch {
                print(error)
                return [Code]()
            }
        } else {
            return [Code]()
        }
    }
    
    func updateCode(_ code: Code) {
        var codes = getCodes()
        if let index = codes.index(where: { $0.date == code.date && $0.code == code.code }) {
            codes.insert(code, at: index)
            codes.remove(at: index + 1)
            userStandard.saveCodes(codes)
        }
    }
    
    func addCode(_ code: Code) {
        var codes = getCodes()
        codes.append(code)
        userStandard.saveCodes(codes)
    }
    
    func deleteCode(_ code: Code) {
        var codes = getCodes()
        if let index = codes.index(where: { $0.date == code.date && $0.code == code.code }) {
            codes.remove(at: index)
            userStandard.saveCodes(codes)
        }
    }
    
    func getApiString() {
        apiString = userStandard.loadAPI()
    }
    
    func setApiString(_ text: String) {
        apiString = text
        userStandard.saveSettingUrl(apiString)
    }
}
