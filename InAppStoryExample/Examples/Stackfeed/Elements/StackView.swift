//
//  StackView.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of UI presentation of Stack feed
class StackView: UIView {
    /// Stack feed data object received from SDK
    fileprivate var stackFeed: StackFeedObject?
    /// Cover story on top of the feed stack.
    fileprivate var feedCover: UIImageView!
    
    /// Сolor showing open stories in the frame
    fileprivate let openColor = UIColor.lightGray
    /// Color showing new stories in the frame
    fileprivate let newColor = UIColor.blue
    /// Stroke width on the frame
    fileprivate let dashWidth: CGFloat = 6
    /// Distance between strokes on the frame in degrees
    fileprivate let dashSpace: CGFloat = 20.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        /// Creating a cover (picture)
        createCover()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// To update the rounding to a circle, update cornerRadius
        if feedCover != nil {
            feedCover.layer.cornerRadius = feedCover.frame.width / 2.0
        }
    }
    
    /// Drawing the frame using data from the Stack feed object
    override func draw(_ rect: CGRect) {
        /// Check if there is data about opening stories in the feed object
        guard let opened = stackFeed?.opened else { return }
        /// Calculate the degrees limiting the frame segment
        let segmentRad = 360.0 / CGFloat(opened.count)
        
        /// Draw the segments on the frame with the help of enumeration
        for (i, open) in opened.enumerated() {
            /// Slightly shift the beginning of the drawing end to get even coverage of the frame and indentations between segments
            let startDegrees: CGFloat = -90 + (segmentRad * CGFloat(i)) + (dashSpace / 2.0)
            let endDegrees: CGFloat = startDegrees + segmentRad - (dashSpace / 2.0)
            
            /// Conversion of segment start and end values to radians
            let startAngle: CGFloat = radians(of: startDegrees)
            let endAngle: CGFloat = radians(of: endDegrees)
            
            /// Set the dimensions of the circle
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let radius = min(center.x, center.y) - dashWidth / 2 - 10
            
            /// Segment drawing
            let trackPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            trackPath.lineWidth = dashWidth
            trackPath.lineCapStyle = .round
            
            if open {
                /// if the story was opened, mark the segment grayed out
                openColor.set()
            } else {
                /// if the story has not been opened, mark the segment blue
                newColor.set()
            }
            
            /// Finish drawing the segment
            trackPath.stroke()
        }
    }
    
    /// Conversion of degrees to radians
    private func radians(of degrees: CGFloat) -> CGFloat {
        return degrees / 180 * .pi
    }
}

extension StackView {
    /// Creating a cover image
    fileprivate func createCover() {
        feedCover = UIImageView()
        /// In order to properly set the layouts, disable translatesAutoresizingMask
        feedCover.translatesAutoresizingMaskIntoConstraints = false
        /// To display a circular image, set the cropping value
        feedCover.clipsToBounds = true
        addSubview(feedCover)
        
        /// configuring the constants to display the list correctly
        var allConstraints: [NSLayoutConstraint] = []
        /// horizontally - from edge to edge
        let horConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[feedCover]-(20)-|",
                                                           options: [.alignAllLeading, .alignAllTrailing],
                                                           metrics: nil,
                                                           views: ["feedCover": feedCover!])
        allConstraints += horConstraint
        /// vertically - height 180pt with a 16pt indent at the top
        let vertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(20)-[feedCover]-(20)-|",
                                                            options: [.alignAllTop, .alignAllBottom],
                                                            metrics: nil,
                                                            views: ["feedCover": feedCover!])
        allConstraints += vertConstraint
        
        /// constraints activation
        NSLayoutConstraint.activate(allConstraints)
    }
}

extension StackView {
    /// Method of updating UI interface by new data
    func updateFeed(newStackFeed: StackFeedObject) {
        /// Update local Stack feed data
        stackFeed = newStackFeed
        /// Method call for redrawing UIView
        setNeedsDisplay()
        
        /// Checking for a cover image
        if feedCover != nil {
            /// Check if there is a background color for the cover
            if let feedColor = newStackFeed.cover?.backgroundColor {
                /// Assign a background color to the image
                feedCover.backgroundColor = feedColor
            }
            
            /// Check if the image address is available to display it in the cover page
            if let feedCoverURL = newStackFeed.cover?.feedCover ?? newStackFeed.cover?.storyCover {
                /// For correct asynchronous loading of images from the Internet, a tag is added
                feedCover.tag = newStackFeed.currentIndex
                /// downloading an image from the network using the `UIImageView` extension
                /// more details can be seen in ``UIKit/UIImageView/downloadedFrom(url:contentMode:withViewTag:)``
                feedCover.downloadedFrom(url: feedCoverURL, contentMode: .scaleAspectFill, withViewTag: newStackFeed.currentIndex)
            }
            
            /// It is also possible to display the video cover, for this you need to create a player and configure it.
            /// Then get the URL of the video file from `newStackFeed.covervideoCover` and set it for the player.
            /// An example of using a cover video can be seen in ``CustomStoryCell/setVideoURL(_:)``.
        }
    }
}
