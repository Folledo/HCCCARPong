//
//  ViewController.swift
//  HCCCARPong
//
//  Created by Samuel Folledo on 4/21/18.
//  Copyright © 2018 Samuel Folledo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let GameMessageName = "gameMessage"

let BallCategory   : UInt32 = 0x1 << 0
let BottomCategory : UInt32 = 0x1 << 1
let BlockCategory  : UInt32 = 0x1 << 2
let PaddleCategory : UInt32 = 0x1 << 3
let BorderCategory : UInt32 = 0x1 << 4

class Wall:SCNPhysicsBody {
    
}

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var trackerNode: SCNNode!
    var gameHasStarted = false
    var foundSurface = false
    var gamePos = SCNVector3Make(0.0, 0.0, 0.0)
    var mainContainer: SCNNode!
    
    //var ballNode: SCNNode!
    
    override func didMove(toParentViewController parent: UIViewController?) {
        
        
        
        
    }
    
    //update
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self //so we can listen to disruptions or rendering
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/Scene.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        //let ball = SCNScene(named: "art.scnassets/Pokeball.scn")!
        //sceneView.scene = ball
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard !gameHasStarted else {return}
        guard let hitTest = sceneView.hitTest(CGPoint(x: view.frame.midX, y: view.frame.midY), types: [.existingPlane, .featurePoint]).last else {return}
        let trans = SCNMatrix4(hitTest.worldTransform)
        gamePos = SCNVector3Make(trans.m41, trans.m42, trans.m43)
        
        if !foundSurface {
            let trackerPlane = SCNPlane(width: 0.3, height: 0.3)
            trackerPlane.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "targ.png")
            
            
            trackerNode = SCNNode(geometry: trackerPlane)
            trackerNode.eulerAngles.x = .pi * -0.5 //this puts the trackerNode on a flat ground surface
            
            sceneView.scene.rootNode.addChildNode(trackerNode)
        }
        
        trackerNode.position = gamePos
        foundSurface = true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameHasStarted {
            //start game
        } else {
            guard foundSurface else {return}
            
            trackerNode.removeFromParentNode()
            gameHasStarted = true
            
            mainContainer = sceneView.scene.rootNode.childNode(withName: "mainContainer", recursively: false)!
            mainContainer.isHidden = false
            mainContainer.position = SCNVector3Make(gamePos.x, gamePos.y, gamePos.z)
            print("++++mainContainer x: \(gamePos.x), y:\(gamePos.y), z: \(gamePos.z)")
        }
        
        addBall()
        
        /*
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.white
        ambientLight.intensity = 500
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        ambientLightNode.position.y = 3.0
        mainContainer.addChildNode(ambientLightNode)
        
        let omniLight = SCNLight()
        omniLight.type = .omni
        omniLight.color = UIColor.white
        omniLight.intensity = 1000
        let omniLightNode = SCNNode()
        omniLightNode.light = omniLight
        omniLightNode.position.y = 3.0
        mainContainer.addChildNode(omniLightNode)
 */
        
    }
    
    func randomPosition() -> SCNVector3 {
        let randX = (Float(arc4random_uniform(50)) / 100.0) - 0.15
        let randZ = (Float(arc4random_uniform(50)) / 100.0) + 0.8
        return SCNVector3Make(randX, 0.2, randZ) //y is height
    }
    
    @objc func addBall() {
        let mySphere = SCNSphere(radius: 0.065)
        let mySphereNode = SCNNode(geometry: mySphere)
        mySphereNode.position = randomPosition()
        mySphereNode.physicsBody?.restitution = 1.0
        
        //ballNode = sceneView.scene.rootNode.childNode(withName: "ship", recursively: false)?.copy() as! SCNNode
        mySphereNode.isHidden = false
        //ballNode.position = randomPosition()
        
        mainContainer.addChildNode(mySphereNode)
        
        mySphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        mySphereNode.physicsBody?.isAffectedByGravity = false
        mySphereNode.physicsBody?.applyForce(SCNVector3Make(0.0, 0.0, -3.0), asImpulse: true) //speed of the ball
        
        
        
        
        let ballDisappearAction = SCNAction.sequence([SCNAction.wait(duration: 5.0), SCNAction.fadeOut(duration: 1.0), SCNAction.removeFromParentNode()]) //after 5 seconds of ship moving, fadeOut, then remove the ball
        mySphereNode.runAction(ballDisappearAction)
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(addBall), userInfo: nil, repeats: false)//Creates a timer and schedules it on the current run loop in the default mode.
        
    }
    
//
//    func cleanScene() {
//        for node in sceneView.rootNode.childNodes {
//
//            if node.presentation.position.y < -2 {
//                node.removeFromParentNode()
//            }
//        }
//    }//end of cleanScene method
    
    
    
    
}
