//
//  ViewController.swift
//  CodeTaker
//
//  Created by Ivan.
//  Copyright © 2019 Ivan. All rights reserved.
//

import UIKit

let cellId = "CodeTableViewCell"

class MainVC: UIViewController {

    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var sendBtn: UIBarButtonItem!
    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    @IBOutlet weak var noCodesLbl: UILabel!
    
    private var codesArr = [Code]() {
        didSet {
            setLayouts()
            mTableView.reloadData()
        }
    }
    
//MARK: - Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        codesArr = DataManager.shared.getActiveCodes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_SCANCODE {
            guard let vc = segue.destination as? ScanVC else {
                return
            }
            vc.delegate = self
        }
    }
    
//MARK: - main functions
    func setLayouts() {
        noCodesLbl.isHidden = !codesArr.isEmpty
        mTableView.isHidden = codesArr.isEmpty
        
        let selectedVals = codesArr.lazy.filter{ $0.isChecked }
        sendBtn.isEnabled = !selectedVals.isEmpty
        deleteBtn.isEnabled = !selectedVals.isEmpty
    }
    
    func deleteCodes() {
        let deletedItems = codesArr.filter { $0.isChecked }
        deletedItems.forEach {
            DataManager.shared.deleteCode($0)
        }
        codesArr = DataManager.shared.getActiveCodes()
        mTableView.reloadData()
    }
    
    func getAPI() -> String {
        if DataManager.shared.apiString.count == 0 {
            return EMPTY_STRING
        }
        var result = DataManager.shared.apiString
        let selectedVals = codesArr.filter{ $0.isChecked }
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
            if !done {
                let alert = UIAlertController(title: nil, message: "The url you set is not correct style!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            } else {
                guard let strongSelf = self else { return }
                let checkedCodes = strongSelf.codesArr.filter { $0.isChecked }
                
                checkedCodes.forEach {
                    var code = $0
                    code.isChecked = false
                    code.isArchive = true
                    DataManager.shared.updateCode(code)
                }
                strongSelf.codesArr = DataManager.shared.getActiveCodes()
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

}

extension MainVC: ScanVCDelegate {
//MARK: - ScanVCDelegate
    func didScanned(result code: String) {
        let existedVals = codesArr.lazy.filter{ $0.code == code }
        guard existedVals.isEmpty else {
            return
        }
        let newItem = Code(index : codesArr.count, code : code)
        codesArr.append(newItem)
        DataManager.shared.addCode(newItem)
        mTableView.reloadData()
    }
}

extension MainVC: CodeCellDelegate {
    //MARK: - CodeCellDelegate
    func didChecked(selected item: Code) -> Bool {
        let selectedVals = codesArr.lazy.filter{ $0.isChecked }
        print(selectedVals.count)
        if selectedVals.count >= 8 && item.isChecked {
            let alert = UIAlertController(title: nil, message: "Maximum 8 items", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return false
        }
        if let index = codesArr.index(where: { $0.date == item.date && $0.code == item.code }) {
            codesArr[index] = item
            DispatchQueue.global().async {
                DataManager.shared.updateCode(item)
            }
        }
        return true
    }
}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    //MARK: - Table view delegate & data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return codesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? CodeCell else {
            return UITableViewCell()
        }
        
        cell.initialize(with: codesArr[indexPath.row], self)
        
        return cell
    }
    
}
