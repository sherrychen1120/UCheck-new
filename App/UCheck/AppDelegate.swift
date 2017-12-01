//
//  AppDelegate.swift
//  UCheck
//
//  Created by Sherry Chen on 7/2/17.
//
//

import UIKit
import CoreData
import Firebase
import Braintree
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftKeychainWrapper


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    override init() {
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BTAppSwitch.setReturnURLScheme("com.ucheckbeta.UCheck.payments")
        
        //Launch FBSDK
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Try retrieving email login info
        let retrievedEmail: String? = KeychainWrapper.standard.string(forKey: "email")
        let retrievedPassword: String? = KeychainWrapper.standard.string(forKey: "password")
        
        //Check if the app has been opened on this device before.
        let defaults = UserDefaults.standard
        
        //MARK: debug calls
        //For debug - set ExistingDevice
        //defaults.set("true", forKey: "ExistingDevice")
        
        //For debug - clean KeychainWrapper
        /*let removeEmail: Bool = KeychainWrapper.standard.removeObject(forKey: "email")
        let removePassword: Bool = KeychainWrapper.standard.removeObject(forKey: "password")
        print("Successfully removed email: \(removeEmail);")
        print("Successfully removed password: \(removePassword).")*/
        
        //For debug - Log out Facebook
        /*let loginManager = FBSDKLoginManager()
        loginManager.logOut()*/
        /*if (FBSDKAccessToken.current() == nil){
            print ("logout successful.")
        }*/
        
        var targetID = ""
        
        if let stringOne = defaults.string(forKey: "ExistingDevice") {
            print("Existing Device " + stringOne)
            let isExistingDevice = (stringOne == "true")
            if (!isExistingDevice){
                //Data inconsistency. Somehow the value stored at "ExistingDevice" is not "true".
                //Most likely a testing legacy.
                //Going to signup board
                defaults.set("true", forKey: "ExistingDevice")
                print("going to sign up page")
                targetID = "signupBoard"
                showTargetVC(ID: targetID)
                return true
                
            } else {
                
                /*if (FBSDKAccessToken.current() == nil){
                    print("AccessToken is nil.")
                }*/
                
                //If there's existing email logged in
                if let email = retrievedEmail, let password = retrievedPassword{
                    FIRAuth.auth()!.signIn(withEmail: email, password: password){ (user, error) in
                        if let error = error {
                            print("Firebase login error: " + error.localizedDescription)
                            //Firebase sign in error. Log out and redirect to login board
                            logoutProcedure(EmailOrFB: "Email", removeUserDefaultsForKey: "email+"+email, deleteProfilePic: true, cleanCurrentSession: false, cleanShoppingCart: false, handleComplete: {
                                    targetID = "loginBoard"
                                    self.showTargetVC(ID: targetID)
                            })
                        } else {
                            //Store user email
                            CurrentUser = email
                            
                            //Store user id
                            if let user = FIRAuth.auth()?.currentUser{
                                CurrentUserId = user.uid
                            }
                            
                            //Get the user name from NSUserDefaults
                            if let name = defaults.string(forKey: "email+" + email) {
                                CurrentUserName = name
                            } else {
                                //Keychain inconsistency, log out the user and go back to login page
                                print("Login error: data inconsistency. No user data in defaults")
                                logoutProcedure(EmailOrFB: "Email", removeUserDefaultsForKey: "email+"+email, deleteProfilePic: true, cleanCurrentSession: false, cleanShoppingCart: false, handleComplete: {
                                    targetID = "loginBoard"
                                    self.showTargetVC(ID: targetID)
                                })
                            }
                            
                            //Get the user profile picture from local storage
                            if let image = loadImageFromPath(path: "profilePicture.png") {
                                //If the picture is found, save photo as the current users image
                                CurrentUserPhoto = image
                            } else {
                                print("No photo found in filepath, trying to re-download")
                                //re-download image
                                let storageRef = FIRStorage.storage().reference()
                                let imagesRef = storageRef.child("profile_pics")
                                let selfieRef = imagesRef.child("\(CurrentUserId).png")
                                selfieRef.data(withMaxSize: 1024 * 1024, completion: { (data, error) in
                                    if (error != nil) {
                                        print("Unable to download image. Will retry later. Error: " + (error?.localizedDescription)!)
                                    } else if (data != nil) {
                                        if let image = UIImage(data: data!) {
                                            //save photo as the current users image
                                            CurrentUserPhoto = image
                                            
                                            //store photo in file system for later use
                                            saveImage(image: image, path: "profilePic.png")
                                        }
                                    }
                                    
                                    //Redirect to scanner board after hearing back from Firebase
                                    targetID = "scannerBoard"
                                    self.showTargetVC(ID: targetID)
                                })
                            }
                            
                        }
                    }
                //else if there was a FB login
                } else if let accessToken = FBSDKAccessToken.current(){
                    let userID = accessToken.userID!
                    
                    //swap fb accessToken for firebase login key
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
                    
                    //Firebase sign in
                    FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                        if let error = error {
                            print("Firebase login error: \(error.localizedDescription)")
                            //Firebase sign in error. Log out and redirect to login board
                            logoutProcedure(EmailOrFB: "FB", removeUserDefaultsForKey: "fb+"+userID, deleteProfilePic: true, cleanCurrentSession: false, cleanShoppingCart: false, handleComplete: {
                                targetID = "loginBoard"
                                self.showTargetVC(ID: targetID)
                            })
                        }
                        
                        //Store Firebase user id
                        if let user = FIRAuth.auth()?.currentUser{
                            CurrentUserId = user.uid
                        }
                        
                        //Get the user email & name from NSUserDefaults, using Facebook userID
                        if let values = defaults.value(forKey: "fb+" + userID) as? [String: String]{
                            CurrentUser = values["email"]!
                            CurrentUserName = values["full_name"]!
                        }
                        
                        if let image = loadImageFromPath(path: "profilePicture.png") {
                            //If picture found, save photo as the current users image
                            CurrentUserPhoto = image
                        } else {
                            print("No photo found in filepath, trying to re-download")
                            //re-download image
                            let storageRef = FIRStorage.storage().reference()
                            let imagesRef = storageRef.child("profile_pics")
                            let selfieRef = imagesRef.child("\(CurrentUserId).png")
                            selfieRef.data(withMaxSize: 1024 * 1024, completion: { (data, error) in
                                if (error != nil) {
                                    print("Unable to download image. Will retry later. Error: " + (error?.localizedDescription)!)
                                } else if (data != nil) {
                                    if let image = UIImage(data: data!) {
                                        //save photo as the current users image
                                        CurrentUserPhoto = image
                                        
                                        //store photo in file system for later use
                                        saveImage(image: image, path: "profilePic.png")
                                    }
                                }
                                
                                //Redirect to scanner board after hearing back from Firebase
                                targetID = "scannerBoard"
                                self.showTargetVC(ID: targetID)
                            })
                        }
                    })
                //no current email or fb session
                } else {
                    targetID = "loginBoard"
                    showTargetVC(ID: targetID)
                }
                return true
            }
        }
        //Actual case for first time using this device. No object found for key "ExistingDevice"
        else {
            defaults.set("true", forKey: "ExistingDevice")
            print("going to sign up page")
            targetID = "signupBoard"
            showTargetVC(ID: targetID)
            return true
        }
    }
    
    func showTargetVC(ID: String){
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialVC = storyboard.instantiateViewController(withIdentifier: ID)
        self.window?.rootViewController = initialVC
        self.window?.makeKeyAndVisible()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare("com.ucheckbeta.UCheck.payments") == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        return false
    }
    
    // If you support iOS 7 or 8, add the following method.
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare("com.ucheckbeta.UCheck.payments") == .orderedSame {
            return BTAppSwitch.handleOpen(url, sourceApplication: sourceApplication)
        }
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "UCheck")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

