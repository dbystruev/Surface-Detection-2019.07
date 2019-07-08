//
//  ViewController.swift
//  Surface Detection
//
//  Created by Denis Bystruev on 08/07/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import ARKit

class ViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: - UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Custom Methods
    func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        
        let extent = planeAnchor.extent
        let width = CGFloat(extent.x)
        let height = CGFloat(extent.z)
        
        let geometry = SCNPlane(width: width, height: height)
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry = geometry
        
        node.eulerAngles.x = -.pi / 2
        node.opacity = 0.25
        
        return node
    }
    
    func createShip(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.clone()
        let center = planeAnchor.center
        node.position = SCNVector3(center.x, 0, center.z)
        node.scale = SCNVector3(0.1, 0.1, 0.1)
        return node
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let floor = createFloor(planeAnchor: planeAnchor)
        node.addChildNode(floor)
        
        let ship = createShip(planeAnchor: planeAnchor)
        node.addChildNode(ship)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        for childNode in node.childNodes {
            let center = planeAnchor.center
            childNode.position = SCNVector3(center.x, 0, center.z)
        }
        
        guard let floor = node.childNodes.first else { return }
        guard let plane = floor.geometry as? SCNPlane else { return }
        
        let extent = planeAnchor.extent
        plane.width = CGFloat(extent.x)
        plane.height = CGFloat(extent.z)
    }
}
