//
//  CurrentSession.swift
//  UCheck
//
//  Created by Sherry Chen on 7/14/17.
//
//

import UIKit

var CurrentStore = "Harnwell"
var CurrentStoreName = "Harnwell"
var CurrentStoreDisplayName = "Harnwell Cafe du Soleil"

var OnGoing = false
var MemberLoggedIn = false
var IsMember = false

var CurrentUser = "" //Stores the email address of the current user
var CurrentUserName = "" //Stores the full name of the current user
var CurrentUserId = "" //Stores the Firebase uid of the current user
var CurrentUserPhoto : UIImage? = nil

protocol communicationScanner {
    func scannerSetup()
    func showHelpForm()
    func toLogOut()
    func showShoppingHistory()
}

class CurrentSession: NSObject {

   
    
    
}
