//
//  ViewController.swift
//  UberClone
//
//  Created by Karol Chmiel on 18/11/2017.
//  Copyright © 2017 Karol Chmiel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var isDriverSwitch: UISwitch!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginView: UIView!
    let DRIVER_STRING = "Driver"
    let RIDER_STRING = "Rider"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        if !areTextFieldFilled() {
            displayAlert(title: "Missing Information", message: "You must provide both an email and password!")
            return
        }
        // sign that bitch up
        Auth.auth().createUser(withEmail: loginTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            if (error != nil) {
                self.displayAlert(title: "Error", message: error!.localizedDescription)
            } else {
                if self.isDriverSwitch.isOn {
                    print("Sign up success, driver")
                    self.saveProfileTypeTo(self.DRIVER_STRING)
                    self.driverSegue()
                } else {
                    print("Sign up success, rider")
                    self.saveProfileTypeTo(self.RIDER_STRING)
                    self.riderSegue()
                }
            }
        })
    }
    
    func saveProfileTypeTo(_ name: String) -> Void {
        let request = Auth.auth().currentUser?.createProfileChangeRequest()
        request?.displayName = name
        request?.commitChanges(completion: nil)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        if !areTextFieldFilled() {
            displayAlert(title: "Missing Information", message: "You must provide both an email and password!")
            return
        }
        // log dat nigga in
        Auth.auth().signIn(withEmail: loginTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            if (error != nil) {
                self.displayAlert(title: "Error", message: error!.localizedDescription)
            } else {
                print("Login in success")
                if user?.displayName == self.RIDER_STRING {
                    self.riderSegue()
                } else {
                    self.driverSegue()
                }
            }
        })
    }
    
    func areTextFieldFilled() -> Bool {
        if (passwordTextField.text?.isEmpty)! || (loginTextField.text?.isEmpty)! {
            return false
        }
        return true
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func switchToLoginView(_ sender: Any) {
        replace(currentView: signUpView, with: loginView)
    }
    
    @IBAction func switchToSignUpView(_ sender: Any) {
        replace(currentView: loginView, with: signUpView)
    }
    
    func replace(currentView: UIView, with newView: UIView) {
        UIView.animate(withDuration: 0.9, animations: {
            currentView.alpha = 0
            newView.alpha = 1
        }, completion: {
            finished in
            currentView.isHidden = true
            newView.isHidden = false
        })
    }
    
    func riderSegue() {
        self.performSegue(withIdentifier: "riderSegue", sender: nil)
    }
    
    func driverSegue() {
        self.performSegue(withIdentifier: "driverSegue", sender: nil)
    }
}
