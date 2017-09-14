//
//  UserTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by George Garcia on 9/7/17.
//  Copyright © 2017 Parse. All rights reserved.
//

// Added to Github Repo - Snapchat_clone-project
//Test

import UIKit
import Parse

class UserTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var usernames = [String]()
    
    var recipientUsername = "" // empty string
    
    func checkForMessages () {
        
        let query = PFQuery(className: "Image")
        
        query.whereKey("recipientUsername", equalTo: (PFUser.current()?.username)!)
        
        do{
            let images = try query.findObjects()
            
            if images.count > 0 {
                    
                    var senderUsername = "Unknown User"
                    
                    if let username = images[0]["senderUsername"] as? String{
                        
                        senderUsername = username
                        
                    }
                    
                    if let pfFile = images[0]["photo"] as? PFFile{
                        
                        pfFile.getDataInBackground(block: { (data, error) in
                            
                            if let imageData = data{
                                
                                images[0].deleteInBackground() // delete in background
                                
                                self.timer.invalidate() // stop timer
                                
                                if let imageToDisplay = UIImage(data: imageData){

                                    let alertController = UIAlertController(title: "You have a snap!", message: "From " + senderUsername, preferredStyle: .alert)
                                    
                                    alertController.addAction(UIAlertAction(title: "Okay!", style: .default, handler: { (action) in
                                        
                                        let backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                        
                                        backgroundImageView.backgroundColor = UIColor.black
                                        
                                        backgroundImageView.alpha = 0.8
                                        backgroundImageView.tag = 10
                                        
                                        self.view.addSubview(backgroundImageView)
                                        
                                        //display our image
                                        
                                        let displayedImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                        
                                        displayedImageView.image = imageToDisplay
                                        
                                        // referring to the image
                                        displayedImageView.tag = 10
                                        
                                        displayedImageView.contentMode = UIViewContentMode.scaleAspectFit
                                        
                                        self.view.addSubview(displayedImageView)
                                        
                                        _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                                            
                                              self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(UserTableViewController.checkForMessages), userInfo: nil, repeats: true)
                                            
                                            for subview in self.view.subviews {
                                                
                                                if subview.tag == 10{
                                                    
                                                    subview.removeFromSuperview()
                                                    
                                                }
                                                
                                            }
                                            
                                        })
                                        
                                        
                                    }))
                                    
                                    self.present(alertController, animated: true, completion: nil)
                                    
                                }
                                
                                
                            }
                            
                            
                        })
                        
                    }
                
            }
            
            
        } catch {
            
            print("Could not get images")
        }
    }
    
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false // displays the navigation bar and buttons

        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(UserTableViewController.checkForMessages), userInfo: nil, repeats: true)
        
        // download the usernames (to display on the list)
        let query = PFUser.query()
        
        query?.whereKey("username", notEqualTo: (PFUser.current()?.username)!)
        
        //DIFFERENT WAY TO DO THE QUERY
        
        do {
            
        let users = try query?.findObjects()
            
            if let users = users as? [PFUser]{
                
                for user in users{
                    
                    self.usernames.append(user.username!)
                    
                }
                
                tableView.reloadData() // udpate table
                
            }
            
        } catch{
            
            print("Couldn't find any users")
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return usernames.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "logoutSeg" {
            
            PFUser.logOut() // logs the user out
            timer.invalidate()
            self.navigationController?.navigationBar.isHidden = true // Hides the bar button on the from the navigation bar
            
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = usernames[indexPath.row] // on the cell itself
        
        return cell
    }

    
    
    // when user taps the username and wants to send photo
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        recipientUsername = usernames[indexPath.row] // who we are sending this to
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            print("Image returned...")
            
            // storing images but first create a class
            let imageToSend = PFObject(className: "Image")
            
            let acl = PFACL()
            acl.getPublicReadAccess = true
            acl.getPublicWriteAccess = true
            
            imageToSend.acl = acl
            
            imageToSend["photo"] = PFFile(name: "photo.png", data: UIImagePNGRepresentation(image)!)
            imageToSend["senderUsername"] = PFUser.current()?.username
            imageToSend["recipientUsername"] = recipientUsername
            
            imageToSend.saveInBackground(block: { (success, error) in
                
                var title = "Sending Failed"
                var description = "Please try again later!"
                
                if success {
                    
                    title = "Message Sent!"
                    description = "Your message has been sent"
                    
                }
                
                let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Okay!", style: .default, handler: { (action) in
                    
                    alertController.dismiss(animated: true, completion: nil)
                    
                }))
                
                // display alert
                self.present(alertController, animated: true, completion: nil)
                
            })
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }

}
