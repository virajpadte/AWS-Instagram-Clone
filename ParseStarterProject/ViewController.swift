/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupOrLogin: UIButton!
    @IBOutlet weak var changeMessage: UILabel!
    
    var signUpMode = true
    
    let activityIndicator = UIActivityIndicatorView()

    override func viewDidAppear(_ animated: Bool) {
        /*
        if PFUser.current() != nil{
            //this means some user is logged in for the current session
            self.performSegue(withIdentifier: "toUserList", sender: self)
        }
 */
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func signupOrLogin(_ sender: Any) {
        if emailTextField.text == "" || passwordTextField.text == ""{
            showAlert(title: "Expected Error", message: "You need to enter both username and password")
        
        }
        else{
            //show activity indicator as the task below this will take time
            
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.center = view.center
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            if signUpMode{
                //attempt to sign up via parse.
                let user = PFUser()
                user.email = emailTextField.text
                user.username = emailTextField.text
                user.password = passwordTextField.text
                
                user.signUpInBackground(block: { (signed, error) in
                    if error != nil{
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        if let errorDict = error{
                            let errorMessage  = errorDict.localizedDescription
                            self.showAlert(title: "Opps", message: errorMessage)
                        }
                    }
                    else{
                        print("signed up")
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.performSegue(withIdentifier: "toUserList", sender: self)
                    }
                })
            }
            else{
                PFUser.logInWithUsername(inBackground: emailTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                    if error != nil{
                        print(error)
                        if let parsedError = error{
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            self.showAlert(title: "Opps", message: parsedError.localizedDescription)
                        }
                    }
                    else{
                        print("logged in")
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.performSegue(withIdentifier: "toUserList", sender: self)
                    }
                })
            
            
            }
            
            
            
        }
        
    }
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            print("alerted user")
            self.dismiss(animated: true, completion: nil)
        }))
        //since you are wanting to show a new viewcontroller in your existing new controller
        //present always couples with a dimiss
        self.present(alert, animated: true, completion: nil)
    
    }
    
    @IBOutlet weak var changeSignUpModeButton: UIButton!

    @IBAction func changeSignupMode(_ sender: Any) {
        if signUpMode{
            signupOrLogin.setTitle("Log In", for: [])
            changeSignUpModeButton.setTitle("Sign Up", for: [])
            changeMessage.text = "Don't have an account?"
            signUpMode = false
        }
        else{
            signupOrLogin.setTitle("Sign Up", for: [])
            changeSignUpModeButton.setTitle("Log In", for: [])
            changeMessage.text = "Already have an account?"
            signUpMode = true
        }
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
