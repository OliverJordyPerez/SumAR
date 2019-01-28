//
//  ARSCNDelegate.swift
//  SumAR
//
//  Created by OliverPérez on 1/20/19.
//  Copyright © 2019 OliverPérez. All rights reserved.
//
import UIKit
import SceneKit
import ARKit
import GameplayKit

//MARK: - ARSCNViewDelegate Methods

extension ViewController: ARSCNViewDelegate{
    
    func initScene() {
        
        sceneView.delegate = self
        
        let mainScene = SCNScene(named: "art.scnassets/scene.scn")!
        sceneView.scene = mainScene
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene.physicsWorld.contactDelegate = self
        
        if let node = mainScene.rootNode.childNode(withName: "ship", recursively: true){
            airplane.node = node
            airplane.node.isHidden = true
        }
        
        numberGenerator()
        obtainAddends()
    }
    
}

