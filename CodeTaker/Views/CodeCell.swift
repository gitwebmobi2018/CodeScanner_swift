//
//  CodeCell.swift
//  CodeTaker
//
//  Created by Ivan.
//  Copyright © 2019 Ivan. All rights reserved.
//

import UIKit
import BEMCheckBox

protocol CodeCellDelegate {
    func didChecked(selected item: Code) -> Bool
}

class CodeCell: UITableViewCell {
    
    @IBOutlet weak var codeLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var checkBox : BEMCheckBox!
    
    var delegate : CodeCellDelegate?
    
    var codeItem : Code!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupLayouts() {
        checkBox.boxType = .circle
        checkBox.onAnimationType = .flat
        checkBox.offAnimationType = .flat
        checkBox.setOn(codeItem.isChecked, animated: false)
        
        codeLbl.text = codeItem.code
        dateLbl.text = codeItem.getDateString()
    }
    
    @IBAction func onCheckBox(_sender: Any) {
        codeItem.isChecked = checkBox.on
        if !(delegate?.didChecked(selected: codeItem))! {
            if checkBox.on {
                checkBox.setOn(false, animated: false)
                codeItem.isChecked = false
            }
        }
    }
    
    func initialize(with item: Code, _ target: CodeCellDelegate) {
        delegate = target
        codeItem = item
        setupLayouts()
    }

}
