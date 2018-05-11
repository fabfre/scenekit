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

class ViewController: UIViewController, ARSessionDelegate {
    
    var vectorPoints:[SCNVector3] = []
    var cameraNode: SCNNode!
    var scnScene: SCNScene!
    let configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var sceneKit: SCNView!
    @IBOutlet weak var ARSceneKit: ARSCNView!
    @IBOutlet weak var stopRecroding: UIButton!
    
    @IBAction func startRecording(_ sender: Any) {
        self.vectorPoints = []
        
        ARSceneKit.isHidden = false
        
        ARSceneKit.session.run(configuration)
        label.text = "capturing"
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        setupScene()
        setupCamera()
        
        ARSceneKit.isHidden = true
        
        ARSceneKit.session.pause()
        label.text = "paused"
        if (vectorPoints.count > 2) {
            let pcNode = self.getNode()
            pcNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
            scnScene.rootNode.addChildNode(pcNode)
        }
    }
    
    @IBAction func resetAction(_ sender: Any) {
        for child in scnScene.rootNode.childNodes {
            child.removeFromParentNode()
        }
        self.vectorPoints = []
        ARSceneKit.session.pause()
        label.text = "paused"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ARSceneKit.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        ARSceneKit.session.delegate = self
        ARSceneKit.session.run(configuration)
        label.text = "capturing"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnScene.background.contents = UIColor.red
        sceneKit.scene = scnScene
        
        sceneKit.allowsCameraControl = true
        sceneKit.autoenablesDefaultLighting = true
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        //print("session did update")
        guard let frame = session.currentFrame, let points = frame.rawFeaturePoints?.points else {
            return
        }
        
        DispatchQueue.main.async() {
            for point in points {
                self.vectorPoints.append(SCNVector3(point))
            }
        }
    }
    
    public func getNode() -> SCNNode {
        let points = self.vectorPoints
        var vertices = Array(repeating: PointCloudVertex(x: 0,y: 0,z: 0,r: 0,g: 0,b: 0), count: points.count)
        
        for i in 0...(points.count-1) {
            let p = points[i]
            vertices[i].x = Float(p.x)
            vertices[i].y = Float(p.y)
            vertices[i].z = Float(p.z)
            vertices[i].r = Float(0.0)
            vertices[i].g = Float(1.0)
            vertices[i].b = Float(1.0)
        }
        
        let node = buildNode(points: vertices)
        return node
    }
    
    private func buildNode(points: [PointCloudVertex]) -> SCNNode {
        let vertexData = NSData(
            bytes: points,
            length: MemoryLayout<PointCloudVertex>.size * points.count
        )
        let positionSource = SCNGeometrySource(
            data: vertexData as Data,
            semantic: SCNGeometrySource.Semantic.vertex,
            vectorCount: points.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<PointCloudVertex>.size
        )
        let colorSource = SCNGeometrySource(
            data: vertexData as Data,
            semantic: SCNGeometrySource.Semantic.color,
            vectorCount: points.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: MemoryLayout<Float>.size * 3,
            dataStride: MemoryLayout<PointCloudVertex>.size
        )
        let elements = SCNGeometryElement(
            data: nil,
            primitiveType: .point,
            primitiveCount: points.count,
            bytesPerIndex: MemoryLayout<Int>.size
        )
        let pointsGeometry = SCNGeometry(sources: [positionSource, colorSource], elements: [elements])

        return SCNNode(geometry: pointsGeometry)
    }
    
}


