//
//  Lane.swift
//  ARKeysPlane
//
//  Created by Jacob Wang on 4/18/19.
//  Copyright © 2019 Jacob Wang. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit


enum GameModeType{
    case classic, arcade, timeTrial
}

protocol GameDelegate {
    func gameOver()
    func timerUpdate(value: Double)
}

class Lane {
    var gameDelegate: GameDelegate!
    let node = SCNNode()
    let w: CGFloat = 0.6
    let l: CGFloat = 2
    var timer: Timer? = nil
    //    let viewNode = SCNNode(geometry: SCNPlane(width: 0.5, height: 1))
    
    // —— GAMEBOARD
    var gameMode: GameModeType
    var rate = 2.0 //tiles per sec
    var score = 0
    var gameOver = false
    
    var tiles: [SCNNode] = []
    //arcade
    var timeForArcade = 15.0
    var timeRemaining = 15.0 //time ticking down each second
    //time trial
    var tilesRemaining = 25
    var tilesRemainToPlace = 20
    var timeTakes = 0.0
    
    init(gameMode: GameModeType) {
        self.gameMode = gameMode
        node.geometry = SCNBox(width: w, height: 0.01, length: l, chamferRadius: 0.0)
        //        viewNode.position = SCNVector3(0, 0.011, 0)
        //        node.addChildNode(viewNode)
        //        viewNode.eulerAngles.x = -Float.pi/2
        
    }
    
    func newPosition(_ p: SCNVector3) {
        node.position = p
    }
    
    func runNewGame() {
        //gameMode = .arcade
        
        if gameMode == .classic {
            timer = Timer.scheduledTimer(timeInterval: TimeInterval((11000 / rate).rounded()/10000), target: self, selector: #selector(runClassic), userInfo: nil, repeats: true)
        }else {
            var zPos = 2/5 * l
            for _ in 0...4{
                tiles.append(addTile(SCNVector3(randomX(), 0.015, zPos)).1)
                zPos -= 1/5 * l
            }
            if gameMode == .arcade{
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimerFiresDecrease), userInfo: nil, repeats: true)
            } else {
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimerFiresIncrease), userInfo: nil, repeats: true)
            }
        }
    }
    
    func randomX() -> CGFloat {
        let x = CGFloat(Int.random(in: 0...3))
        switch x{
        case 0:
            return self.w * -3/8
        case 1:
            return self.w * -1/8
        case 2:
            return self.w * 1/8
        default:
            return self.w * 3/8
        }
    }
    
    //CLASSIC
    @objc func runClassic() {
        let tile = addTile(SCNVector3(randomX(), 0.015, -self.l*3/5))
        moveDownClassic(tile.0, tile.1)
    }
    
    @discardableResult
    func addTile(_ p: SCNVector3) -> (CGFloat, SCNNode) {
        let width = self.w / 4
        let length = self.l / 5
        let tile = SCNNode(geometry: SCNBox(width: width, height: 0.02, length: length, chamferRadius: 0.0))
        tile.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        tile.position = p
        tile.name = "tile"
        node.addChildNode(tile)
        return (length, tile)
    }
    
    fileprivate func moveDownClassic(_ length: CGFloat, _ tile: SCNNode) {
        let duration = (70000 / rate).rounded()/10000
        //print("\((5 / rate) / 5 == 1 / rate) : \((5 / rate) / 5) \(1 / rate)")
        
        let actionMove = SCNAction.move(by: SCNVector3(0, 0, Float(length*6)), duration: TimeInterval(duration))
        //        let actionRemove = SCNAction.removeFromParentNode()
        let loseAction = SCNAction.run { (tile) in
            UIView.animate(withDuration: 0.5, animations: {
                tile.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                self.timer!.invalidate()
                //tile.runAction(actionRemove)
                UIView.animate(withDuration: 1.0, animations: {
                    for t in self.tiles{
                        t.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                    }
                })
                if !self.gameOver {
                    self.gameOver = true
                    self.gameDelegate.gameOver()
                }
                
            })
        }
        tile.runAction(SCNAction.sequence([actionMove, loseAction]))
    }
    
    //ARCADE
    @objc func onTimerFiresDecrease() {
        print(timeRemaining)
        timeRemaining -= 0.1
        self.gameDelegate.timerUpdate(value: timeRemaining)
        if timeRemaining <= 0 {
            if !self.gameOver {
                self.gameOver = true
                self.gameDelegate.gameOver()
            }
            self.timer!.invalidate()
            self.timer = nil
            print("should be over")
            //black -> red
            UIView.animate(withDuration: 1.0, animations: {
                for t in self.tiles{
                    t.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                }
            })
        }
    }
    
    //TIME TRIAL
    @objc func onTimerFiresIncrease() {
        timeTakes += 0.1
        self.gameDelegate.timerUpdate(value: timeTakes)
        print(timeTakes)
    }
}
