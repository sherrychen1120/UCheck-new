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
            if (existingItem.item_number == newItem.item_number) {
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
        subtotal = subtotal + Double(newItem.item_price)!

    }
    
    private static func decreasePrices(oldItem : Item){
        subtotal = subtotal - Double(oldItem.item_price)!
        
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
            print(item.item_name)
        }
        print("]")
        print("subtotal = " + String(subtotal))
        print("total savings = " + String(total_saving))
    }
    
    static func clear(){
        CurrentShoppingCart = [];
        subtotal = 0.0;
        total_saving = 0.0;
    }

}
