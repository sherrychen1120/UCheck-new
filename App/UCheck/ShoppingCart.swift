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
        
        var foundExisting = false
        
        for existingItem in CurrentShoppingCart {
            if (existingItem.code == newItem.code) {
                existingItem.addItem()
                self.increasePrices(newItem: newItem)
                foundExisting = true
            }
        }
        
        if (!foundExisting){
            CurrentShoppingCart.append(newItem)
            self.increasePrices(newItem: newItem)
        }
    }
    
    private static func increasePrices(newItem : Item){
        
        if newItem.has_discount{
            subtotal = subtotal + Double(newItem.discount_price)!
            let saving = Double(newItem.price)! - Double(newItem.discount_price)!
            total_saving = total_saving + saving
        } else {
            subtotal = subtotal + Double(newItem.price)!
        }

    }
    
    private static func decreasePrices(oldItem : Item){
        
        if oldItem.has_discount{
            subtotal = subtotal - Double(oldItem.discount_price)!
            let saving = Double(oldItem.price)! - Double(oldItem.discount_price)!
            total_saving = total_saving - saving
        } else {
            subtotal = subtotal - Double(oldItem.price)!
        }

        
    }
    
    static func deleteItem(oldItem : Item){
        
        var foundExisting = false
        
        for existingItem in CurrentShoppingCart {
            if (existingItem.code == oldItem.code) {
                
                let remainingQuantity = existingItem.deleteItem()
                self.decreasePrices(oldItem : existingItem)
                
                if (remainingQuantity == 0){
                    let index = CurrentShoppingCart.index(of: existingItem)
                    CurrentShoppingCart.remove(at: index!)
                }
                
                foundExisting = true
            }
        }
        
        if (!foundExisting){
             //error message
            print("The item to delete doesn't exist in the shopping cart.")
        }

        
    }
    
    static func listItems(){
        print("[")
        for item in CurrentShoppingCart {
            print(item.name)
        }
        print("]")
        print("subtotal = " + String(subtotal))
        print("total savings = " + String(total_saving))
    }

}
