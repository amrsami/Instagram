//
//  PostViewController.swift
//  Instagram
//
//  Created by Amr Sami on 10/6/15.
//  Copyright (c) 2015 Amr Sami. All rights reserved.
//

import UIKit

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    var photoSelected:Bool = false
    var error = ""
    var activityIndicator = UIActivityIndicatorView()

    
    func displayAlert (title:String, error:String) {
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var imageToPost: UIImageView!
    
    @IBAction func chooseImage(sender: AnyObject) {
        
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)

    }
    
    @IBOutlet weak var sharedText: UITextField!
    
    @IBAction func postImage(sender: AnyObject) {
        
        
        if photoSelected == false {
            
            error = "Please select an image to post"
        } else if sharedText.text == "" {
            
            error = "Please enter your text to share"
        }
        
        if error != "" {
            
            displayAlert("Cannot Post Image", error: error)
            
            error = ""
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            
            var post = PFObject(className: "Post")
            let text = sharedText.text
            let username = PFUser.currentUser()?.username
            post.setObject(text, forKey: "title")
            post.setObject(username!, forKey: "username")
            
            post.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                
                if success == false {
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    self.displayAlert("Couldn't Post Image", error: "title Plase try again later")
                    
                } else {
                    
                    let imageData = UIImagePNGRepresentation(self.imageToPost.image)
                    let imageFile = PFFile (name: "image.png", data: imageData)
                    post.setObject(imageFile, forKey: "imageFile")
                    post.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        if success == false {
                            self.displayAlert("Couldn't Post Image", error: "image Plase try again later")
                        } else {
                            
                            println("posted successfully")
                            
                            self.photoSelected = false
                            self.imageToPost.image = UIImage (named: "placeholder.png")
                            self.sharedText.text = ""
                            
                            self.displayAlert("Image Posted", error: "your image posted successfully!")
                        }
                        
                    }
                    
                }
                
            }
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        println("Image Selected")
        self.dismissViewControllerAnimated(true, completion: nil)
        
        imageToPost.image = image
        photoSelected = true
    }

    @IBAction func logout(sender: AnyObject) {
        
        PFUser.logOut()
        performSegueWithIdentifier("logout", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.sharedText.delegate = self
        
        photoSelected = false
        imageToPost.image = UIImage (named: "placeholder.png")
        sharedText.text = ""
        error = ""
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
