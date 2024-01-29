//
//  CustomSharingController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// To simplify the readability of the code, enter typealias for closure at the end of sharing.
typealias ShareComplete = (Bool) -> Void

/// Example of using a custom modal window for sharing.
/// To work correctly, you need to specify *serviceKey* for SDK in ``AppDelegate``.
///
/// To use URL schema, you need to add their list to info.plist
///
/// ```
/// <key>LSApplicationQueriesSchemes</key>
/// <array>
///     <string>tg</string>
///     <string>instagram</string>
///     <string>instagram-stories</string>
///     <string>whatsapp</string>
/// </array>
/// ```
class CustomSharingController: UIViewController {
    /// List of stories
    fileprivate var storyView: StoryView!
    /// Closure handler from `StoryView`
    fileprivate var closureHandler: StoriesClosureHandler!
    
    /// Customizing the appearance of the controller
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Configuring `InAppStory` before use
        setupInAppStory()
        /// Create and add a list of stories to the screen
        setupStoryView()
    }
}

extension CustomSharingController {
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup `InAppStorySDK` for user with ID
        InAppStory.shared.settings = Settings(userID: "")
        /// Set the closure that will be called when the share button is pressed in the reader
        InAppStory.shared.customShare = customShare(shareObject:complete:)
    }
    
    /// Create and add a list of stories to the screen
    fileprivate func setupStoryView() {
        /// create instance of `StoryView`
        storyView = StoryView()
        storyView.translatesAutoresizingMaskIntoConstraints = false
        /// adding a point from where the reader will be shown
        storyView.target = self
        /// enable the share button in the bottom bar of stories
        /// you must also enable this functionality in the console
        storyView.panelSettings = PanelSettings(share: true)
        /// creating a closure handler for `storyView`
        closureHandler = StoriesClosureHandler(storyView: storyView)
        /// adding a storyView as a subview to the controller
        self.view.addSubview(storyView)
        
        /// configuring the constants to display the list correctly
        var allConstraints: [NSLayoutConstraint] = []
        /// horizontally - from edge to edge
        let horConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[storyView]-(0)-|",
                                                           options: [.alignAllLeading, .alignAllTrailing],
                                                           metrics: nil,
                                                           views: ["storyView": storyView!])
        allConstraints += horConstraint
        /// vertically - height 180pt with a 16pt indent at the top
        let vertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(16)-[storyView(180)]",
                                                            options: [.alignAllTop, .alignAllBottom],
                                                            metrics: nil,
                                                            views: ["storyView": storyView!])
        allConstraints += vertConstraint
        /// constraints activation
        NSLayoutConstraint.activate(allConstraints)
        
        /// running internal `StoryView` logic
        storyView.create()
    }
}

extension CustomSharingController {
    /// Function that handles closure, which is called when the reader's sharings button is pressed.
    /// - Parameters:
    ///   - shareObject: object that contains data to be shared
    ///   - complete: closure that must be called when unsharing is finished (e.g. closing the sharing window)
    ///
    /// ### SharingObject
    /// - `text` - plain text <String?>;
    /// - `images` - image array <Array<UIImage>?>;
    /// - `link` -  link <String?>;
    /// - `payload` - custom data set in the console when creating the widget "Share <String?>;
    func customShare(shareObject: SharingObject, complete: @escaping ShareComplete) {
        /// Creating a custom sharing window instance
        let customShareView = SharingViewController(shareObject: shareObject, complete: complete) { [weak self] in
            guard let weakSelf = self else { return }
            /// This closure is called if the user wants to use system sharing and taps the relevant button, see ``ShareView/defaultComplete``.
            weakSelf.defaultShareComplete(shareObject: shareObject, complete: complete)
        }
        /// Display the controller on top of the reader
        InAppStory.shared.present(controller: customShareView, with: .crossDissolve)
    }
    
    /// Method of displaying the system window of sharing
    /// - Parameters:
    ///   - shareObject: object that contains data to be shared
    ///   - complete: closure that must be called when unsharing is finished (e.g. closing the sharing window)
    ///
    /// ### SharingObject
    /// - `text` - plain text <String?>;
    /// - `images` - image array <Array<UIImage>?>;
    /// - `link` -  link <String?>;
    /// - `payload` - custom data set in the console when creating the widget "Share <String?>;
    func defaultShareComplete(shareObject: SharingObject, complete: ((Bool) -> Void)? = nil) {
        /// Creating a list of objects for sharing
        var items = [Any]()
        /// If the object contains text
        if let text = shareObject.text {
            items.append(text)
        }
        /// If the object contains link
        if let url = shareObject.link {
            items.append(url)
        }
        /// If the object contains images
        if let images = shareObject.images, !images.isEmpty {
            for image in images {
                items.append(image)
            }
        }
        
        /// Create `UIActivityViewController` for displaying on top of the reader. Because `UIActivityViewController`
        /// is an inheritor of `UIViewController` class, there is no need to do anything with it before displaying.
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        /// On closure of the sharding, it should be passed to the closure with what result it was completed.
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            if let completeSharing = complete {
                if success {
                    completeSharing(true)
                } else {
                    completeSharing(false)
                }
                
                if error != nil {
                    completeSharing(false)
                }
            }
        }
        
        /// Display the controller on top of the reader
        InAppStory.shared.present(controller: activityViewController, with: .crossDissolve)
    }
}
