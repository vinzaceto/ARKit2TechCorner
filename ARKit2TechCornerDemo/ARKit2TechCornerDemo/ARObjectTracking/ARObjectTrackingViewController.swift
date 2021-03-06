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

    // Create a new scene
    //let scene = SCNScene(named: "art.scnassets/ship.scn")!

    // Set the scene to the view
    //sceneView.scene = scene
    
    configureLightning()
  }
  
  func configureLightning()
  {
    sceneView.autoenablesDefaultLighting = true
    sceneView.automaticallyUpdatesLighting = true
  }

  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)

    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()

    guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "AR Resources Objects", bundle: nil) else {
      fatalError("Missing expected asset catalog resources.")
    }
    configuration.isLightEstimationEnabled = true;
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
    let letterOffset: Float = 0.1
    let hideOffset: Float = 4.0
    let absoluteOffset: Float = -0.6
    let absoluteZOffset: Float = -1.5
    if let objAnchor = anchor as? ARObjectAnchor
    {
      if objAnchor.referenceObject.name == "M_scan" || objAnchor.referenceObject.name == "StarkMoleskine"
      {
        let lettersScene = SCNScene(named: "art.scnassets/TextDemo.scn")!

        let m_text_node = lettersScene.rootNode.childNode(withName: "m_root_node", recursively: true)!
        node.addChildNode(m_text_node)
        m_text_node.position = SCNVector3(m_text_node.position.x - hideOffset + absoluteOffset, m_text_node.position.y, m_text_node.position.z + absoluteZOffset)
        //addTranslateAnimation(node: m_text_node, distanceX: -CGFloat(hideOffset), distanceY: 0.0, distanceZ: 0.0, delay: 0.0) this
        addTranslateAnimation(node: m_text_node, distanceX: CGFloat(hideOffset), distanceY: 0.0, distanceZ: 0.0, delay: 0.0)

        let and_text_node = lettersScene.rootNode.childNode(withName: "and_root_node", recursively: true)!
        let m_width = getNodeWidth(m_text_node) ?? 0.0
        let and_width = getNodeWidth(and_text_node) ?? 0.0
        node.addChildNode(and_text_node)

        and_text_node.position = SCNVector3(and_text_node.position.x + letterOffset + m_width + absoluteOffset, and_text_node.position.y, and_text_node.position.z + hideOffset + absoluteZOffset)
        //addTranslateAnimation(node: and_text_node, distanceX: -CGFloat(hideOffset), distanceY: 0.0, distanceZ: 0.0, delay: 5.0)
        addTranslateAnimation(node: and_text_node, distanceX: 0.0, distanceY: 0.0, distanceZ: -CGFloat(hideOffset), delay: 4.0)

        let c_text_node = lettersScene.rootNode.childNode(withName: "c_root_node", recursively: true)!
        let c_width = getNodeWidth(c_text_node) ?? 0.0
        node.addChildNode(c_text_node)
        c_text_node.position = SCNVector3(c_text_node.position.x + letterOffset * 2 + m_width + c_width + absoluteOffset, c_text_node.position.y + hideOffset, c_text_node.position.z + absoluteZOffset)
        //c_text_node.rotation = SCNVector4(1.0, 0.0, 0.0, Float.pi)
        //addTranslateAnimation(node: c_text_node, distanceX: -CGFloat(hideOffset), distanceY: 0.0, distanceZ: 0.0, delay: 8)
        addTranslateAnimation(node: c_text_node, distanceX: 0.0, distanceY: -CGFloat(hideOffset), distanceZ: 0.0, delay: 6)
        //addTranslateAndRotateAnimation(node: c_text_node, distanceX: 0.0, distanceY: -CGFloat(hideOffset), distanceZ: 0.0, rotation: -CGFloat(Float.pi), delay: 8)

        let t_text_node = lettersScene.rootNode.childNode(withName: "t_root_node", recursively: true)!
        node.addChildNode(t_text_node)
        t_text_node.position = SCNVector3(t_text_node.position.x + letterOffset * 3 + hideOffset + m_width + c_width + and_width + absoluteOffset, t_text_node.position.y, t_text_node.position.z + absoluteZOffset)
        addTranslateAnimation(node: t_text_node, distanceX: -CGFloat(hideOffset), distanceY: 0.0, distanceZ: 0.0, delay: 5)
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

  private func insertFightClubVideo(node: SCNNode)
  {
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

  func addTiltAndRotateAnimation(node: SCNNode)
  {
    let rotateOne = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi), z: 0, duration: 5.0)
    let hoverUp = SCNAction.moveBy(x: 0, y: 0.2, z: 0, duration: 2.5)
    let hoverDown = SCNAction.moveBy(x: 0, y: -0.2, z: 0, duration: 2.5)
    let hoverSequence = SCNAction.sequence([hoverUp, hoverDown])
    let rotateAndHover = SCNAction.group([rotateOne, hoverSequence])
    let repeatForever = SCNAction.repeatForever(rotateAndHover)
    node.runAction(repeatForever)
  }

  func addTranslateAnimation(node: SCNNode, distanceX: CGFloat, distanceY: CGFloat, distanceZ: CGFloat, delay: TimeInterval)
  {
    let moveLeft = SCNAction.moveBy(x: distanceX, y: distanceY, z: distanceZ, duration: 3)
    let delayAction = SCNAction.wait(duration: delay)
    let sequence = SCNAction.sequence([delayAction, moveLeft])
    node.runAction(sequence)
  }

  func addTranslateAndRotateAnimation(node: SCNNode, distanceX: CGFloat, distanceY: CGFloat, distanceZ: CGFloat, rotation: CGFloat, delay: TimeInterval)
  {
    let moveLeft = SCNAction.moveBy(x: distanceX, y: distanceY, z: distanceZ, duration: 8)
    let rotate = SCNAction.rotateBy(x: rotation, y: 0.0, z: 0.0, duration: 1)
    let delayAction = SCNAction.wait(duration: delay)
    let sequence = SCNAction.sequence([delayAction, moveLeft, rotate])
    node.runAction(sequence)
  }

  private func getNodeWidth(_ node: SCNNode) -> Float?
  {
    let min = node.boundingBox.min
    let max = node.boundingBox.max
    let w = CGFloat(max.x - min.x)
    //let h = CGFloat(max.y - min.y)
    //let l =  CGFloat( max.z - min.z)
    return Float(w)
  }
}
