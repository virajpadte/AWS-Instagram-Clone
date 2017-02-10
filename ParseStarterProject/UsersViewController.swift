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

    
    func getData(){
        
        print("getting data")
        //get the list of all the registered users
        //before we get data lets empty all the data arrays
        
        userIDs.removeAll()
        userIDs.removeAll()
        
        
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
                                //self.userNames.append(individualUser.username!)
                                self.userIDs.append(individualUser.objectId!)
                                self.users[individualUser.objectId!] = [individualUser.username!:false]
                            }
                        }
                    }
                }
                
            }
            //print acquired data
            print(self.userIDs)
            print(self.users)
            print("first query to get list")
        }
        )
        let newQuery = PFQuery(className: "Followers")
        newQuery.whereKey("Follower", equalTo: PFUser.current()?.objectId)
        newQuery.findObjectsInBackground { (objects, error) in
            if error != nil{
                print(error)
            }
            else if let retrivedObjects = objects{
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
            print("fetch query to get followers data")
            self.refereshController.endRefreshing()
            print("ended refreshing")
        }
    }
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
        super.viewDidLoad()
        getData()
        
        //pull to refresh
        refereshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refereshController.addTarget(self, action: #selector(getData), for: UIControlEvents.valueChanged)
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
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (alerted) in
            }))
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            //unchecked row .. so we can check it
            //check the selected a row
            table.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            //add an entry in the Followers class
            
            let newFollowerEntry = PFObject(className: "Followers")
            let currentObjectID = PFUser.current()?.objectId
            let followingObjectID = userIDs[indexPath.row]
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
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    */
    
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
