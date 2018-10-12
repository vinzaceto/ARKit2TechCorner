//
//  ViewController.swift
//  ARKit2TechCornerDemo
//
//  Created by Antonio Ruffolo on 06/10/2018.
//  Copyright © 2018 Antonio Ruffolo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARObjectTrackingViewController: UIViewController, ARSCNViewDelegate
{
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var ObjectIdentity: UILabel!
  
  let fightClubVideoPlayer: AVPlayer = {
    //load Prague video from bundle
    guard let url = Bundle.main.url(forResource: "fight club video", withExtension: "mov", subdirectory: "art.scnassets") else {
      print("Could not find video file")
      return AVPlayer()
    }
    
    return AVPlayer(url: url)
  }()
  
  override func viewDidLoad()
  {
    super.viewDidLoad()

    // Set the view's delegate
    sceneView.delegate = self

    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
    
    sceneView.scene.lightingEnvironment.intensity = 4

    // Create a new scene
    //let scene = SCNScene(named: "art.scnassets/ship.scn")!

    // Set the scene to the view
    //sceneView.scene = scene
  }

  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)

    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()

    guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "AR Resources Objects", bundle: nil) else {
      fatalError("Missing expected asset catalog resources.")
    }
    configuration.detectionObjects = referenceObjects

    // Run the view's session
    sceneView.session.run(configuration)
  }

  override func viewWillDisappear(_ animated: Bool)
  {
    super.viewWillDisappear(animated)

    // Pause the view's session
    sceneView.session.pause()
  }

  // MARK: - ARSCNViewDelegate


  // Override to create and configure nodes for anchors added to the view's session.
  func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode?
  {
    let node = SCNNode()
    if let objAnchor = anchor as? ARObjectAnchor
    {
      if objAnchor.referenceObject.name == "StarkMoleskine"
      {
        // Create a plane
        let plane = SCNPlane(width: 0.2,
                             height: 0.5)
        
        plane.firstMaterial?.diffuse.contents = self.fightClubVideoPlayer
        fightClubVideoPlayer.play()
        fightClubVideoPlayer.volume = 0.4
        
        let planeNode = SCNNode(geometry: plane)
        
        // Rotate the plane to match the anchor
        //planeNode.eulerAngles.x = -.pi / 2
        
        planeNode.position = SCNVector3(planeNode.position.x, planeNode.position.y + 0.3, planeNode.position.z )
        
        // Add plane node to parent
        node.addChildNode(planeNode)
      }
      else if objAnchor.referenceObject.name == "M_scan"
      {
        let lettersScene = SCNScene(named: "art.scnassets/TextDemo.scn")!
        let textNode = lettersScene.rootNode.childNode(withName: "example_text", recursively: true)!
        node.addChildNode(textNode)
      }
      
      print("Anchor name is \(objAnchor.referenceObject.name ?? "not available")")  
      DispatchQueue.main.async {
        self.ObjectIdentity.text = objAnchor.referenceObject.name
      }
      
    }

    return node
  }

  func session(_ session: ARSession, didFailWithError error: Error)
  {
    // Present an error message to the user
  }

  func sessionWasInterrupted(_ session: ARSession)
  {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
  }

  func sessionInterruptionEnded(_ session: ARSession)
  {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
  }

  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
  {
    if let objectAnchor = anchor as? ARObjectAnchor
    {
      //node.addChildNode(self.model)
      print("Object detected! \(objectAnchor.description)")
    }
  }
}
