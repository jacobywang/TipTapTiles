//
//  GraphicScene.swift
//  ARKeysPlane
//
//  Created by Jacob Wang on 2/21/19.
//  Copyright © 2019 Jacob Wang. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

struct GraphicScene {
    
    var scene: SCNScene?
    
    init() {
        scene = self.initializeScene()
    }
    
    func initializeScene() -> SCNScene? {
        let scene = SCNScene()
        
        setDefaults(scene: scene)
        
        return scene
    }
    
    func setDefaults(scene: SCNScene) {
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = SCNLight.LightType.ambient
        ambientLightNode.light?.color = UIColor(white: 0.6, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)

        // Create a directional light with an angle to provide a more interesting look
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.color = UIColor(white: 0.8, alpha: 1.0)
        directionalLight.shadowRadius = 5.0
        directionalLight.shadowColor = UIColor.black.withAlphaComponent(0.6)
        directionalLight.castsShadow = true
        directionalLight.shadowMode = .deferred
        let directionalNode = SCNNode()
        directionalNode.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(-40), GLKMathDegreesToRadians(0), GLKMathDegreesToRadians(0))
        directionalNode.light = directionalLight
        scene.rootNode.addChildNode(directionalNode)
    }
    
//    func addLane(sView: ARSCNView , parent: SCNNode, position: SCNVector3 = SCNVector3Zero) {
//        guard let scene = self.scene else { return }
//
//        let laneNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.01, length: 0.2, chamferRadius: 0.0))
//        //laneNode.geometry?.firstMaterial?.colorBufferWriteMask = []
//        laneNode.position = scene.rootNode.convertPosition(position, to: parent)
//
//        laneNode.eulerAngles.y = (sView.session.currentFrame?.camera.eulerAngles.y)!
//
//        parent.addChildNode(laneNode)
//        //add bounce animation
//    }
//
//    func addText(string: String, parent: SCNNode, position: SCNVector3 = SCNVector3Zero) {
//        guard let scene = self.scene else { return }
//
//        let textNode = self.createTextNode(string: string)
//        textNode.position = scene.rootNode.convertPosition(position, to: parent)
//
//        parent.addChildNode(textNode)
//    }
    
//    func createTextNode(string: String) -> SCNNode {
//        let text = SCNText(string: string, extrusionDepth: 0.1)
//        text.font = UIFont.systemFont(ofSize: 1.0)
//        text.flatness = 0.01
//        text.firstMaterial?.diffuse.contents = UIColor.white
//
//        let textNode = SCNNode(geometry: text)
//        textNode.castsShadow = true
//
//        let fontSize = Float(0.04)
//        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
//
//        var minVec = SCNVector3Zero
//        var maxVec = SCNVector3Zero
//        (minVec, maxVec) =  textNode.boundingBox
//        textNode.pivot = SCNMatrix4MakeTranslation(
//            minVec.x + (maxVec.x - minVec.x)/2,
//            minVec.y,
//            minVec.z + (maxVec.z - minVec.z)/2
//        )
//
//        return textNode
//    }
    
}

