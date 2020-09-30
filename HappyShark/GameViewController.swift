//
//  GameViewController.swift
//  HappyShark
//
//  Created by Anatolii Kasianov on 24.09.2020.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ability to play sounds
        sendAudioToBackground()
        
        if let view = self.view as! SKView? {
            
            let scene = GameScene(size: CGSize(width: 1920, height: 1080))

            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .allButUpsideDown
//        } else {
//            return .all
//        }
    }
    
//    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
//        return .landscapeLeft
//    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func sendAudioToBackground() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
