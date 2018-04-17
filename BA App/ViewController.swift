//
//  ViewController.swift
//  BA App
//
//  Created by Fabian Frey on 17.04.18.
//  Copyright © 2018 Fabian Frey. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

public enum ShapeType:Int {
    
    case Box = 0
    case Sphere
    case Pyramid
    case Torus
    case Capsule
    case Cylinder
    case Cone
    case Tube
    
    // 2
    static func random() -> ShapeType {
        let maxValue = Tube.rawValue
        let rand = arc4random_uniform(UInt32(maxValue+1))
        return ShapeType(rawValue: Int(rand))!
    }
}


class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet weak var sceneKit: SCNView!
    
    @IBAction func startRecording(_ sender: Any) {
        let configuration = ARWorldTrackingConfiguration()
        session.run(configuration)
    }
    
    @IBOutlet weak var stopRecroding: UIButton!
    
    @IBAction func stopRecording(_ sender: Any) {
        session.pause()
    }
    
    
    var cameraNode: SCNNode!
    var scnScene: SCNScene!
    let session = ARSession()
    
    func setupScene() {
        scnScene = SCNScene()
        scnScene.background.contents = UIColor.red
        sceneKit.scene = scnScene
        
        sceneKit.showsStatistics = true
        sceneKit.allowsCameraControl = true
        sceneKit.autoenablesDefaultLighting = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupScene()
        setupCamera()
        self.session.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        session.run(configuration)
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        
        scnScene.rootNode.addChildNode(cameraNode)
        //spawnShape()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Access the last frame
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        print("session did update")
        guard let frame = session.currentFrame, let points = frame.rawFeaturePoints?.points else {
            return
        }
        
        let camera = frame.camera.transform
        for point in points {
            //let vektor = multiply(camera, point)
            let sphere = SCNSphere(radius: 0.05)
            var geometryNode = SCNNode(geometry: sphere)
            geometryNode.position = SCNVector3(point)
            print(point)
            self.scnScene.rootNode.addChildNode(geometryNode)
        }
    }
    
    func spawnShape() {
        // 1
        var geometry:SCNGeometry
        // 2
        switch ShapeType.random() {
        default:
            // 3
            geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        }
        // 4
        let geometryNode = SCNNode(geometry: geometry)
        // 5
        scnScene.rootNode.addChildNode(geometryNode)
    }
    
    
    func multiply( _ matrixA: matrix_float3x3, _ vectorB:vector_float3) -> SCNVector3 {
        let x:Float = Float((matrixA.columns.0.x * vectorB.x) + (matrixA.columns.1.x * vectorB.y) + (matrixA.columns.2.x * vectorB.z))
        let y:Float = Float((matrixA.columns.0.y * vectorB.x) + (matrixA.columns.1.y * vectorB.y) + (matrixA.columns.2.y * vectorB.z))
        let z:Float = Float((matrixA.columns.0.z * vectorB.x) + (matrixA.columns.1.z * vectorB.y) + (matrixA.columns.2.z * vectorB.z))
        
        return SCNVector3.init(vector_float3.init(x,y,z))
    }
    
    func prefersStatusBarHidden() -> Bool {
        return true
    }
}

