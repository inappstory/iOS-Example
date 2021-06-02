//
//  SimpleIntegrationController.swift
//  InAppStoryExample
//

import UIKit
import AVFoundation
import InAppStorySDK

class CustomStoryCell: UICollectionViewCell
{
    // reuseIdentifier of cell
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    // nib of cell, if cell created in .xib file
    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    // player for video cover
    fileprivate let player = AVPlayer()
    fileprivate var playerLayer: AVPlayerLayer!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sourceHeight: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        titleLabel.text = ""
        videoView.isHidden = true
    }
    
    // set start cell style
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 16
        
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        titleLabel.textColor = .black
        
        if playerLayer == nil {
            player.isMuted = true
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = videoView.frame
            playerLayer.videoGravity = .resizeAspectFill
            videoView.layer.addSublayer(playerLayer)
        }
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        // update vidoe frame for cover
        if playerLayer != nil {
            playerLayer.frame = videoView.frame
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CustomStoryCell: StoryCellProtocol
{
    // title of cell
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    // source title of cell (deprecated soon)
    func setSource(_ text: String) {}
    
    // image url for cover
    func setImageURL(_ url: URL) {
        imageView.image = nil
        imageView.tag = Int(Date().timeIntervalSince1970)
        
        imageView.downloadedFrom(url: url, contentMode: .scaleAspectFill, withViewTag: imageView.tag)
    }
    
    // video url for animated cover
    func setVideoURL(_ url: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        
        // loop video
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            guard let weakSelf = self, !weakSelf.videoView.isHidden else {
                return
            }
            
            weakSelf.player.seek(to: CMTime.zero)
            weakSelf.player.play()
        }
        
        player.play()
        
        videoView.isHidden = false
    }
    
    // set new state if story is opened
    func setOpened(_ value: Bool) {
        containerView.alpha = value ? 0.7 : 1.0
    }
    
    // set new state if story cell if highlighted
    func setHighlight(_ value: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.containerView.alpha = value ? 0.7 : 1.0
        }
    }
    
    // set background color of cell
    func setBackgroundColor(_ color: UIColor) {
        imageView.backgroundColor = color
    }
    
    // set title color of cell
    func setTitleColor(_ color: UIColor) {
        titleLabel.textColor = color
    }
    
    // does the story have sound
    func setSound(_ value: Bool) {}
}
