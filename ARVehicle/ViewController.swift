//
//  ViewController.swift
//  ARVehicle
//
//  Created by Sai Balaji on 20/08/23.
//

import UIKit
import SceneKit
import ARKit

enum BodyType: Int{
    case car = 1
    case floor = 2
}

class ViewController: UIViewController{
    
    @IBOutlet var sceneView: ARSCNView!
    var carChassisNode: SCNNode!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
   
        
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        
        
      
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc func tapped(tapGesture: UITapGestureRecognizer){
        let location = tapGesture.location(in: self.sceneView)
        let hitResult = sceneView.session.raycast(sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .horizontal)!)
        if !hitResult.isEmpty{
            self.addCar(result: hitResult.first!)
        }
    }
    
    func addCar(result: ARRaycastResult){
        let carScene = SCNScene(named: "art.scnassets/car.scn")!
        carChassisNode = carScene.rootNode.childNode(withName: "car", recursively: true)!
        
        carChassisNode.scale = SCNVector3(0.02, 0.02, 0.02)
        carChassisNode.position = SCNVector3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y + 0.002, result.worldTransform.columns.3.z)
        carChassisNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        let wheelFLNode = carScene.rootNode.childNode(withName: "wheelFL", recursively: true)!
        let wheelFRNode = carScene.rootNode.childNode(withName: "wheelFR", recursively: true)!
        let wheelRLNode = carScene.rootNode.childNode(withName: "wheelRL", recursively: true)!
        let wheelRRNode = carScene.rootNode.childNode(withName: "wheelRR", recursively: true)!
       
        wheelFRNode.scale = SCNVector3(0.02, 0.02, 0.02)
        wheelFLNode.scale = SCNVector3(0.02, 0.02, 0.02)
        wheelRRNode.scale = SCNVector3(0.02, 0.02, 0.02)
        wheelRLNode.scale = SCNVector3(0.02, 0.02, 0.02)
        
        
        let wheelFL = SCNPhysicsVehicleWheel(node: wheelFLNode)
        let wheelFR = SCNPhysicsVehicleWheel(node: wheelFRNode)
        let wheelRL = SCNPhysicsVehicleWheel(node: wheelRLNode)
        let wheelRR = SCNPhysicsVehicleWheel(node: wheelRRNode)
        

        
        
        let vehicle = SCNPhysicsVehicle(chassisBody: carChassisNode.physicsBody!
                                        , wheels: [wheelFL,wheelFR,wheelRL,
                                                   wheelRR])
        sceneView.scene.physicsWorld.addBehavior(vehicle)

        sceneView.scene.rootNode.addChildNode(carChassisNode)
        
    }
    
    
    
}


extension ViewController: ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("ADD")
        if let planeAnchor = anchor as? ARPlaneAnchor{
            self.addGrounPlane(anchor: planeAnchor,node: node)
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
       // print("UPDATE")
        node.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
        if let planeAnchor = anchor as? ARPlaneAnchor{
            self.addGrounPlane(anchor: planeAnchor,node: node)
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("REMOVE")
        node.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
    }
}




extension ViewController{
    func addGrounPlane(anchor: ARPlaneAnchor,node: SCNNode){
       // print(node)
        let floorPlane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        floorPlane.materials.first?.diffuse.contents = UIColor.gray
        floorPlane.materials.first?.isDoubleSided = true
        let floorNode = SCNNode(geometry: floorPlane)
        floorNode.position = SCNVector3(anchor.center.x, 0.0, anchor.center.z)
        floorNode.eulerAngles = SCNVector3(x: Float(Double.pi) / 2, y: 0, z: 0)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: floorPlane,options: nil))
        floorNode.physicsBody?.categoryBitMask = BodyType.floor.rawValue
        node.addChildNode(floorNode)

        
    }
}
