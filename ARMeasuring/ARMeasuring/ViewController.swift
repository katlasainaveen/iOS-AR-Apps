//
//  ViewController.swift
//  ARMeasuring
//
//  Created by Sai Naveen Katla on 04/10/20.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
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
    
    func addDot(at location: ARHitTestResult) {
        let sphere = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        sphere.materials = [material]
        
        let node = SCNNode(geometry: sphere)
        node.position = SCNVector3(location.worldTransform.columns.3.x, location.worldTransform.columns.3.y, location.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(node)
        dotNodes.append(node)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = pow(pow(a, 2) + pow(b, 2) + pow(c, 2), 0.5)
        
        updateText(with: "\(abs(distance))", at: end.position)
    }
    
    func updateText(with text: String, at position: SCNVector3) {
        textNode.removeFromParentNode()
        
        let textgeometry = SCNText(string: text, extrusionDepth: 1.0)
        textgeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textgeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touch = touches.first {
            let location = touch.location(in: sceneView)
            let hitTestResult = sceneView.hitTest(location, types: .featurePoint)
            
            if let hitResult = hitTestResult.first {
                addDot(at: hitResult)
            }
        }
    }

    
}
