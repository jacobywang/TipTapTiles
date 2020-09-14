//
//  Plane.swift
//  ARKeysPlane
//
//  Created by Jacob Wang on 2/21/19.
//  Copyright © 2019 Jacob Wang. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class Plane: SCNNode {
    
    var planeAnchor: ARPlaneAnchor
    
    var planeGeometry: SCNPlane
    var planeNode: SCNNode
//    var shadowPlaneGeometry: SCNPlane
//    var shadowNode: SCNNode
    
    var visible = true
    
    init(_ anchor: ARPlaneAnchor) {
        
        self.planeAnchor = anchor
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        //self.planeGeometry = SCNPlane(width: 3, height: 3)    //need update bc of extent so knows if its a plane or not

//        let grid = UIImage(named: "plane_grid.png")
//        let material = SCNMaterial()
//        material.diffuse.contents = grid
//        self.planeGeometry.materials = [material]

        self.planeGeometry.firstMaterial?.transparency = 0.0
        self.planeNode = SCNNode(geometry: planeGeometry)
        self.planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        self.planeNode.castsShadow = false

//        self.shadowPlaneGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
//        let shadowMaterial = SCNMaterial()
//        shadowMaterial.diffuse.contents = UIColor.white
//        shadowMaterial.lightingModel = .constant
//        shadowMaterial.writesToDepthBuffer = true
//        shadowMaterial.colorBufferWriteMask = []
//
//        self.shadowPlaneGeometry.materials = [shadowMaterial]
//
//        self.shadowNode = SCNNode(geometry: shadowPlaneGeometry)
//        self.shadowNode.transform = planeNode.transform
//        self.shadowNode.castsShadow = false
        
        super.init()
        
        self.name = "plane"
        
        self.addChildNode(planeNode)
//        self.addChildNode(shadowNode)

        self.position = SCNVector3(anchor.center.x, -0.002, anchor.center.z) // 2 mm below the origin of plane.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ anchor: ARPlaneAnchor) {
        self.planeAnchor = anchor
        
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        
//        self.shadowPlaneGeometry.width = CGFloat(anchor.extent.x)
//        self.shadowPlaneGeometry.height = CGFloat(anchor.extent.z)
        
        //this causes orientation problem
        self.position = SCNVector3Make(anchor.center.x, -0.002, anchor.center.z)
    }
    
//    func setPlaneVisibility() {
//        if visible{
//            visible = false
//            self.planeNode.geometry?.firstMaterial?.transparency = 0.0
//        }else{
//            visible = true
//            self.planeNode.geometry?.firstMaterial?.transparency = 0.5
//        }
//        //self.planeNode.isHidden = !visible
//    }
}

