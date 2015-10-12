//
//  UserTableViewController.swift
//  Instagram
//
//  Created by Amr Sami on 9/16/15.
//  Copyright (c) 2015 Amr Sami. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {
    
    var users = [""]
    var following = [Bool]()
    var refresher:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateUers()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString (string: "Pull to Refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)

    }
    
    func updateUers () {
        var query = PFUser.query()
        var data: Void? = query?.findObjectsInBackgroundWithBlock({(objects:[AnyObject]?, error:NSError?) -> Void in
            
            self.users.removeAll(keepCapacity: true)
            
            for object: AnyObject in objects! {
                var user:PFUser = object as! PFUser
                var isFollowing:Bool
                
                if user.username != PFUser.currentUser()?.username {
                    
                    self.users.append(user.username!)
                    
                    isFollowing = false
                    
                    var query = PFQuery(className:"followers")
                    var foer = PFUser.currentUser()?.username
                    query.whereKey("following", equalTo:user.username!)
                    query.whereKey("follower", equalTo:foer!)
                    query.findObjectsInBackgroundWithBlock {
                        (objects: [AnyObject]?, error: NSError?) -> Void in
                        
                        if error == nil {
                            if let objects = objects as? [PFObject] {
                                for object in objects {
                                    
                                    isFollowing = true
                                    
                                }
                                self.following.append(isFollowing)
                                self.tableView.reloadData()
                            }
                            
                        } else {
                            // Log details of the failure
                            println(error)
                        }
                        
                        self.refresher.endRefreshing()
                        
                    }
                    
                }
                
                
            }
            
        })

    }
    
    func refresh () {
        println("refreshed")
        updateUers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell (style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
        if following.count > indexPath.row {
            if following[indexPath.row] {
                
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }
        
        cell.textLabel?.text = users[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        if cell.accessoryType == UITableViewCellAccessoryType.Checkmark{
           
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            var query = PFQuery(className:"followers")
            var foing = cell.textLabel?.text!
            var foer = PFUser.currentUser()?.username
            query.whereKey("following", equalTo:foing!)
            query.whereKey("follower", equalTo:foer!)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                        
                            object.deleteInBackground()
                            
                        }
                    }
                    
                } else {
                    // Log details of the failure
                    println(error)
                }
            }

            
        } else {
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            var following = PFObject (className: "followers")
            var foing = cell.textLabel?.text!
            var foer = PFUser.currentUser()?.username
            following.setObject(foing!, forKey: "following")
            following.setObject(foer!, forKey: "follower")
            
            following.saveInBackground()
        }
        
        
    }
    
}