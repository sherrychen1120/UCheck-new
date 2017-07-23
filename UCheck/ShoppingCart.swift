//
//  ShoppingCart.swift
//  UCheck
//
//  Created by Sherry Chen on 7/23/17.
//
//

import UIKit

var CurrentShoppingCart : [Item] = []
var subtotal = 0.0
var total_saving = 0.0

class ShoppingCart: NSObject {
    
    static func addItem(newItem : Item){
        if (!CurrentShoppingCart.contains(newItem)){
            CurrentShoppingCart.append(newItem)
            
            if newItem.has_discount{
                subtotal += Double(newItem.discount_price)!
                let saving = Double(newItem.price)! - Double(newItem.discount_price)!
                total_saving += saving
            } else {
                subtotal += Double(newItem.price)!
            }
            
        }
    }
    
    static func deleteItem(oldItem : Item){
        if (CurrentShoppingCart.contains(oldItem)){
            let index = CurrentShoppingCart.index(of: oldItem)
            CurrentShoppingCart.remove(at: index!)
            
            if oldItem.has_discount{
                subtotal += Double(oldItem.discount_price)!
                let saving = Double(oldItem.price)! - Double(oldItem.discount_price)!
                total_saving -= saving
            } else {
                subtotal -= Double(oldItem.price)!
            }
        }
    }
    
    static func listItems(){
        print("[")
        for item in CurrentShoppingCart {
            print(item.name)
        }
        print("]")
    }

}
