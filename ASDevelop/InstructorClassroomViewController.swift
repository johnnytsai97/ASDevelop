//
//  InstructorClassroomViewController.swift
//  ASDevelop
//
//  Created by lmulder on 11/8/17.
//  Copyright © 2017 CMPT275. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class InstructorClassroomViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    var MainLoginViewController:MainLoginViewController?
    var photoArray = [textToImage(drawText: "+ Add Student", inImage: UIImage(named:"AddButton.png")!, atPoint: CGPoint(x: 15,y: 235))]
    
    @IBOutlet weak var StudentCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow the view controller to automatically update collection view data
        self.StudentCollectionView.delegate = self
        self.StudentCollectionView.dataSource = self

        initializeInstructor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updatePhotoArray()
    }
    
    // Update the images that are displayed on the collection view
    func updatePhotoArray() {
        // Delete all elements
        photoArray.removeAll()
        
        // Add image of all students to the collection view
        for student in instructor.students {
            let displayImage = student.photo
            let displayText = student.firstName + ", " + String(student.age) as NSString
            photoArray.append(textToImage(drawText: displayText, inImage: displayImage!, atPoint: CGPoint(x: 15,y: 235)))
        }
        
        // Add the Add Student button to collection view
        photoArray.append(textToImage(drawText: "+ Add Student", inImage: UIImage(named:"AddButton.png")!, atPoint: CGPoint(x: 15,y: 235)))
        
        // Refresh the collection view
        self.StudentCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Number of items in the collection view
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get the cell object at current index
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as UICollectionViewCell
        let imageview:UIImageView=UIImageView(frame: CGRect(x: 0, y: 0, width: 383, height: 262))
        
        // Assign each photo in the array to the indexed cell
        imageview.image = photoArray[indexPath.row]
        cell.contentView.addSubview(imageview)
        
        // Pass the cell back to the collection view
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // If the last collection view image is pressed
        if indexPath.row == photoArray.count - 1 {
            // Display new student page
            presentNewStudentScreen()
        }
        else {
            // Display the student corresponding to the button number pressed
            presentStudentModulesViewController(studentIndex: indexPath.row)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Initialize the new instructor class
    func initializeInstructor() {
        instructor = Instructor()
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout),with: nil, afterDelay: 0)
        }else{
            let ref = Database.database().reference()
            let userID = Auth.auth().currentUser?.uid
            print("Current user ID is: \(userID)")
            ref.child("Instructors").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists(){
                    print("snapshot does not exist")
                    return
                }
                //print (snapshot)

                let instructorData = snapshot.value as! NSDictionary
                
                guard let instructorEmail = instructorData["Email"] as! String! else {return}

                //INSTRUCTOR EMAIL
                instructor.changeEmail(email: instructorEmail)
                print ("\nCurrently logged in Instructor email is: \(instructor.email)")      //instructor1@gmail.com

//https://stackoverflow.com/questions/38797626/firebase-and-reading-nested-data-using-swift
                    ref.child("Instructors").child(userID!).child("Student").observeSingleEvent(of: .value, with: { (snapshot) in
                        if !snapshot.exists(){
                            print("snapshot does not exist")
                            return
                        }
                        print("\nNumber of student's under \(instructorEmail) is: \(snapshot.childrenCount)")
                        let studentData = snapshot.children
                        while let studentInfo = studentData.nextObject() as? DataSnapshot{
                            
                            //ALL EXISTING STUDENT ID
                            //print(studentInfo.key)
                            
                            //store individual student INFO
                            ref.child("Instructors").child(userID!).child("Student").child("\(studentInfo.key)").observeSingleEvent(of: .value, with: { (snapshot) in
                                if !snapshot.exists(){
                                    print("snapshot does not exist")
                                    return
                                }
                                let studentDict = snapshot.value as! NSDictionary
                                
                                //Unique Student Auto ID
                                print("\nStudent's ID is: \(studentInfo.key)")
                                //AGE (need to convert from string to int)
                                guard let studentAge = studentDict["Age"] as! String! else {return}
                                print ("Student's age is: \(studentAge)")
                                //FIRSTNAME
                                guard let studentFirstName = studentDict["First_Name"] as! String! else {return}
                                print ("Student's First Name is: \(studentFirstName)")
                                //LASTNAME
                                guard let studentLastName = studentDict["Last_Name"] as! String! else {return}
                                print ("Student's Last Name is: \(studentLastName)")
                                //PROFILE IMAGE URL
                                guard let profileImageURL = studentDict["profileImageURL"] as! String! else {return}
                                print ("Student's profile image is stored here: \(profileImageURL)")
//                                let storageRef = Storage.storage().reference(forURL: profileImageURL)
//                                storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
//                                    let pic = UIImage(data: data!)
//                                }
//                                //MODULE
//                                ref.child("Instructors").child(userID!).child("Student").child("\(studentInfo.key)").observeSingleEvent(of: .value, with: { (snapshot) in
//                                    if !snapshot.exists(){
//                                        print("snapshot does not exist")
//                                        return
//                                    }
//                                    print("\nNumber of Modules student with ID: \(studentInfo.key) have: \(snapshot.childrenCount)")
//                                    let moduleData = snapshot.children
//                                    while let studentModuleInfo = moduleData.nextObject() as? DataSnapshot{
//                                        print (studentModuleInfo.key)
//                                        print("\nStudent's moudule contains: \(studentModuleInfo.key)")
//                                    }
//
//                                }
                                
                                
                                //instructor.addStudent(student: Student(modules: <#T##[Module]#>, firstName: <#T##String#>, age: <#T##Int#>, photo: <#T##UIImage?#>))
                            }, withCancel: nil)
                            //while loop will iterate thru all the student nodes.
                        }// END OF LOOP iterating through all the students

                    }, withCancel: nil)
                
              
                
            }, withCancel: nil)
        }
    }
    
    @objc func handleLogout(){
        do{
            try Auth.auth().signOut()
        }catch let logoutError {
            print(logoutError)
        }
    }
    
    
    // Back,Logout button tapped
    @IBAction func logoutTapped(_ sender: Any) {
        
        do {
            // Sign out of firebase
            try Auth.auth().signOut()
            // Close the current view
            dismiss(animated: true, completion: nil)
        } catch {
            print ("There was a problem logging out.. Try again later")
        }
    }
    
    // Settings button pressed
    @IBAction func settingsButtonPressed(_ sender: Any) {
        // Display the account settings page
        presentAccountSettingsViewController()
    }
    
    //present login screen after successfully logged in
    func presentNewStudentScreen() {
        
        //Create the new view
        let NewStudentViewController:NewStudentViewController = storyboard!.instantiateViewController(withIdentifier: "NewStudentViewController") as! NewStudentViewController
        
        //Assign the instructor class to the new logged in view
        NewStudentViewController.InstructorClassroomViewController = self
        
        //Change the view to the new view
        self.present(NewStudentViewController, animated: true, completion: nil)
    }
    
    //present student modules view controller
    func presentStudentModulesViewController(studentIndex: Int) {
        
        //Create the new view
        let StudentModulesViewController:StudentModulesViewController = storyboard!.instantiateViewController(withIdentifier: "NewStudentModulesViewController") as! StudentModulesViewController
        
        //Assign the current view to the parent view
        StudentModulesViewController.InstructorClassroomViewController = self
        
        //Assign the student index to the StudentModulesView
        StudentModulesViewController.studentIndex = studentIndex
        
        //Change the view to the new view
        self.present(StudentModulesViewController, animated: true, completion: nil)
    }
    
    //present settings page
    func presentAccountSettingsViewController() {
        
        //Create the new view
        let AccountSettingsViewController:AccountSettingsViewController = storyboard!.instantiateViewController(withIdentifier: "AccountSettingsViewController") as! AccountSettingsViewController
        
        //Change the view to the new view
        self.present(AccountSettingsViewController, animated: true, completion: nil)
    }
}
