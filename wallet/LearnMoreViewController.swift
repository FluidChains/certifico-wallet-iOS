//
//  LearnMoreViewController.swift
//  certificates
//
//  Created by Sergio Quintero on 12/10/20.
//  Copyright © 2020 Fluid Chains Inc. All rights reserved.
//

import UIKit
import AVKit
import SafariServices


class LearnMoreViewController: UIViewController {


    @IBOutlet weak var btnChertero: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizations.LearnMore

        
        let animation = LOTAnimationView(name: "welcome_lottie.json")
        animation.loopAnimation = true
        animation.contentMode = .scaleAspectFill
        animation.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(animation, at: 0)
        animation.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        animation.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        animation.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        animation.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        animation.play()
    }
    @IBAction func openChertero(_ sender: Any) {
        let certURL = SFSafariViewController(url: URL(string: "https://chertero.com")!)
        present(certURL, animated: true)
    }
    
    @IBAction func playWelcomeVideo() {
        guard let path = Bundle.main.path(forResource: Localizations.VideoIntroduction, ofType:"mp4") else {
            print(Localizations.VideoIntroduction)
            print("Video file not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        playerController.showsPlaybackControls = true
        if #available(iOS 11.0, *) {
            playerController.exitsFullScreenWhenPlaybackEnds = true
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(didEndPlaying),
                                                   name: .AVPlayerItemDidPlayToEndTime,
                                                   object: nil)
        }
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    @objc func didEndPlaying(_ notification: Notification) {
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
