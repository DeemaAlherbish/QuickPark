//
//  TermsViewController.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 11/02/2022.
//

import UIKit

class TermsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "5a36a11aee712c8452ae989ab425827d"))
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
     @IBAction func ForgotPass(_ sender: Any) {
       
         let forgotPasswordAlert = UIAlertController(title: "Forgot password?", message: "Enter email address", preferredStyle: .alert)
            forgotPasswordAlert.addTextField { (textField) in
                textField.placeholder = "Enter email address"
            }
            forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (action) in
                let resetEmail = forgotPasswordAlert.textFields?.first?.text
                Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                    if error != nil{
                        self.showAlert(title: "Error", message: "Please enter a valid email!")
                    }else {
                        self.showAlert(title: "Password reset successful", message: "You have successfully requested to reset your password! please check your email ")
                    }
                })
            }))
            //PRESENT ALERT
            self.present(forgotPasswordAlert, animated: true, completion: nil)
        
     }
    */

}
