//
//  TextNode.swift
//  mobile-challenge
//
//  Created by MARCEN, RAFAEL [External] on 10/7/17.
//  Copyright © 2017 MARCEN, RAFAEL. All rights reserved.
//

import Foundation
import SceneKit

class TextNode: SCNNode {
    
    let depth : Float = 0.01
    
    override init() {
        super.init()
    }
    
    init(text: String) {
        super.init()
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        // Text
        let textNode = SCNText(string: text, extrusionDepth: CGFloat(depth))
        let font = UIFont(name: "Futura", size: 0.15)
        textNode.font = font
        textNode.alignmentMode = kCAAlignmentCenter
        textNode.firstMaterial?.diffuse.contents = UIColor.white
        textNode.firstMaterial?.specular.contents = UIColor.black
        textNode.firstMaterial?.isDoubleSided = true
        textNode.chamferRadius = CGFloat(depth)
        
        // Bubble
        let (minBound, maxBound) = textNode.boundingBox
        let bubbleNode = SCNNode(geometry: textNode)
        bubbleNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x) / 2, minBound.y, depth / 2)
        bubbleNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        
        // Sphere
        let sphere = SCNSphere(radius: 0.005)
        sphere.firstMaterial?.diffuse.contents = UIColor.blue
        let sphereNode = SCNNode(geometry: sphere)
        
        // Parent
        addChildNode(bubbleNode)
        addChildNode(sphereNode)
        constraints = [billboardConstraint]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
