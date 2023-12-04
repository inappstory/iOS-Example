//
//  SimpleIntegrationController.swift
//  InAppStoryExample
//

import UIKit
import AVFoundation
import InAppStorySDK

/// An example implementation of a simple cell with a full cell area cover.
///
/// It is necessary that the cell class inherits from `UICollectionViewCell` and implements the `StoryCellProtocol` protocol
///
/// The example shows how to create a cell with an *.xib* file. In order to use programmatic cell layout it is necessary to return the value `nil` in the variable ``nib``
/// ```
/// static var nib: UINib? { return nil }
/// ```
/// 
/// Appearance parameters are configured in the cell itself in the ``awakeFromNib()`` method, such as colors, rounding, and fonts.
/// The `StoryView` list knows nothing about the internal state of the cell and can only affect it by calling `StoryCellProtocol` methods.
/// - Remark: To display the cell contents correctly, remember to clear the fields in the method ``prepareForReuse()``
///
/// # Video cover
/// Due to the peculiarities of the audio playback system, installing video cover may affect the playback
/// of music from a player application running in the background, even if there is no sound in the video.
/// In order to keep the sound from background playback, it is necessary to set a certain category for `AVAudioSession`,
/// but it is difficult to do it in `AVPlayer`. If your application does not contain video playback functions or sounds
/// that should mute background music playback, you can use the example and set the category for `AVAudioSession` as `.ambient`.
/// This way, background music will not be muted if the covers contain videos.
/// ```
/// do {
///     try AVAudioSession.sharedInstance().setCategory(.ambient)
///     try AVAudioSession.sharedInstance().setActive(true)
/// } catch let error as NSError {
///     print(error)
/// }
/// ```
/// If an application contains video or music that should override background playback, you can set a different category before playing it to `AVAudioSession`
class CustomStoryCell: UICollectionViewCell {
    /// reuse identifier for registering a cell in `UICollectionView`
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    /// nib of cell, if cell created in .xib file
    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    /// transferred from the list
    var storyID: String!
    
    /// player for video cover
    fileprivate let player = AVPlayer()
    fileprivate var playerLayer: AVPlayerLayer!
    
    /// image cover
    @IBOutlet weak var imageView: UIImageView!
    /// video cover
    @IBOutlet weak var videoView: UIView!
    /// title
    @IBOutlet weak var titleLabel: UILabel!
    /// container for cell contents
    @IBOutlet weak var containerView: UIView!
    
    /// Called by the collection view before the instance is returned from the reuse queue.
    override func prepareForReuse() {
        super.prepareForReuse()
        
        /// Cleaning the cell before use
        /// If you do not clear the image or video, when you reuse the cell,
        /// the image that was loaded the first time and the content will be duplicated.
        imageView.image = nil
        titleLabel.text = ""
        videoView.isHidden = true
        
        player.replaceCurrentItem(with: nil)
    }
    
    /// Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /// set start cell style
        /// cell edge rounding setting
        containerView.layer.cornerRadius = 16
        /// setting the font and color of the cell header
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        titleLabel.textColor = .black
        
        /// customizing the player for the video cover
        if playerLayer == nil {
            /// player mute
            player.isMuted = true
            
            if #available(iOS 12.0, *) {
                /// fixes "autolock" blocking due to video loop
                player.preventsDisplaySleepDuringVideoPlayback = false
            }
            
            /// playback layer creation
            playerLayer = AVPlayerLayer(player: player)
            /// video render size setting
            playerLayer.frame = videoView.frame
            /// video rendering ratio setting
            playerLayer.videoGravity = .resizeAspectFill
            /// adding a video layer to the view for display
            videoView.layer.addSublayer(playerLayer)
        }
    }
    
    /// Tells the delegate a layer's bounds have changed.
    ///
    /// Due to the fact that at the time of creating a cell, its dimensions may not be quite right
    /// and may not take into account the parameters set when creating the `StoryView`,
    /// it is necessary to update the dimensions of the video layer to display correctly.
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        /// update vidoe frame for cover
        if playerLayer != nil {
            playerLayer.frame = videoView.frame
        }
    }
    
    /// When deinitializing a cell, you must delete the observers so that ARC can clear the memory
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

/// Implementation of `StoryCellProtocol` methods
extension CustomStoryCell: StoryCellProtocol {
    
    /// Title of cell
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    /// Image url for cover
    func setImageURL(_ url: URL) {
        /// additional cleaning of `UIImageView` from the old image
        imageView.image = nil
        /// setting a tag for `UIImageView`, for proper asynchronous loading of images from the network
        imageView.tag = Int(String("\(Int(Date().timeIntervalSince1970 * 1000000))".dropFirst(8)))!
        /// downloading an image from the network using the `UIImageView` extension
        /// more details can be seen in ``UIKit/UIImageView/downloadedFrom(url:contentMode:withViewTag:)``
        imageView.downloadedFrom(url: url, contentMode: .scaleAspectFill, withViewTag: imageView.tag)
    }
    
    /// Video url for animated cover
    /// In this method the link to the cached file inside the SDK is passed, you do not need to download anything additionally
    func setVideoURL(_ url: URL) {
        /// replacing the playing video in the player
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        
        /// Vdeo looping
        /// To loop the video, it is necessary to set the observer to end its playback and
        /// start the video again when the condition is met.
        /// To make video playback smoother when restarting,
        /// the `preventsDisplaySleepDuringVideoPlayback` parameter for 
        /// the player is added to ``awakeFromNib()``
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            guard let weakSelf = self, !weakSelf.videoView.isHidden else {
                return
            }
            /// at the end of playback go to the beginning of the video
            weakSelf.player.seek(to: CMTime.zero)
            /// start plaing
            weakSelf.player.play()
        }
        
        /// If the application goes into the background, the video playback will stop and will not start again when you return to the foreground,
        /// to do this you need to subscribe to the event of leaving the background and restart the playback
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterForeground(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        /// start video playback
        player.play()
        /// show the cover video in the cell
        videoView.isHidden = false
    }
    
    /// Set new state if story is opened
    func setOpened(_ value: Bool) {
        /// If the story has already been read by the user, in this case we change the display
        /// to make it clear that the story has already been opened.
        containerView.alpha = value ? 0.7 : 1.0
    }
    
    /// Set new state if story cell if highlighted
    func setHighlight(_ value: Bool) {
        /// If the user pressed his finger on a cell but did not release it, we highlight it for better UX
        UIView.animate(withDuration: 0.2) {
            self.containerView.alpha = value ? 0.7 : 1.0
        }
    }
    
    /// Set background color of cell
    func setBackgroundColor(_ color: UIColor) {
        /// Stories may not have a cover video or photo, or they may not have had time to load.
        /// In this case, in the console you can set the color of the cell that will be displayed as the cover.
        imageView.backgroundColor = color
    }
    
    /// Set title color of cell
    func setTitleColor(_ color: UIColor) {
        /// In the console, you can also set the color of the header to contrast with the cover.
        /// For example, all covers are dark and have a white header,
        /// but there are some very light ones, for them you can set a dark header color.
        titleLabel.textColor = color
    }
    
    /// does the story have sound
    func setSound(_ value: Bool) {
        /// A video with sound can be set inside a story.
        /// For such stories there is a flag that there is sound.
        /// Using this method you can mark that a story contains a sound file.
    }
}

extension CustomStoryCell {
    /// Processing of application exit event and background mode
    @objc func enterForeground(_ notification: NSNotification) {
        /// If the player is created, it is restarted
        if player.currentItem != nil {
            player.seek(to: CMTime.zero)
            player.play()
        }
    }
}
