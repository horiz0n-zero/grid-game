//
//  json.swift
//  dans une case
//
//  Created by Antoine FeuFeu on 22/05/2016.
//  Copyright © 2016 Antoine FeuFeu. All rights reserved.
//

import Foundation

extension Dictionary {
    static func lectureJSON(filename: String) -> Dictionary<String, AnyObject>? {
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            
            var data: NSData!
            do {
                data = try? NSData(contentsOfFile: path, options: NSDataReadingOptions())
            }
            
            if let data = data {
                
                var dictionary: AnyObject!
                do {
                    dictionary = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                    
                }
                if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                    return dictionary
                } else {
                    print("json format invalide '\(filename)'")
                    return nil
                }
            } else {
                print("impossible de charger: \(filename)")
                return nil
            }
        } else {
            print("impossible de trouver: \(filename)")
            return nil
        }
    }
}