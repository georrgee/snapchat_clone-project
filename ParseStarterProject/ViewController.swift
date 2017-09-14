/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

// Added to Georrgee github
//repo: https://github.com/georrgee/snapchat_clone-project.git
// 

import UIKit
import Parse

class ViewController: UIViewController {
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    
    @IBAction func signupOrLogin(_ sender: AnyObject) {
        
        if usernameTextField.text == ""{
            
            errorLabel.text = "Username is required!"
        } else{
            
            // password(just gonna have it there because it doesnt matter about the password
            PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: "password", block: { (user, error) in
                
                
                if error != nil {
                    
                    let user = PFUser() // creating a user
                    
                    user.username = self.usernameTextField.text
                    user.password = "password"
                    user.signUpInBackground(block: { (success, error) in
                        
                        if let error = error {
                            
                            var errorMessage = "Signup failed - please try again later"
                            
                            if let errorString = (error as NSError).userInfo["error"] as? String {
                                
                                errorMessage = errorString
                                
                            }
                            
                            self.errorLabel.text = errorMessage
                            
                        } else { // if no error...
                            
                            self.performSegue(withIdentifier: "showUserTable", sender: self)

                            
                        }
                        
                    })
                    
                    print("\(self.usernameTextField.text!)" + " is created")
                    
                } else {
                    
                    print("\(self.usernameTextField.text!)" + " logged in!")
                    self.performSegue(withIdentifier: "showUserTable", sender: self)
                    
                }
                
            })
            
            
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PFUser.current() != nil {
            
            performSegue(withIdentifier: "showUserTable", sender: self)
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
