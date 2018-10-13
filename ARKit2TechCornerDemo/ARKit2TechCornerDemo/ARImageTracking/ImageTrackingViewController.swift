//
//  ImageTrackingViewController.swift
//  ARKit2TechCornerDemo
//
//  Created by Antonio Ruffolo on 10/10/2018.
//  Copyright © 2018 Antonio Ruffolo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ImageTrackingViewController: UIViewController, ARSCNViewDelegate
{
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var magicSwitch: UISwitch!
  @IBOutlet weak var blurView: UIVisualEffectView!

  // Create video player
  let isaVideoPlayer: AVPlayer = {
    //load Isa video from bundle
    guard let url = Bundle.main.url(forResource: "isa video", withExtension: "mp4", subdirectory: "art.scnassets") else {
      print("Could not find video file")
      return AVPlayer()
    }

    return AVPlayer(url: url)
  }()
  let pragueVideoPlayer: AVPlayer = {
    //load Prague video from bundle
    guard let url = Bundle.main.url(forResource: "prague video", withExtension: "mp4", subdirectory: "art.scnassets") else {
      print("Could not find video file")
      return AVPlayer()
    }

    return AVPlayer(url: url)
  }()
  let fightClubVideoPlayer: AVPlayer = {
    //load Prague video from bundle
    guard let url = Bundle.main.url(forResource: "fight club video", withExtension: "mov", subdirectory: "art.scnassets") else {
      print("Could not find video file")
      return AVPlayer()
    }

    return AVPlayer(url: url)
  }()
  let homerVideoPlayer: AVPlayer = {
    //load Prague video from bundle
    guard let url = Bundle.main.url(forResource: "homer video", withExtension: "mov", subdirectory: "art.scnassets") else {
      print("Could not find video file")
      return AVPlayer()
    }

    return AVPlayer(url: url)
  }()


  /// The view controller that displays the status and "restart experience" UI.
  lazy var statusViewController: StatusViewController = {
    return children.lazy.compactMap({ $0 as? StatusViewController }).first!
  }()

  /// A serial queue for thread safety when modifying the SceneKit node graph.
  let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
    ".serialSceneKitQueue")

  /// Convenience accessor for the session owned by ARSCNView.
  var session: ARSession {
    return sceneView.session
  }

  // MARK: - View Controller Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    sceneView.delegate = self
    sceneView.session.delegate = self
    magicSwitch.setOn(false, animated: false)

    // Hook up status view controller callback(s).
    statusViewController.restartExperienceHandler = { [unowned self] in
      self.restartExperience()
    }
  }

  override func viewDidAppear(_ animated: Bool)
  {
    super.viewDidAppear(animated)

    // Prevent the screen from being dimmed to avoid interuppting the AR experience.
    UIApplication.shared.isIdleTimerDisabled = true

    // Start the AR experience
    resetTracking()
  }

  override func viewWillDisappear(_ animated: Bool)
  {
    super.viewWillDisappear(animated)
    session.pause()
  }

  // MARK: - Session management (Image detection setup)

  /// Prevents restarting the session while a restart is in progress.
  var isRestartAvailable = true

  @IBAction func switchOnMagic(_ sender: Any)
  {
    let configuration = ARImageTrackingConfiguration()

    guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
      print("Could not load images")
      return
    }

    // Setup Configuration
    configuration.trackingImages = trackingImages
    configuration.maximumNumberOfTrackedImages = 4
    session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
  }

  /// Creates a new AR configuration to run on the `session`.
  /// - Tag: ARReferenceImage-Loading
  func resetTracking()
  {
    let configuration = ARImageTrackingConfiguration()
    session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
  }

  // MARK: - Image Tracking Results
  public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    let node = SCNNode()

    if let imageAnchor = anchor as? ARImageAnchor {

      let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
      //addVideoFromReferenceImage(plane: plane, referenceImage: imageAnchor.referenceImage.name)
      DispatchQueue.main.async {
        self.addImageFromReferenceImage(plane: plane, referenceImage: imageAnchor.referenceImage.name)
      }

      let planeNode = SCNNode(geometry: plane)

      // Rotate the plane to match the anchor
      planeNode.eulerAngles.x = -.pi / 2

      //planeNode.position = SCNVector3(planeNode.position.x - 10, planeNode.position.y, planeNode.position.z)

      // Add plane node to parent
      node.addChildNode(planeNode)
    }

    return node
  }

  private func addVideoFromReferenceImage(plane: SCNPlane, referenceImage: String?)
  {
    if referenceImage == "prague image"
    {
      // Set AVPlayer as the plane's texture and play
      plane.firstMaterial?.diffuse.contents = self.pragueVideoPlayer
      self.pragueVideoPlayer.play()
      self.pragueVideoPlayer.volume = 0.4
    } else if referenceImage == "fight club image"
    {
      plane.firstMaterial?.diffuse.contents = self.fightClubVideoPlayer
      self.fightClubVideoPlayer.play()
    } else if referenceImage == "homer image"
    {
      plane.firstMaterial?.diffuse.contents = self.homerVideoPlayer
      self.homerVideoPlayer.play()
    } else
    {
      plane.firstMaterial?.diffuse.contents = self.isaVideoPlayer
      self.isaVideoPlayer.play()
      self.isaVideoPlayer.isMuted = true
    }
  }

  private func addImageFromReferenceImage(plane: SCNPlane, referenceImage: String?)
  {
    if referenceImage == "prague image"
    {
      let img = UIImage(named: "HoSlide")
      let imgView = UIImageView(image: img)
      imgView.contentMode = .scaleAspectFit

      plane.firstMaterial?.diffuse.contents = imgView
    }
    else if referenceImage == "fight club image"
    {
      let img = UIImage(named: "SkySlide")
      let imgView = UIImageView(image: img)
      imgView.contentMode = .center

      plane.firstMaterial?.diffuse.contents = imgView
    }
    else if referenceImage == "homer image"
    {
      let img = UIImage(named: "PirelliSlide")
      let imgView = UIImageView(image: img)
      imgView.contentMode = .scaleAspectFit

      plane.firstMaterial?.diffuse.contents = imgView
    }
    else
    {
      let img = UIImage(named: "EnelXSlide")
      let imgView = UIImageView(image: img)
      imgView.contentMode = .scaleAspectFit

      plane.firstMaterial?.diffuse.contents = imgView
    }
  }
}
