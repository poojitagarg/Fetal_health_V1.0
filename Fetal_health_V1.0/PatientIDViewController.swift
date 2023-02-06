//
//  PatientIDViewController.swift
//  Fetal_health_V1.0
//
//  Created by School on 1/5/24.
//

import UIKit

class PatientIDViewController: UIViewController {

    @IBOutlet weak var PatientIDTxt: UITextField!
//    public var completionHandler: ((String?) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func BtnStart(_ sender: Any) {
        self.performSegue(withIdentifier: "mainVC", sender: self)
//        completionHandler?(PatientIDTxt.text)
//        dismiss(animated: true,completion: nil)
    }
    
    func resetInitialState() {
            // Reset any state or clear input fields on the initial screen
            // For example, if you have a text field named 'inputTextField':
        PatientIDTxt.text = ""
        }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainVC"{
            if let vc = segue.destination as? ViewController{
                vc.patientID = PatientIDTxt.text!
                
            }
        }
    }

}
