//
//  ViewController.swift
//  ARKeysPlane
//
//  Created by Jacob Wang on 2/21/19.
//  Copyright © 2019 Jacob Wang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


//maybe–image tracking https://youtu.be/ySYFZwkZoio
//maybe ^ just set rendering order of lane and image/foot
class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var placeHereButton: UIButton!
    @IBOutlet weak var retryPlacingButton: UIButton!
    @IBOutlet weak var continueAfterPlaceButton: UIButton!
    
    @IBOutlet weak var pauseView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var finalScoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    
    var touchMode: Bool!
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        return formatter
    }()
    
    var sceneController = GraphicScene()    
    var lane: Lane!
    var laneNotInScene = true
    var screenCenter = CGPoint()
    
    var timer: Timer? = nil
    
    var imageDotLocation = CGPoint(x: 0.0, y: 0.0)
    
    var placedLane = false
    var planes = [ARPlaneAnchor: Plane]()
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private var worldConfiguration: ARWorldTrackingConfiguration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // Create a new scene
        if let scene = sceneController.scene {
            // Set the scene to the view
            sceneView.scene = scene
        }

        screenCenter = view.center
        
        feedbackGenerator.prepare()
        
        placeHereButton.layer.cornerRadius = 25
        placeHereButton.layer.borderWidth = 1.5
        placeHereButton.layer.borderColor = UIColor.white.cgColor
        //placeHereButton.isHidden = true
        
        retryPlacingButton.layer.cornerRadius = 15
        retryPlacingButton.layer.borderWidth = 1.5
        retryPlacingButton.layer.borderColor = UIColor.white.cgColor
        
        continueAfterPlaceButton.layer.cornerRadius = 15
        continueAfterPlaceButton.layer.borderWidth = 1.5
        continueAfterPlaceButton.layer.borderColor = UIColor.white.cgColor
        
        retryPlacingButton.isHidden = true
        continueAfterPlaceButton.isHidden = true
        
        sessionInfoLabel.layer.cornerRadius = 10
        sessionInfoLabel.layer.borderWidth = 1.5
        sessionInfoLabel.layer.borderColor = UIColor.white.cgColor
        
        setupPauseView()
        setupImageTracking()
        if touchMode {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapScreen))
            tapRecognizer.numberOfTapsRequired = 1
            tapRecognizer.numberOfTouchesRequired = 1
            self.view.addGestureRecognizer(tapRecognizer)
        }
        
    }
    
    @objc func didTapScreen(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        if let node = hitTestResults.first?.node {
            if node.name == "tile" && lane.timeRemaining > 0 {
                tileTap(node)     //other tap code
                if self.lane.gameMode == .classic {
                    self.scoreLabel.text = "\(self.lane.score)"
                }
                
                self.feedbackGenerator.impactOccurred()
            }
        }
    }
    
    func setupPauseView() {
        pauseView.isHidden = true
        pauseView.backgroundColor = .white
        pauseView.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        if let configuration = worldConfiguration {
            configuration.planeDetection = [.horizontal]
            
            sceneView.session.run(configuration)
        }
        
        sceneView.session.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    private func setupImageTracking() {
        worldConfiguration = ARWorldTrackingConfiguration()
        
        guard let referenceImages = ARReferenceImage.referenceImages(
            inGroupNamed: "AR Images", bundle: nil) else {
                fatalError("Missing expected asset catalog resources.")
        }
        worldConfiguration?.detectionImages = referenceImages
        worldConfiguration?.maximumNumberOfTrackedImages = 2
    }
    
    @IBAction func restartButtonTapped(_ sender: Any) {
        resetLane()
        pauseView.isHidden = true
        scoreLabel.text = "0"
        preGameSetup()
    }

    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        if !placedLane{
            let plane = Plane(anchor)
            planes[anchor] = plane
            
            node.addChildNode(plane)
            //print("Added plane: \(plane)")
        }
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        if !placedLane{
            if let plane = planes[anchor] {
                plane.update(anchor)
            }
        }
    }
    
    //dont use anymore
    func removePlane(anchor: ARPlaneAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            plane.removeFromParentNode()
        }
    }
    
//————Initial Moving of Lane
    
    @IBAction func placeLane(_ sender: Any) {
        if !laneNotInScene{
            placedLane = true
            feedbackGenerator.impactOccurred()
            self.placeHereButton.isHidden = true
            self.retryPlacingButton.isHidden = false
            self.continueAfterPlaceButton.isHidden = false
        }
    }
    
    @IBAction func retryPlaceLane(_ sender: Any) {
        placedLane = false
        DispatchQueue.main.async {
            self.placeHereButton.isHidden = false
            self.retryPlacingButton.isHidden = true
            self.continueAfterPlaceButton.isHidden = true
        }
    }
    
    func preGameSetup() {
        self.countdownLabel.isHidden = false
        
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
        
        //func to start the actual game — 3,2,1
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
            self.countdownLabel.isHidden = true
            self.countdownLabel.text = "3"
            
            switch self.lane.gameMode {
            case .classic:
                self.scoreLabel.text = "0"
            case .arcade:
                self.scoreLabel.text = "\(self.lane.timeRemaining)"
            case .timeTrial:
                self.scoreLabel.text = "\(self.lane.timeTakes)"
            }
            
            self.scoreLabel.isHidden = false
            self.lane.runNewGame()
        })
    }
    
    @IBAction func continueAfterPlaceLane(_ sender: Any) {
        DispatchQueue.main.async {
            self.retryPlacingButton.isHidden = true
            self.continueAfterPlaceButton.isHidden = true
            self.preGameSetup()
            
        }
        
//        for p in self.planes {
//            //print(p.1)
//            p.1.geometry?.firstMaterial?.transparency = 0.0
//        }
//
    }
    
    func updateLane() {
        if let worldPos = worldPositionFromScreenPosition(CGPoint(x: screenCenter.x, y: screenCenter.y - 170), self.sceneView){
            self.lane.node.simdPosition = worldPos
            if laneNotInScene {
                sceneView.scene.rootNode.addChildNode(self.lane.node)
                laneNotInScene = false
                //placeHereButton.isHidden = false    //causes delay
                //feedbackGenerator.impactOccurred()  //causes crash
            }
            lane.node.eulerAngles.y = (sceneView.session.currentFrame?.camera.eulerAngles.y)!
        }
    }
    
    func worldPositionFromScreenPosition(_ position: CGPoint, _ sceneView: ARSCNView) -> float3? {
        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            return result.worldTransform.translation
        }
        return nil
    }
    
    var countDownTime = 3
    
    @objc func countDown() {
        countDownTime -= 1
        if countDownTime == 0{
            countdownLabel.text = "GO!"
            timer!.invalidate()
            timer = nil
            countDownTime = 3
        } else {
            countdownLabel.text = "\(countDownTime)"
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.addPlane(node: node, anchor: planeAnchor)
                //self.feedbackGenerator.impactOccurred()
            }
        }
        if let imageAnchor = anchor as? ARImageAnchor {
            handleFoundImage(imageAnchor, node)
        } else {
            print("did not detect image")
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.updatePlane(anchor: planeAnchor)
            }
        }
        
        if let _ = anchor as? ARImageAnchor/*, !touchMode*/ {
            //node.presentation.position
            let screenPosition = renderer.projectPoint(node.worldPosition)
            self.imageDotLocation = CGPoint(x: CGFloat(screenPosition.x), y: CGFloat(screenPosition.y))
            
            let hitTestResults = sceneView.hitTest(self.imageDotLocation)

            if let n = hitTestResults.first?.node {
                if n.name == "tile" && lane.timeRemaining > 0 {
                    print("intersect")
                    tileTap(n)
                    print(lane.score)
                    DispatchQueue.main.async {
                        if self.lane.gameMode == .classic {
                            self.scoreLabel.text = "\(self.lane.score)"
                        }
                        
                        self.feedbackGenerator.impactOccurred()
                    }
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {

    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if !placedLane{
            updateLane()
        }
        
        if imageDotLocation != CGPoint(x: 0.0, y: 0.0){
            let hitTestResults = sceneView.hitTest(self.imageDotLocation)
            
            if let n = hitTestResults.first?.node {
                if n.name == "tile" && lane.timeRemaining > 0 {
                    print("intersect")
                    tileTap(n)
                    print(lane.score)
                    DispatchQueue.main.async {
                        if self.lane.gameMode == .classic {
                            self.scoreLabel.text = "\(self.lane.score)"
                        }
                        
                        self.feedbackGenerator.impactOccurred()
                    }
                }
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
//    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//        guard let frame = session.currentFrame else { return }
//        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
//    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
        //guide user to improve tracking
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
            
        }
        
        sessionInfoLabel.text = message
        sessionInfoLabel.isHidden = message.isEmpty
    }
    
    private func handleFoundImage(_ imageAnchor: ARImageAnchor, _ node: SCNNode) {
        let name = imageAnchor.referenceImage.name!
        print("you found a \(name) image")
        
        let size = imageAnchor.referenceImage.physicalSize
        
        if let imageNode = makeImageNode(size: size) {
            node.addChildNode(imageNode)

            node.opacity = 1
        }
    }
    
    private func makeImageNode(size: CGSize) -> SCNNode? {
        let imagePlane = SCNPlane(width: size.width/4, height: size.height/4)
        imagePlane.cornerRadius = size.width/8
        
        let imageNode = SCNNode(geometry: imagePlane)

        imageNode.name = "imageNode"
        imageNode.eulerAngles.x = -.pi / 2
        imageNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red

        return imageNode
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("contact")
    }
    
    func tileTap(_ node: SCNNode) {
        node.removeFromParentNode()
        
        if lane.gameMode != .timeTrial {
            lane.score += 1
        }
        
        if lane.gameMode != .classic {//classic
            let index = lane.tiles.index(of: node)
            lane.tiles.remove(at: index!)
            
            if lane.tiles.count >= 1 {
                for i in 0...lane.tiles.count - 1 {
                    if i >= index! {
                        lane.tiles[i].runAction(SCNAction.move(by: SCNVector3(0, 0, Float(1/5 * lane.l)), duration: 0.5))
                    }
                }
            }
            
            if lane.gameMode == .arcade {    //arcade
                lane.tiles.append(lane.addTile(SCNVector3(lane.randomX(), 0.015, -2/5 * lane.l)).1)
                //lane.score += 1
            } else {  //time trial
                if lane.tilesRemainToPlace > 0 {
                    lane.tiles.append(lane.addTile(SCNVector3(lane.randomX(), 0.015, -2/5 * lane.l)).1)
                    lane.tilesRemainToPlace -= 1
                }
                
                lane.tilesRemaining -= 1
                
                if lane.tilesRemaining == 0 {
                    lane.gameOver = true
                    lane.timer!.invalidate()
                    lane.timer = nil
                    lane.tilesRemainToPlace = 20
                    lane.tilesRemaining = 25
                    gameOver()
                }
            }
        }
    }
    
    func resetLane() {
        for n in lane.node.childNodes {
            n.removeFromParentNode()
        }
        lane.tiles = []
        lane.tilesRemaining = 25
        lane.timeRemaining = lane.timeForArcade
        lane.score = 0
        lane.timeTakes = 0
        lane.gameOver = false
    }
}

extension ViewController: GameDelegate {
    func gameOver() {
        OperationQueue.main.addOperation {
            self.scoreLabel.isHidden = true
            switch self.lane.gameMode {
            case .classic:
                if self.lane.score > UserDefaults.standard.integer(forKey: "classicHighScore") {
                    UserDefaults.standard.set(self.lane.score, forKey: "classicHighScore")
                }
                self.highScoreLabel.text = "High Score: \(UserDefaults.standard.integer(forKey: "classicHighScore"))"
                self.finalScoreLabel.text = "\(self.lane.score)"
            case .arcade:
                if self.lane.score > UserDefaults.standard.integer(forKey: "arcadeHighScore") {
                    UserDefaults.standard.set(self.lane.score, forKey: "arcadeHighScore")
                }
                self.highScoreLabel.text = "High Score: \(UserDefaults.standard.integer(forKey: "arcadeHighScore"))"
                self.finalScoreLabel.text = "\(self.lane.score)"
            case .timeTrial:
                if self.lane.timeTakes < UserDefaults.standard.double(forKey: "timeTrialHighScore") || UserDefaults.standard.double(forKey: "timeTrialHighScore") == 0.0 {
                    UserDefaults.standard.set(self.lane.timeTakes, forKey: "timeTrialHighScore")
                }
                self.highScoreLabel.text = "High Score: \(String(describing: self.numberFormatter.string(from: NSNumber(value: UserDefaults.standard.double(forKey: "timeTrialHighScore")))!))'s"
                self.finalScoreLabel.text = "\(self.numberFormatter.string(for: self.lane.timeTakes)!)'s"
            }

            self.pauseView.isHidden = false
        }
        
        print("game over")
    }
    
    func timerUpdate(value: Double) {
        self.scoreLabel.text = numberFormatter.string(from: NSNumber(value: value))
    }
}
