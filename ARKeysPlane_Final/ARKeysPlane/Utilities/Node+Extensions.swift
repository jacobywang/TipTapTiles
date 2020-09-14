//
//  Node+Extensions.swift
//  ARWalkthrough
//
//  Created by Wyszynski, Daniel on 2/18/18.
//  Copyright © 2018 Nike, Inc. All rights reserved.
//

import SceneKit

extension SCNNode {

    public class func allNodes(from file: String) -> [SCNNode] {
        var nodesInFile = [SCNNode]()
        
        do {
            guard let sceneURL = Bundle.main.url(forResource: file, withExtension: nil) else {
                print("Could not find scene file \(file)")
                return nodesInFile
            }
            
            let objScene = try SCNScene(url: sceneURL as URL, options: [SCNSceneSource.LoadingOption.animationImportPolicy:SCNSceneSource.AnimationImportPolicy.doNotPlay])
            
            for childNode in objScene.rootNode.childNodes {
                nodesInFile.append(childNode)
            }
        } catch {
            
        }
        
        return nodesInFile
    }

    func topmost(parent: SCNNode? = nil, until: SCNNode) -> SCNNode {
        if let pNode = self.parent {
             return pNode == until ? self : pNode.topmost(parent: pNode, until: until)
        } else {
            return self
        }
    }
    
    public func centerPivot() {
        var min = SCNVector3Zero
        var max = SCNVector3Zero
        (min, max) = self.boundingBox
        self.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2
        )
    }

}
