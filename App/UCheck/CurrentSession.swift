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

var CurrentUser = ""
var CurrentUserName = ""
var CurrentUserId = ""
var CurrentUserPhoto : UIImage? = nil

var toLogOut = false
var forHelp = false

protocol communicationScanner {
    func scannerSetup()
    func showHelpForm()
    func toLogOut()
}

class CurrentSession: NSObject {

   
    
    
}
