//
//  FeedViewController.swift
//  Instagram
//
//  Created by Amr Sami on 10/12/15.
//  Copyright (c) 2015 Amr Sami. All rights reserved.
//

import UIKit

class FeedViewController: UITableViewController {
    
    var titles = [String]()
    var usernames = [String]()
    var images = [UIImage]()
    var imageFiles = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var getFollowedUsersQuery = PFQuery(className: "followers")
        let username = PFUser.currentUser()?.username
        getFollowedUsersQuery.whereKey("follower", equalTo: username!)
        getFollowedUsersQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                var followedUser = ""
                
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        
                        followedUser = object.objectForKey("following") as! String
                        
                        var query = PFQuery(className:"Post")
                        query.whereKey("username", equalTo: followedUser)
                        query.findObjectsInBackgroundWithBlock {
                            (objects: [AnyObject]?, error: NSError?) -> Void in
                            
                            if error == nil {
                                // The find succeeded.
                                print("Successfully retrieved \(objects!.count) Posts.")
                                // Do something with the found objects
                                if let objects = objects as? [PFObject] {
                                    for object in objects {
                                        self.titles.append(object.objectForKey("title") as! String)
                                        self.usernames.append(object.objectForKey("username") as! String)
                                        self.imageFiles.append(object.objectForKey("imageFile") as! PFFile)
                                        
                                        self.tableView.reloadData()
                                    }
                                }
                            } else {
                                // Log details of the failure
                                println("Error: \(error!) \(error!.userInfo!)")
                            }
                        }

                        
                    }
                }
            }
        }
        
        self.tableView.reloadData()

        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myCell:Cell = self.tableView.dequeueReusableCellWithIdentifier("myCell") as! Cell
       
        if titles.count > indexPath.row {
            //if titles[indexPath.row] {

                myCell.title.text = titles[indexPath.row]
                myCell.username.text = usernames[indexPath.row]
        
                imageFiles[indexPath.row].getDataInBackgroundWithBlock ({
                    (imageData: NSData?, error: NSError?) -> Void in
            
                    if error == nil {
                        let image = UIImage(data: imageData!)
                
                        myCell.postedImage.image = image
                    }
        
        
                })
            //}
        }
        
            return myCell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 227
    }
    
   
}
