//
//  ScanVC.swift
//  CodeTaker
//
//  Created by Ivan.
//  Copyright © 2019 Ivan. All rights reserved.
//

import UIKit
import MTBBarcodeScanner

enum Scanner {
    case started
    case scanned
    case noPermission
    case error
}

protocol ScanVCDelegate {
    func didScanned(result code: String)
}

class ScanVC: UIViewController {

    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var flashSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    
    private var results: [Code] = []
    
    var delegate : ScanVCDelegate?
    
    var scanner : MTBBarcodeScanner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureScanner()
        updateResults()
    }
    
    func updateResults() {
        results = DataManager.shared.getLatestCodes()
        tableView.reloadData()
    }
    
    func configureScanner() {
        preview.layer.cornerRadius = 10
        preview.layer.masksToBounds = true
        scanner = MTBBarcodeScanner(metadataObjectTypes: [AVMetadataObject.ObjectType.ean13.rawValue,
                                                          AVMetadataObject.ObjectType.ean8.rawValue,
                                                          AVMetadataObject.ObjectType.code128.rawValue],
                                    previewView: preview)
        MTBBarcodeScanner.requestCameraPermission { (granted) in
            if granted {
                do {
                    self.flashSwitch.isOn = self.scanner.torchMode == .on
                    try self.scanner.startScanning(resultBlock: { (codes) in
                        if let fCode = codes?.first {
                            self.didScan(result: fCode.stringValue ?? EMPTY_STRING)
                        }
                    })
                } catch {
                    self.setStatusLbl(error.localizedDescription, scanner: .error)
                }
            } else {
                self.setStatusLbl(NO_PERMISSION_CAMERA, scanner: .noPermission)
            }
        }
        
        scanner.didStartScanningBlock = {
            self.setStatusLbl(CAMERA_CONFIGURED, scanner: .started)
        }
    }
    
    func didScan(result: String) {
        print(result)
        guard result != EMPTY_STRING else {
            return
        }
        delegate?.didScanned(result: result)
        setStatusLbl(result, scanner: .scanned)
        updateResults()
    }
    
    func setStatusLbl(_ text: String, scanner: Scanner) {
        resultLbl.text = text
        switch scanner {
        case .started:
            resultLbl.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            break
        case .scanned:
            resultLbl.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            resultLbl.text = "Scanned!!!"//text.codeResultPresentation()
            break
        case .noPermission:
            resultLbl.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            break
        case .error:
            resultLbl.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            break
        }
    }
    
    @IBAction func onCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleFlashSwitch() {
        toggleFlash()
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                } catch {
                    print(error)
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }


}

extension ScanVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScanedResultCell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row].code
        return cell
    }
    
}

extension ScanVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
