//
//  NotificationsController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of using notifications
///
/// Notifications in `InAppStorySDK` are mainly used to track user activity within stories and games.
///
/// - Attention: It is not desirable to use them for interacting with the interface and tracking the r
/// eader's operation, it is better to use closures for that. For more details see ``StoriesClosureHandler``.
///
/// The data in the notification comes to `userInfo` as `Dictionary<String,Any?>`. Don't forget to unwrap optional values.
///
/// For more information and a complete list of notifications with options, see: 
/// [NotificationCenter](https://docs.inappstory.com/sdk-guides/ios/events.html#notificationcenter)
class NotificationsController: UIViewController {
    /// List of stories
    fileprivate var storyView: StoryView!
    /// Customizing the appearance of the controller
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///
        addObservers()
        /// Configuring `InAppStory` before use
        setupInAppStory()
        /// Create and add a list of stories to the screen
        setupStoryView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension NotificationsController {
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storyNotification(notification:)),
                                               name: StoriesLoaded,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storyNotification(notification:)),
                                               name: ClickOnStory,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storyNotification(notification:)),
                                               name: ShowStory,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storyNotification(notification:)),
                                               name: CloseStory,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storyNotification(notification:)),
                                               name: ClickOnButton,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storyNotification(notification:)),
                                               name: ShowSlide,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storyNotification(notification:)),
                                               name: LikeStory,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storyNotification(notification:)),
                                               name: DislikeStory,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storyNotification(notification:)),
                                               name: FavoriteStory,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storyNotification(notification:)),
                                               name: ClickOnShareStory,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storyNotification(notification:)),
                                               name: StartGame,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storyNotification(notification:)),
                                               name: CloseGame,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storyNotification(notification:)),
                                               name: FinishGame,
                                               object: nil)
    }
    
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup `InAppStorySDK` for user with ID
        InAppStory.shared.settings = Settings(userID: "")
    }
    
    /// Create and add a list of stories to the screen
    fileprivate func setupStoryView() {
        /// create instance of `StoryView`
        storyView = StoryView()
        storyView.translatesAutoresizingMaskIntoConstraints = false
        /// adding a point from where the reader will be shown
        storyView.target = self
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

extension NotificationsController {
    @objc func storyNotification(notification: Notification) {
        if notification.userInfo != nil {
            /// display the contents of the notification
            print("Notification UserInfo -> \n\((notification.userInfo as! Dictionary<String, Any>))")
        }
    }
}
