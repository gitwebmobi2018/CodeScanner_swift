//
//  SettingVC.swift
//  CodeTaker
//
//  Created by Ivan.
//  Copyright © 2019 Ivan. All rights reserved.
//

import UIKit

class SettingVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextViewLayout()
    }
    
    func setTextViewLayout() {
        textView.layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 10
        textView.text = DataManager.shared.apiString
    }
    
    @IBAction func onSaveBtn(_ sender: Any) {
        DataManager.shared.setApiString(textView.text)
        navigationController?.popViewController(animated: true)
    }

}
