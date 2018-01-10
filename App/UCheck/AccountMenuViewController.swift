import UIKit
import Firebase
import SwiftKeychainWrapper
import FirebaseAuth

class AccountMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var topBox: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var bottomBox: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dataTableView: UITableView!
    
    var titles : [String] = ["First Name", "Last Name", "Email", "Password"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataTableView.delegate = self
        dataTableView.dataSource = self
        dataTableView.isScrollEnabled = false
        
        view.setGradientBackground(colorOne: Colors.lightRed, colorTwo: Colors.darkRed)
        backButton.contentHorizontalAlignment = .left
        
        topBox.backgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        bottomBox.backgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        
        if CurrentUserPhoto != nil {
            imageView.image = CurrentUserPhoto
        }
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //If directing to history receipt, pass on the selected session
//        if (segue.identifier == "ShoppingHistoryToHistoryReceipt"){
//            let controller = segue.destination as! HistoryReceiptViewController
//            controller.curr_item = selected_item
//        }
    }
    
    //number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    //number of sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //set up cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.dataTableView.dequeueReusableCell(withIdentifier: "AccountMenuCell", for: indexPath) as? AccountMenuTableViewCell else {
            fatalError("the dequeued cell is not a AccountMenuTableViewCell!")
        }
        
        let subtitleTitle = titles[indexPath.row]
        cell.subtitle.text = subtitleTitle
        
        switch subtitleTitle {
        case "First Name":
            cell.value.text = CurrentUserName.components(separatedBy: " ")[0]
        case "Last Name":
            cell.value.text = CurrentUserName.components(separatedBy: " ")[1]
        case "Email":
            cell.value.text = CurrentUser
        case "Password":
            guard let retrievedPassword: String = KeychainWrapper.standard.string(forKey: "password") else {
                cell.value.text = "●●●●●●"
                break
            }
            var dottedPass = ""
            for _ in 1...retrievedPassword.count  {
                dottedPass.append("●");
            }
            cell.value.text = dottedPass
        default:
            cell.value.text = "No Information Provided"
        }
        
        return cell
    }
    
    //tableView func to set cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataTableView.bounds.height / 4
    }
    
    //tableView func for cell selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSubtitle = titles[indexPath.row]
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Update " + selectedSubtitle, message: nil, preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = selectedSubtitle
        
            switch selectedSubtitle {
            case "First Name":
                textField.text = CurrentUserName.components(separatedBy: " ")[0]
            case "Last Name":
                textField.text = CurrentUserName.components(separatedBy: " ")[1]
            case "Email":
                textField.text = CurrentUserName
            case "Password":
                guard let retrievedPassword: String = KeychainWrapper.standard.string(forKey: "password") else {
                    textField.text = "Facebook Authentication"
                    break
                }
                var dottedPass = ""
                for _ in 1...retrievedPassword.count  {
                    dottedPass.append("●");
                }
                textField.text = dottedPass
                textField.delegate = self
            default:
                textField.text = ""
            }
            
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            self.dataTableView.deselectRow(at: indexPath, animated: true)
        }))
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            self.replaceData(newValue: textField.text!, property: selectedSubtitle)
            guard let cell = self.dataTableView.dequeueReusableCell(withIdentifier: "AccountMenuCell", for: indexPath) as? AccountMenuTableViewCell else {
                fatalError("the dequeued cell is not a AccountMenuTableViewCell!")
            }
            
            cell.value.text = textField.text!
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func replaceData(newValue: String, property: String) {
        switch property {
        case "First Name":
            let lastName = CurrentUserName.components(separatedBy: " ")[1]
            let newName = newValue + " " + lastName
            
            if var values = UserDefaults.standard.value(forKey: "fb+" + CurrentUserId) as? [String: String]{
                values["full_name"]! = newName
                UserDefaults.standard.set(values, forKey: "fb+" + CurrentUserId)
            } else {
                UserDefaults.standard.set(newName, forKey: "email+" + CurrentUser)
            }
            
            CurrentUserName = newName
            
            let ref = FIRDatabase.database().reference(withPath: "user-profiles")
            let userRef = ref.child(CurrentUserId)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                var value = snapshot.value as? [AnyHashable:Any]
                value?["first_name"] = newValue
                userRef.setValue(value)
            })

        case "Last Name":
            let firstName = CurrentUserName.components(separatedBy: " ")[0]
            let newName = firstName + " " + newValue
            
            if var values = UserDefaults.standard.value(forKey: "fb+" + CurrentUserId) as? [String: String]{
                values["full_name"]! = newName
                UserDefaults.standard.set(values, forKey: "fb+" + CurrentUserId)
            } else {
                UserDefaults.standard.set(newName, forKey: "email+" + CurrentUser)
            }
            
            CurrentUserName = newName
            
            let ref = FIRDatabase.database().reference(withPath: "user-profiles")
            let userRef = ref.child(CurrentUserId)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                var value = snapshot.value as? [AnyHashable:Any]
                value?["last_name"] = newValue
                userRef.setValue(value)
            })

        case "Email":
            let oldEmail = CurrentUser
            
            if var values = UserDefaults.standard.value(forKey: "fb+" + CurrentUserId) as? [String: String]{
                values["email"]! = newValue
                UserDefaults.standard.set(values, forKey: "fb+" + CurrentUserId)
            } else {
                UserDefaults.standard.removeObject(forKey: "email+" + oldEmail)
                UserDefaults.standard.set(CurrentUserName, forKey: "email+" + newValue)
                KeychainWrapper.standard.removeObject(forKey: "email")
                KeychainWrapper.standard.set(newValue, forKey: "email")
            }
            
            CurrentUser = newValue
            
            FIRAuth.auth()?.currentUser?.updateEmail(newValue) { (error) in
                print(error ?? "Error while updating Email with Database")
            }
            
            let ref = FIRDatabase.database().reference(withPath: "user-profiles")
            let userRef = ref.child(CurrentUserId)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                var value = snapshot.value as? [AnyHashable:Any]
                value?["email"] = newValue
                userRef.setValue(value)
            })
        case "Password":
            KeychainWrapper.standard.removeObject(forKey: "password")
            KeychainWrapper.standard.set(newValue, forKey: "password")
            FIRAuth.auth()?.currentUser?.updatePassword(newValue) { (error) in
                print(error ?? "Error while updating Password with Database")
            }
        default:
            return
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let currentString: String = textField.text!

        var isValidPassword: Bool {
            do {
                let regex = try NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d$@$!%*#?&]{6,18}$")
                if(regex.firstMatch(in: currentString, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, currentString.count)) != nil){
                    
                    if(currentString.count>=6 && currentString.count<=18){
                        return true
                    }else{
                        return false
                    }
                }else{
                    return false
                }
            } catch {
                return false
            }
        }
        
        if (!isValidPassword) {
            let alert = UIAlertController(title: "Password is incorrecty formatted", message: nil, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }
        
        return isValidPassword
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}

