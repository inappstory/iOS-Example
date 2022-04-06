//
//  FramedStoryCell.swift
//  InAppStoryExample
//
//  Created by StPashik on 08.02.2022.
//

import UIKit
import AVFoundation
import InAppStorySDK

class FramedStoryCell: UICollectionViewCell
{
    static var reuseIdentifier: String {
        return String(describing: self)
    }

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    var storyID: String!
    
    fileprivate let player = AVPlayer()
    fileprivate var playerLayer: AVPlayerLayer!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var framerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var soundIcon: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        titleLabel.text = ""
        videoView.isHidden = true
        
        player.replaceCurrentItem(with: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        framerView.layer.cornerRadius = 16.0
        containerView.layer.cornerRadius = 12.0
        
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        titleLabel.textColor = .white
        titleLabel.isHidden = false
        
        if playerLayer == nil {
            player.isMuted = true
            
            if #available(iOS 12.0, *) {
                player.preventsDisplaySleepDuringVideoPlayback = false
            }
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = videoView.frame
            playerLayer.videoGravity = .resizeAspectFill
            videoView.layer.addSublayer(playerLayer)
        }
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        if playerLayer != nil {
            playerLayer.frame = videoView.frame
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension FramedStoryCell: StoryCellProtocol
{
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    func setImageURL(_ url: URL) {
        imageView.image = nil
        imageView.tag = Int(String("\(Int(Date().timeIntervalSince1970 * 1000000))".dropFirst(8)))!

        imageView.downloadedFrom(url: url, contentMode: .scaleAspectFill, withViewTag: imageView.tag)
    }
    
    func setVideoURL(_ url: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            guard let weakSelf = self, !weakSelf.videoView.isHidden else {
                return
            }
            
            weakSelf.player.seek(to: CMTime.zero)
            weakSelf.player.play()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterForeground(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        player.play()
        
        videoView.isHidden = false
    }
    
    func setOpened(_ value: Bool) {
        framerView.layer.borderWidth = value ? 0 : 2
        framerView.layer.borderColor = value ? UIColor.clear.cgColor : UIColor.purple.cgColor
    }
    
    func setHighlight(_ value: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.containerView.applyTransform(withScale: value ? 0.95 : 1.0, anchorPoint: CGPoint(x: 0.5, y: 0.5))
        }
    }
    
    func setBackgroundColor(_ color: UIColor) {
        imageView.backgroundColor = color
    }
    
    func setTitleColor(_ color: UIColor) {
        titleLabel.textColor = color
    }
    
    func setSound(_ value: Bool) {
        soundIcon.isHidden = !value
    }
}

extension FramedStoryCell
{
    @objc func enterForeground(_ notification: NSNotification)
    {
        if player.currentItem != nil {
            player.seek(to: CMTime.zero)
            player.play()
        }
    }
}
