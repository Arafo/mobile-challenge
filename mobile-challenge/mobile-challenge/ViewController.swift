//
//  ViewController.swift
//  mobile-challenge
//
//  Created by MARCEN, RAFAEL [External] on 10/6/17.
//  Copyright © 2017 MARCEN, RAFAEL. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var indicatorImage: UIImageView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var debugLabel: UILabel!
    
    let debug = true
    
    var request: VNCoreMLRequest!
    var latestPrediction : Product = Product()
    
    var fps = 30
    var lastTime : TimeInterval?
    var accumTime : TimeInterval?
    var nodes : [(SCNNode, Product)] = []
    let buyButtonMaxTimeout : Double = 3.0
    let buyButtonStepTimeout : Double = 0.04
    var buyButtonTimeout : Double = 3.0

    let queue = DispatchQueue(label: "com.adidas.camera-queue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupVision()
        
        buyButton.isHidden = true
    }
    
    func setupScene() {
        // Set the view's delegate
        self.sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        if debug {
            self.sceneView.showsStatistics = true
        }
        
        self.sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: adidasCNN().model) else {
            print("Error: could not create Vision model")
            return
        }
        
        request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
        request.imageCropAndScaleOption = .centerCrop
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func setupSession() {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @IBAction func handleTap(_ sender: UIButton) {
        let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        
        let arHitTestResults : [ARHitTestResult] = sceneView.hitTest(screenCentre, types: [.featurePoint])
        
        if let closestResult = arHitTestResults.first {
            
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            // Text
            let node = TextNode(text: latestPrediction.name)
            sceneView.scene.rootNode.addChildNode(node)
            node.position = worldCoord
            nodes.append((node, latestPrediction))
        }
    }
    
    @IBAction func buyButtonTap(_ sender: UIButton) {
        let model = latestPrediction.id
        if model != "", let url = URL(string: "https://www.adidas.es/" + model + ".html") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
}

// MARK: - Inference
extension ViewController {
    
    typealias Prediction = (String, Double)
    
    func predict(image: UIImage) {
        if let pixelBuffer = image.pixelBuffer(width: 416, height: 416) {
            predict(pixelBuffer: pixelBuffer)
        }
    }
    
    func predict(pixelBuffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        
        if let observations = request.results as? [VNClassificationObservation] {
            //print(observations.count)
            guard let observation = observations.first else {
                return
            }
            
            if observation.confidence >= 0.9 {

                let prediction = [(Prediction) (observation.identifier, Double(observation.confidence)),
                                  (Prediction) (observations[1].identifier, Double(observations[1].confidence)),
                                  (Prediction) (observations[2].identifier, Double(observations[2].confidence)),
                                  (Prediction) (observations[3].identifier, Double(observations[3].confidence))]
                latestPrediction = Product(string: observation.identifier)
                
                DispatchQueue.main.async {
                    self.captureButton.isEnabled = true
                    self.indicatorImage.tintColor = UIColor.green
                    if self.debug {
                        self.debugLabel.text = ""
                    }
                    self.show(results: prediction)
                }
            } else {
                print("Low confidence")
                DispatchQueue.main.async {
                    self.captureButton.isEnabled = false
                    self.indicatorImage.tintColor = UIColor.red
                    if self.debug {
                        self.debugLabel.text = "Low confidence: \(observation.confidence)"
                    }
                }
            }
        }
    }
    
    func show(results: [Prediction]) {
        var s: [String] = []
        for (i, pred) in results.enumerated() {
            s.append(String(format: "%d: %@ (%3.2f%%)", i + 1, pred.0, pred.1 * 100))
        }
        print(s)
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController : ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
            
            let hitTestResults : [ARHitTestResult] = self.sceneView.hitTest(screenCentre, types: [.featurePoint])
            
            if let closestResult = hitTestResults.first {
                
                let transform : matrix_float4x4 = closestResult.worldTransform
                let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                
                for (node, prediction) in self.nodes {
                    
                    // Bounding box coordinates from local to world space
                    let min = node.convertPosition(node.boundingBox.min, to: node.parent)
                    let max = node.convertPosition(node.boundingBox.max, to: node.parent)
                    
                    if isInside(box: (min: min, max: max), point: worldCoord) {
                        //print("Buy...")
                        self.buyButton.isHidden = false
                        self.buyButtonTimeout = self.buyButtonMaxTimeout
                        self.latestPrediction = prediction
                    } else {
                        self.buyButtonTimeout = self.buyButtonTimeout - self.buyButtonStepTimeout
                        self.buyButton.isHidden = self.buyButtonTimeout <= 0.0
                    }
                }
                
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        var delta: TimeInterval?
        if let luti = self.lastTime {
            delta = time - luti
        } else {
            delta = time
        }
        
        if delta! > Double(self.fps) / 60 {
            self.lastTime = time

            var currentScreen : UIImage? = nil
            DispatchQueue.main.async {
                currentScreen = self.sceneView.snapshot()
                
                self.queue.async {
                    if let screen = currentScreen {
                        self.predict(image: screen)
                    }
                }
            }
        }
    }
}
