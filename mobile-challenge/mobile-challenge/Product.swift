//
//  Product.swift
//  mobile-challenge
//
//  Created by MARCEN, RAFAEL [External] on 10/8/17.
//  Copyright © 2017 MARCEN, RAFAEL. All rights reserved.
//

import Foundation

class Product {
    var id : String
    var name : String
    
    init() {
        name = ""
        id = ""
    }
    
    init(string: String) {
        var array = string.components(separatedBy: ";")
        name = array[0]
        id = array[1]
    }
}
