//
//  ViewController.swift
//  ARDicee
//
//  Created by Sai Naveen Katla on 02/10/20.
//  Copyright © 2020 Sai Naveen Katla. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
//        print("here")
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//        let sphere = SCNSphere(radius: 0.2)
//        let material = SCNMaterial()r
//        material.diffuse.contents = UIImage(named: "art.scnassets/8k_moon.jpg")
//        sphere.materials = [material]
//
//        let node = SCNNode()
//        node.position = SCNVector3(0, 0.1, -0.5)
//
//        node.geometry = sphere
//
//        sceneView.scene.rootNode.addChildNode(node)
//        sceneView.autoenablesDefaultLighting = true
//
        
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        print("ARWorldTracking is Supported: \(ARWorldTrackingConfiguration.isSupported)")
        print("Session is Supported: \(ARConfiguration.isSupported)")
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func rollAgain(_ sender: Any) {
        rollAll()
    }
    
    @IBAction func removeButton(_ sender: Any) {
        removeAll()
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dicenode in diceArray {
                dice(dice: dicenode)
            }
        }
    }
    
    func removeAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    func dice(dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        //5 as more revolutions 5 times. 10 will give 10 times.
        dice.runAction(.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
    }
    
    //MARK: - ARSCNViewDelegate
    
    //caleed when touches are detected
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: sceneView)
            
            //convert 2D touch position to 3D
            let results = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                let dice = SCNScene(named: "art.scnassets/diceCollada.scn")!
                if let diceNode = dice.rootNode.childNode(withName: "Dice", recursively: true) {
                    //columns there are 4 - as worldTransform is 4*4 matrix - scale, rotation, -, position
                    diceNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x,
                                                   y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                                                   z: hitResult.worldTransform.columns.3.z)
                    diceArray.append(diceNode)
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
                    let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
                    
                    //5 as more revolutions 5 times. 10 will give 10 times.
                    diceNode.runAction(.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
                }
            }
        }
    }
    
    //detecting nodes
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            print("Horizontal Plane found")
            let planeAchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAchor.extent.x), height: CGFloat(planeAchor.extent.z))
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(planeAchor.center.x, 0, planeAchor.center.z)
            
            //SCNPlane creates rectangle vertically by default(x and y) but we need it in horizontal(x and z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
        }
        else {
            return
        }
    }
    
    
}
