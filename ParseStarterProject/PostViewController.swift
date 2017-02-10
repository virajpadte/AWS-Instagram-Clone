//
//  PostViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Viraj Padte on 2/9/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var imageVIew: UIImageView!
    let imagePicker = UIImagePickerController()
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            print("alerted user")
            alert.dismiss(animated: true, completion: nil)
        }))
        //since you are wanting to show a new viewcontroller in your existing new controller
        //present always couples with a dimiss
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func selectImage(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            //set image to the display
            imageVIew.image = image
            //dismiss the picker
            imagePicker.dismiss(animated: true, completion: nil)
            
            
        }
    }
    @IBAction func post(_ sender: Any) {
        //post content on the parse server
        let post = PFObject(className: "Posts")
        post.setObject(message.text!, forKey: "message")
        let compressedImage = UIImageJPEGRepresentation(imageVIew.image!, 1)
        let imageData = PFFile(name: "image.jpg", data: compressedImage!)
        post.setObject(imageData, forKey: "Pic")
        post.saveInBackground { (success, error) in
            if error != nil{
                print(error)
                //create an alter to the user
                self.showAlert(title: "Opps", message: "A problem occurred while posting the image!")
            }else{
                print("posted")
                self.showAlert(title: "Yeah!", message: "Your image is posted")
                self.message.text = ""
                self.imageVIew.image = UIImage()
                
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
