//
//  ViewController.swift
//  SumAR
//
//  Created by OliverPérez on 1/4/19.
//  Copyright © 2019 OliverPérez. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import GameplayKit

class ViewController: UIViewController, ARSCNViewDelegate {

    // MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!

    @IBOutlet weak var heightSlider: UISlider!{
        didSet{
            heightSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        }
    }
    
    @IBOutlet weak var engineSlider: UISlider!{
        didSet{
            engineSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        }
    }
    
    @IBOutlet weak var sumLabel: UILabel!
    
    // MARK: - Variables
    var mainScene = SCNScene()
    var planeDidRender = Bool()
    var airplaneNode = SCNNode()
    var ringNode = SCNNode()

    var xPosition: Float = 0
    var yPosition: Float = 0
    var zPosition: Float = 0.5
    
    var xAngle: Float = 0
    var timerVerticalMovements = Timer()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        mainScene = SCNScene(named: "art.scnassets/ship.scn")!
        if let airplane = mainScene.rootNode.childNode(withName: "ship", recursively: true){
            airplaneNode = airplane
        }
        
        if let ring = mainScene.rootNode.childNode(withName: "torus", recursively: true){
            ringNode = ring
        }
        
        sceneView.autoenablesDefaultLighting = true
        numberGenerator()
        obtainAddends()
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

    // MARK: - ARSCNViewDelegate
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                
                if let airplaneNode = mainScene.rootNode.childNode(withName: "ship", recursively: true){
                    airplaneNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y + 0.01,
                        z: hitResult.worldTransform.columns.3.z)
                    sceneView.scene.rootNode.addChildNode(airplaneNode)
                }
            }
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if (anchor is ARPlaneAnchor) && !planeDidRender {
            
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: 0.5, height: 0.5)
            
            let planeNode = SCNNode()

            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            airplaneNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)

            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            
            let body = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: airplaneNode))
            airplaneNode.physicsBody = body
            airplaneNode.physicsBody?.categoryBitMask = CollisionCategory.airplaneCategory.rawValue
            airplaneNode.physicsBody?.collisionBitMask = CollisionCategory.ringCategory.rawValue
            airplaneNode.physicsBody?.contactTestBitMask = CollisionCategory.ringCategory.rawValue
            
            let bodyRing = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: ringNode))
            ringNode.physicsBody = bodyRing
            ringNode.physicsBody?.categoryBitMask = CollisionCategory.ringCategory.rawValue
            ringNode.physicsBody?.collisionBitMask = CollisionCategory.airplaneCategory.rawValue
            ringNode.physicsBody?.contactTestBitMask = CollisionCategory.airplaneCategory.rawValue

            node.addChildNode(planeNode)
            node.addChildNode(airplaneNode)
            node.addChildNode(ringNode)
          //  movePlane()
            planeDidRender = true
            
        } else{
            return
        }
    }
    
    // MARK: - Actions
    @IBAction func moveRightLeft(_ sender: UISlider) {
        
        xPosition = -sender.value * 2.5
    
    }
    
    @IBAction func resetHorizontalDirection(_ sender: UISlider) {
        
        sender.value = 0
        xPosition = 0
    }
    
    
    @IBAction func moveUpDown(_ sender: UISlider) {
        
        yPosition = -sender.value * 2
        timerVerticalMovements.invalidate()
    }
    
    
    @IBAction func resetMoveUpDown(_ sender: UISlider) {
        
       sender.value = 0
        
       timerVerticalMovements = Timer.scheduledTimer(withTimeInterval: 1/24, repeats: true) { (timer) in
            if self.airplaneNode.eulerAngles.x > 0 {
                self.airplaneNode.eulerAngles.x -= Float.pi/180 * 1 * self.zPosition
            }else {
                self.airplaneNode.eulerAngles.x += Float.pi/180 * 1 * self.zPosition
            }
            if abs(self.airplaneNode.eulerAngles.x) < Float.pi/180 * 1 {
               self.airplaneNode.eulerAngles.x = 0
               timer.invalidate()
            }
        }
        
        yPosition = sender.value
      
    }
    
    @IBAction func speedControl(_ sender: UISlider) {
        zPosition = sender.value
    }
    
    @IBAction func startEngine(_ sender: UIButton) {
        Timer.scheduledTimer(withTimeInterval: 1/24, repeats: true) { (timer) in
            self.airplaneNode.localTranslate(by: SCNVector3(0,0,0.01 * self.zPosition))
            self.airplaneNode.eulerAngles.y += Float.pi/180 * self.xPosition
            self.airplaneNode.eulerAngles.x += Float.pi/180 * self.yPosition
        }
    }
    
    // MARK: - Display Sum
    func obtainAddends(){
        
        let sum: Level = randomSum(0)
        sumLabel.text = "\(sum.minNum) + \(sum.maxNum)"
        addRingsNodes()
        addNumbersNodes(goal: sum.goal)
        
    }
    
    struct CollisionCategory: OptionSet {
        let rawValue: Int
        static let airplaneCategory  = CollisionCategory(rawValue: 1 << 0)
        static let ringCategory = CollisionCategory(rawValue: 1 << 1)
    }
    
    func addRingsNodes(){
        var angle:Float = 0.0
        let radius:Float = 4.0
        let angleIncrement:Float = Float.pi * 2.0 / 4.0
        
        for index in 0..<4 {
            let node = SCNNode()
            
            let torus = SCNTorus(ringRadius: 0.4, pipeRadius: 0.05)
            let color = UIColor(hue: 25.0 / 359.0, saturation: 0.8, brightness: 0.7, alpha: 1.0)
            torus.firstMaterial?.diffuse.contents = color
            
            let x = radius * cos(angle)
            let z = radius * sin(angle)
            
            node.position = SCNVector3(x: x, y: 0.5, z: z)
            node.eulerAngles.x = Float.pi/2
            angle += angleIncrement
            
            node.name = "ring\(index)"
            node.geometry = torus
            
            let body = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: node))
            node.physicsBody = body
            node.physicsBody?.categoryBitMask = CollisionCategory.ringCategory.rawValue
            node.physicsBody?.contactTestBitMask = CollisionCategory.airplaneCategory.rawValue
            node.physicsBody?.collisionBitMask = CollisionCategory.airplaneCategory.rawValue
            
            sceneView.scene.rootNode.addChildNode(node)
            
        }
    }
    
    func addNumbersNodes(goal: Int){
        var angle:Float = 0.0
        let radius:Float = 4.0
        let angleIncrement:Float = Float.pi * 2.0 / 4.0
        let grades: [Float] = [-Float.pi/2.0, -Float.pi, Float.pi/2, 0.0]
        let randomChoice = GKRandomDistribution(lowestValue: 0, highestValue: 3)
        let randomNode: Int = randomChoice.nextInt()
        
        for index in 0..<4 {
            let nodeText = SCNNode()
            var text = SCNText()
            if randomNode == index {
                text = SCNText(string: String(goal), extrusionDepth: 0.1)
            } else {
                let randomChoiceGoal = GKRandomDistribution(lowestValue: 1, highestValue: 10)
                let randomGoal: Int = randomChoiceGoal.nextInt()
                text = SCNText(string: String(randomGoal), extrusionDepth: 0.1)
            }
            
            text.font = UIFont.systemFont(ofSize: 0.5)
            text.flatness = 0.01
            text.firstMaterial?.diffuse.contents = UIColor.white
            
            let x = radius * cos(angle)
            let z = radius * sin(angle)
            
            nodeText.position = SCNVector3(x: x, y: 0, z: z)
            nodeText.eulerAngles.y = grades[index]
            angle += angleIncrement
            
            nodeText.geometry = text
            
            sceneView.scene.rootNode.addChildNode(nodeText)
        }
    }
}


extension ViewController: SCNPhysicsContactDelegate{
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("** Collision!! " + contact.nodeA.name! + " hit " + contact.nodeB.name!)

    }
    
}
