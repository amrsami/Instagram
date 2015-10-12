//
//  ViewController.swift
//  Instagram
//
//  Created by Amr Sami on 9/15/15.
//  Copyright (c) 2015 Amr Sami. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    var activityIndicator = UIActivityIndicatorView()
    var error = ""
    var signupActive = true

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var alreadyRegistered: UILabel!
    
    @IBAction func signupToLogin(sender: AnyObject) {
        
        if signupActive == true {
            
            signupActive = false
            signupLabel.text = "Use the form below to log in"
            signupBtn.setTitle("Log In", forState: UIControlState.Normal)
            alreadyRegistered.text = "Not Registered?"
            loginBtn.setTitle("Sign Up", forState: UIControlState.Normal)
            
        } else {
            
            signupActive = true
            signupLabel.text = "Use the form below to sign up"
            signupBtn.setTitle("Sign Up", forState: UIControlState.Normal)
            alreadyRegistered.text = "Already Registered?"
            loginBtn.setTitle("Log In", forState: UIControlState.Normal)

            
        }
        
    }
    
    func displayAlert (title:String, error:String) {
        var alert = UIAlertController(title: "Error In Form", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    
    func instaSignup() {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        if signupActive == true {
            
            var user = PFUser()
            user.username = username.text
            user.password = password.text
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, signupError: NSError?) -> Void in
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if let signupError = signupError {
                    if let errorString = signupError.userInfo?["error"] as? NSString {
                        
                        self.error = errorString as String
                    } else {
                        self.error = "Please Try Again later"
                    }
                    
                    self.displayAlert("Couldn't Sing up", error: self.error)
                    
                } else {
                    // Hooray! Let them use the app now.
                    println("signed In")
                    self.performSegueWithIdentifier("jumpToUserTable", sender: self)
                }
            }
            
        } else {
            
            PFUser.logInWithUsernameInBackground(username.text, password:password.text) {
                (user: PFUser?, signupError: NSError?) -> Void in
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if signupError == nil {
                    // Do stuff after successful login.
                    println("Logged In")
                    self.performSegueWithIdentifier("jumpToUserTable", sender: self)
                    
                } else {
                    // The login failed. Check error to see why.
                    if let signupError = signupError {
                        if let errorString = signupError.userInfo?["error"] as? NSString {
                            
                            self.error = errorString as String
                        } else {
                            self.error = "Please Try Again later"
                        }
                        
                        self.displayAlert("Couldn't Log In", error: self.error)
                    }

                }
            }

            
        }
    }
    
    
    @IBAction func signup(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
            
            error = "please enter a username and password"
            
        }
        
        if error != "" {
            
            displayAlert("Error In Form", error: error)
            
            error = ""
            
        } else {
            
            instaSignup()
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.username.delegate = self
        self.password.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("jumpToUserTable", sender: self)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}

