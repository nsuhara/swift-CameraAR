//
//  ViewController.swift
//  swift-CameraAR
//
//  Created by nsuhara on 2018/11/26.
//  Copyright © 2018 nsuhara. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            addChildNode(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.delegate = self
        self.sceneView.showsStatistics = true
        self.sceneView.scene = SCNScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        self.sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
    }
    
    private func rotateImage(image: UIImage, angle: Float) -> UIImage {
        let result: UIImage?
        
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: image.size.width, height: image.size.height), false, 0.0)

        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.translateBy(x: image.size.width / 2, y: image.size.height / 2)
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: CGFloat(angle) * CGFloat(Double.pi) / 180.0)
        context.draw(image.cgImage!, in: CGRect.init(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        
        result = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return result!
    }
    
    private func addChildNode(image: UIImage) {
        guard let currentFrame = self.sceneView.session.currentFrame else { return }
        
        let sceneNode = SCNNode()
        let scale: CGFloat = 1 / 10
        let sceneBox = SCNBox(
            width: image.size.width * scale / image.size.height,
            height: scale,
            length: 1 / 100000000,
            chamferRadius: 0.0)
        sceneBox.firstMaterial?.diffuse.contents = image
        sceneNode.geometry = sceneBox
        
        var simdFloat4x4 = matrix_identity_float4x4
        simdFloat4x4.columns.3.z = -0.1
        sceneNode.simdTransform = matrix_multiply(currentFrame.camera.transform, simdFloat4x4)
        
        self.sceneView.scene.rootNode.addChildNode(sceneNode)
    }
    
    @IBAction func onTapCamera(_ sender: Any) {
        addChildNode(image: rotateImage(image: self.sceneView.snapshot(), angle: 90.0))
    }
    
    @IBAction func onTapPhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.modalPresentationStyle = .overFullScreen
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func onTapClear(_ sender: Any) {
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }
    
}
