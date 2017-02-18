//
//  UsersViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Viraj Padte on 2/8/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse
class UsersViewController: UITableViewController {
    
    var feedFrom = [String:String]()
    var posts = [String:[String:UIImage]]()
    

    
    @IBOutlet var table: UITableView!
    //make empty arrays for holding usernames and objectIDs
    
    var userIDs = [String]()
    var users = [String: [String: Bool]]()
    let refereshController = UIRefreshControl()
    
    
    @IBAction func logout(_ sender: Any) {
        PFUser.logOut()
        performSegue(withIdentifier: "toLoginPage", sender: self)
        print("logout")
    }
    @IBAction func feed(_ sender: Any) {
        feedFrom.removeAll()
        //referesh all the data to take new data into affect
        print("getFeed")
        print("users dict now: \(users)")
        //find the followers for the current user
        for (objectID,userDict) in users {
            for (username,status) in userDict{
                if status == true{
                    feedFrom[objectID] = username
                }
            }
        }
        print("feedFrom \(feedFrom)")
        //segue to a new viewcontroller
        performSegue(withIdentifier: "toFeed", sender: self)
        //this is a table
        //show this based on the sequnce we found
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFeed"{
            let destination = segue.destination as! FeedViewController
            //count the posts of all people current user is following
            //destination.feedCount = feedFrom.count
            destination.feedFrom = feedFrom
            //getPosts and then segue
            //getPosts()
            //print("posts \(posts)")
            //destination.posts = posts
        }
        else if segue.identifier == "toLoginPage"{
            print("segue to login page")
        }
        print("prepare for segue")
    }
    
    func getUserData(){
        print("getting data")
        //get the list of all the registered users
        //before we get data lets empty all the data arrays
        userIDs.removeAll()
        users.removeAll()
        let query = PFUser.query()
        query?.findObjectsInBackground(block: { (object, error) in
            if error != nil{
                print(error)
            }
            else if let retrivedObject = object as? NSArray{
                print(retrivedObject)
                if retrivedObject.count > 0 {
                    print("we have atleast one user registered")
                    for element in retrivedObject{
                        if let individualUser = element as? PFUser {
                            if individualUser.username! != PFUser.current()?.username{
                                self.userIDs.append(individualUser.objectId!)
                                self.users[individualUser.objectId!] = [individualUser.username!:false]
                                    self.table.reloadData()
                            }
                        }
                    }
                }
            }
        }
        )
        getCheckMarks()
    }

    func getCheckMarks(){
        //this section is just for putting following marks on the user list
        let newQuery = PFQuery(className: "Followers")
        newQuery.whereKey("Follower", equalTo: PFUser.current()?.objectId)
        newQuery.findObjectsInBackground { (objects, error) in
            if error != nil{
                print(error)
            }
            else if let retrivedObjects = objects{
                print("retrivedObjects: \(retrivedObjects)")
                for object in retrivedObjects{
                    
                    if let followingID = object.value(forKey: "Following") as? String{
                        print("Following ID: \(followingID)")
                        //mark the ones the current user is following
                        self.users.updateValue([(self.users[followingID]?.keys.first)!: true], forKey: followingID)
                        print("updated")
                        self.table.reloadData()
                        
                    }
                }
            }
            print("fetched query to get followers data \(self.users)")
            self.refereshController.endRefreshing()
            print("ended refreshing")
        }
    }
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
        super.viewDidLoad()
        getUserData()
        
        //pull to refresh
        refereshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refereshController.addTarget(self, action: #selector(getUserData), for: UIControlEvents.valueChanged)
        table.addSubview(refereshController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userIDs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        //check for ticks
        //get username
        let username = users[userIDs[indexPath.row]]?.keys.first
        print("Username \(username)")
        if (users[userIDs[indexPath.row]]?[username!])!{
            cell.textLabel?.text = username
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else{
            cell.textLabel?.text = users[userIDs[indexPath.row]]?.keys.first
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark{
            //already checked so now we need to uncheck
            //uncheck the selected a row
            //before unchecking, alert the user
            let alertController = UIAlertController(title: "Unfollow", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.destructive, handler: { (alerted) in
                self.table.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
                //update the entry in the Followers class
                //fetch data corresponding to the current user's object id and the followers object id
                let currentObjectID = PFUser.current()?.objectId
                let followingObjectID = self.userIDs[indexPath.row]
                //update locally
                print("To be updated \(self.users[followingObjectID])")
                for key in (self.users[followingObjectID]?.keys)!{
                    self.users[followingObjectID]?.updateValue(false, forKey: key)
                }
                print("updated locally")
                
                //updated on server
                let query = PFQuery(className: "Followers")
                query.whereKey("Follower", equalTo: currentObjectID)
                query.whereKey("Following", equalTo: followingObjectID)
                query.findObjectsInBackground(block: { (objects, error) in
                    if error != nil{
                        print(error)
                    }
                    else if let retrivedObjects = objects{
                        for object in retrivedObjects{
                            object.deleteInBackground(block: { (deleted, error) in
                                if error != nil{
                                    print("Couldn't delete")
                                }
                                else if deleted{
                                    print("deleted")
                                }
                            })
                        }
                    }
                })
                alertController.dismiss(animated: true, completion: nil)
                print("dismissed")
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (alerted) in
                //dismiss the alert on tapping cancel
                print("cancelled")
                alertController.dismiss(animated: true, completion: nil)
                print("dismissed")
            }))
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            //unchecked row .. so we can check it
            //check the selected a row
            table.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            
            let currentObjectID = PFUser.current()?.objectId
            let followingObjectID = userIDs[indexPath.row]
            //update locally
            print("To be updated \(self.users[followingObjectID])")
            for key in (self.users[followingObjectID]?.keys)!{
                self.users[followingObjectID]?.updateValue(true, forKey: key)
            }
            print("updated locally")

            //updated on server
            //add an entry in the Followers class
            let newFollowerEntry = PFObject(className: "Followers")
            
            newFollowerEntry.setObject(currentObjectID, forKey: "Follower")
            newFollowerEntry.setObject(followingObjectID, forKey: "Following")
            newFollowerEntry.saveInBackground(block: { (saved, error) in
                if error != nil{
                    print(error)
                }
                else if saved{
                    print("saved")
                }
            })
        }
    }
}
