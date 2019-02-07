//
//  ArchiveVC.swift
//  CodeTaker
//
//  Created by Dmitry Kuzin on 29/01/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//

import UIKit

class ArchiveVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendBtn: UIBarButtonItem!
    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    @IBOutlet weak var noCodesLbl: UILabel!
    @IBOutlet weak var selectAllBtn : UIBarButtonItem!
    
    private var codes: [Code] = [] {
        didSet {
            setLayouts()
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codes = DataManager.shared.getArchiveCodes()
    }
    
}

extension ArchiveVC {
    
    //MARK: - main functions
    func setLayouts() {
        noCodesLbl.isHidden = !codes.isEmpty
        tableView.isHidden = codes.isEmpty
        
        let selectedVals = codes.filter{ $0.isChecked }
        if selectedVals.count > 10 || selectedVals.isEmpty {
            sendBtn.isEnabled = false
        } else {
            sendBtn.isEnabled = true
        }
        
        deleteBtn.isEnabled = !selectedVals.isEmpty
        
        setSelectAllButtonTitle()
    }
    
    func setSelectAllButtonTitle() {
        let selectedVals1 = codes.filter{ $0.isChecked }
        if selectedVals1.count == 0 {
            selectAllBtn.title = "Select all"
        }
        if selectedVals1.count == codes.count {
            selectAllBtn.title = "Deselect all"
        }
    }
    
    func deleteCodes() {
        let deletedItems = codes.filter { $0.isChecked }
        deletedItems.forEach {
            DataManager.shared.deleteCode($0)
        }
        codes = DataManager.shared.getArchiveCodes()
        if selectAllBtn.title == "Deselect all" {
            selectAllBtn.title = "Select all"
        }
        tableView.reloadData()
    }
    
    func getAPI() -> String {
        if DataManager.shared.apiString.count == 0 {
            return EMPTY_STRING
        }
        var result = DataManager.shared.apiString
        let selectedVals = codes.filter{ $0.isChecked }
        for index in 0..<selectedVals.count {
            let item = selectedVals[index]
            result += "code\(index + 1)=\(item.code.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            if index != selectedVals.count - 1 {
                result += "&"
            }
        }
        print(result)
        return result
    }
}

extension ArchiveVC {
    
    //MARK: - IBActions
    @IBAction func onSendBtn(_ sender: Any) {
        let urlString = getAPI()
        
        guard urlString != EMPTY_STRING else {
            let alert = UIAlertController(title: nil, message: "Please set a URL in settings first!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let realUrl = URL(string: urlString) else {
            let alert = UIAlertController(title: nil, message: "The url you set is not correct style!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        UIApplication.shared.open(realUrl, options: [:]) { [weak self] (done) in
            guard let strongSelf = self else { return }
            if !done {
                let alert = UIAlertController(title: nil, message: "The url you set is not correct style!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                strongSelf.present(alert, animated: true, completion: nil)
            } else {
                let checked = strongSelf.codes.filter { $0.isChecked }
                checked.forEach {
                    var code = $0
                    code.isChecked = false
                    DataManager.shared.updateCode(code)
                }
                strongSelf.codes = DataManager.shared.getArchiveCodes()
            }
        }
    }
    
    @IBAction func onDeleteBtn(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Are you sure to delete?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (deleteAction) in
            self.deleteCodes()
        }
        alert.addAction(yesAction)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onSelectAllBtn(_ sender: Any) {
        guard codes.count > 0 else {
            return
        }
        let btn = sender as! UIBarButtonItem
        if btn.title == "Select all" {
            codes.lazy.forEach { (item) in
                var temp = item
                temp.isChecked = true
                if let index = codes.index(where: { $0.date == item.date && $0.code == item.code }) {
                    codes[index] = temp
                    DataManager.shared.updateCode(temp)
                }
            }
            btn.title = "Deselect all"
        } else {
            codes.lazy.forEach { (item) in
                var temp = item
                temp.isChecked = false
                if let index = codes.index(where: { $0.date == item.date && $0.code == item.code }) {
                    codes[index] = temp
                    DataManager.shared.updateCode(temp)
                }
            }
            btn.title = "Select all"
        }
    }
    
}

extension ArchiveVC: CodeCellDelegate {
    
    func didChecked(selected item: Code) -> Bool {
        let selectedVals = codes.filter{ $0.isChecked }
        if selectedVals.count >= 10 && item.isChecked {
            let alert = UIAlertController(title: nil, message: "Maximum 10 items", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return false
        }
        if let index = codes.index(where: { $0.date == item.date && $0.code == item.code }) {
            codes[index] = item
            DispatchQueue.global().async {
                DataManager.shared.updateCode(item)
            }
        }
        setSelectAllButtonTitle()
        return true
    }
    
}

extension ArchiveVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return codes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? CodeCell else {
            return UITableViewCell()
        }
        
        cell.initialize(with: codes[indexPath.row], self)
        
        return cell
    }
    
}
