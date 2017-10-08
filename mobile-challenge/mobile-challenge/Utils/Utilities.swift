//
//  Utilities.swift
//  mobile-challenge
//
//  Created by MARCEN, RAFAEL [External] on 10/8/17.
//  Copyright © 2017 MARCEN, RAFAEL. All rights reserved.
//

import Foundation
import ARKit


func isInside(box: (min: SCNVector3, max: SCNVector3)?, point: SCNVector3) -> Bool {
    guard let box = box else {
        return false
    }
    
    return (point.x >= box.min.x && point.x <= box.max.x) &&
        (point.y >= box.min.y && point.y <= box.max.y) &&
        (point.z >= box.min.z && point.z <= box.max.z)
}
