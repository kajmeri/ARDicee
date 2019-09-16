//
//  ViewController.swift
//  ARDicee
//
//  Created by Krishna Ajmeri on 9/16/19.
//  Copyright © 2019 Krishna Ajmeri. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
	
	//MARK: - Variable Declaration
	
	@IBOutlet var sceneView: ARSCNView!
	var diceArray = [SCNNode]()
	
	//MARK: - View Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		sceneView.delegate = self
		sceneView.autoenablesDefaultLighting = true
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
	
	//MARK: - Touch/Motion Methods
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let touchLocation = touch.location(in: sceneView)
			
			let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
			
			if let hitResult = results.first {
				addDice(atLocation: hitResult)
			}
		}
	}
	
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		rollAll()
	}
	
	//MARK: - Dice Rendering Methods
	
	func addDice(atLocation location: ARHitTestResult) {
		
		let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
		
		if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
			
			diceNode.position = SCNVector3(
				x: location.worldTransform.columns.3.x,
				y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
				z: location.worldTransform.columns.3.z
			)
			
			diceArray.append(diceNode)
			
			sceneView.scene.rootNode.addChildNode(diceNode)
			
			roll(dice: diceNode)
		}
	}
	
	func roll(dice: SCNNode) {
		let randomX = CGFloat(arc4random_uniform(4) + 1) * (CGFloat.pi/2)
		let randomZ = CGFloat(arc4random_uniform(4) + 1) * (CGFloat.pi/2)
		
		dice.runAction(SCNAction.rotateBy(x: randomX * 5, y: 0, z: randomZ * 5, duration: 0.5))
	}
	
	func rollAll() {
		if !diceArray.isEmpty {
			for dice in diceArray {
				roll(dice: dice)
			}
		}
	}
	
	@IBAction func rollAllAgain(_ sender: UIBarButtonItem) {
		rollAll()
	}
	
	@IBAction func removeAllDice(_ sender: UIBarButtonItem) {
		if !diceArray.isEmpty {
			for dice in diceArray {
				dice.removeFromParentNode()
			}
		}
	}
	
	//MARK: - ARSCNViewDelegate Methods
	
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		
		guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
		
		let planeNode = createPlane(withPlaneAnchor: planeAnchor)
		
		node.addChildNode(planeNode)
	}
	
	//MARK: - Plane Rendering Methods
	
	func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
		let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
		let planeNode = SCNNode()
		let gridMaterial = SCNMaterial()
		
		planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
		planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
		
		gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
		
		plane.materials = [gridMaterial]
		
		planeNode.geometry = plane
		
		return planeNode
	}
}
