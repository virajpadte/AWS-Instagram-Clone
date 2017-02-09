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
    
    var userNames = [String]()
    var userIDs = [String]()
    
    @IBAction func logout(_ sender: Any) {
        PFUser.logOut()
        performSegue(withIdentifier: "toLoginPage", sender: self)
        print("logout")
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
        
        //get the list of all the registered users
        
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
                                self.userNames.append(individualUser.username!)
                                self.userIDs.append(individualUser.objectId!)
                            }
                        }
                    }
                }
                
            }
            //print acquired data
            print(self.userNames)
            print(self.userIDs)
            //referesh array data
            self.table.reloadData()
        }
        )
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
        return userNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = userNames[indexPath.row]
        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark{
            //already checked so now we need to uncheck
            //uncheck the selected a row
            //before unchecking, alert the user
            let alertController = UIAlertController(title: "Unfollow \(userNames[indexPath.row].components(separatedBy: "@")[0])", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
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
