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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var trackerNode: SCNNode!
    var gameHasStarted = false
    var foundSurface = false
    var gamePos = SCNVector3Make(0.0, 0.0, 0.0)
    var mainContainer: SCNNode!
    var ballNode: SCNNode!
    
    
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
            trackerPlane.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "compass2")
            
            
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
            mainContainer.isHidden = true
            mainContainer.position = gamePos
        }
        
        addBall()
        
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
        
    }
    
    func randomPosition() -> SCNVector3 {
        let randX = (Float(arc4random_uniform(200)) / 100.0) - 1.0
        let randY = (Float(arc4random_uniform(200)) / 100.0) + 1.5
        return SCNVector3Make(randX, randY, -3.0)
    }
    
    @objc func addBall() {
        ballNode = sceneView.scene.rootNode.childNode(withName: "pokeball", recursively: false)?.copy() as! SCNNode
        ballNode.isHidden = false
        ballNode.position = randomPosition()
        
        mainContainer.addChildNode(ballNode)
        
        ballNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        ballNode.physicsBody?.isAffectedByGravity = false
        ballNode.physicsBody?.applyForce(SCNVector3Make(0.0, 0.0, 2.0), asImpulse: true) //speed of the ball
        
        let ballDisappearAction = SCNAction.sequence([SCNAction.wait(duration: 5.0), SCNAction.fadeOut(duration: 1.0), SCNAction.removeFromParentNode()]) //wait, fadeOut, then remove the ball
        ballNode.runAction(ballDisappearAction)
        
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(addBall), userInfo: nil, repeats: false)//Creates a timer and schedules it on the current run loop in the default mode.
        
    }
    
}
