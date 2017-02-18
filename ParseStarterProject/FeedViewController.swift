//
//  FeedViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Viraj Padte on 2/15/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedCell: UITableViewCell{

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var imageCaption: UILabel!
    @IBOutlet weak var username: UILabel!
}


class FeedViewController: UITableViewController {
    
    //class variable
    let refereshController = UIRefreshControl()
    var feedFrom = [String:String]()
    //var postsDict = [String:String]()
    //var postsDict = [String:[String:UIImage]]()
    var postMessages = [String]()
    var postUsers = [String]()
    var postImages = [UIImage]()
    
    @IBOutlet var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        getPosts()
        //pull to refresh
        refereshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refereshController.addTarget(self, action: #selector(FeedViewController.getPosts), for: UIControlEvents.valueChanged)
        table.addSubview(refereshController)
    }
    
    func getPosts(){
        refereshController.endRefreshing()
        postMessages.removeAll()
        postUsers.removeAll()
        postImages.removeAll()
        
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "updatedAt")
        query.whereKey("uploaderID", containedIn: Array(feedFrom.keys))
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print("Error \(error)")
            }
            else{
                print("no error in fetching")
                print("objects \(objects)")
                if let posts = objects{
                    print("processed well")
                    print("Num posts \(posts.count)")
                    for post in posts{
                        if let uploaderID = post["uploaderID"] as? String{
                            if let imageCaption = post["message"] as? String{
                                if let imageFile = post["Pic"] as? PFFile{
                                    do{
                                        let imageData = try imageFile.getData()
                                        if let image = UIImage(data: imageData){
                                            self.postUsers.append(uploaderID)
                                            self.postMessages.append(imageCaption)
                                            print(imageCaption)
                                            self.postImages.append(image)
                                            print("saved data")
                                            self.table.reloadData()
                                        }
                                    }
                                    catch{
                                        print("some error")
                                    }
                                }
                                //trying to get data in background messed up my order.. so I will have to skip this for now.
                                    /*
                                    imageFile.getDataInBackground(block: { (data, error) in
                                        if error != nil{
                                            print(error)
                                        }
                                        else if let imagedata = data{
                                            if let image = UIImage(data: imagedata){
                                                self.postUsers.append(uploaderID)
                                                self.postMessages.append(imageCaption)
                                                print(imageCaption)
                                                self.postImages.append(image)
                                                print("saved data")
                                                self.table.reloadData()
                                            }
                                        }
                                    })
                                }
                                */
                            }
                        }
                    }
                }
                else{
                    print("processing error")
                }
            }
        }
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
        return postMessages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let dataArray = Array(postsDict.keys)
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        if postMessages.count > 0{
            cell.postImage.image = postImages[indexPath.row]
            cell.imageCaption.text = postMessages[indexPath.row]
            cell.username.text = postUsers[indexPath.row]
        }
        return cell
    }
}
