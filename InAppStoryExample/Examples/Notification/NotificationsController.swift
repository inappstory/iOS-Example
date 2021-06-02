//
//  NotificationsController.swift
//  InAppStoryExample
//
//  For more information see: https://github.com/inappstory/ios-sdk#notificationcenter
//

import UIKit
import InAppStorySDK

class NotificationsController: UIViewController {

    fileprivate var storyView: StoryView!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObservers()

        setupInAppStory()
        
        setupStoryView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension NotificationsController
{
    // for all notifications see: https://github.com/inappstory/ios-sdk#notificationcenter
    fileprivate func addObservers()
    {
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
    
    fileprivate func setupInAppStory()
    {
        // setup InAppStorySDK for user with ID
        InAppStory.shared.settings = Settings(userID: "")
    }
    
    fileprivate func setupStoryView()
    {
        // create instance of StoryView
        storyView = StoryView(frame: .zero, favorite: false)
        storyView.translatesAutoresizingMaskIntoConstraints = false
        // adding a point from where the reader will be shown
        storyView.target = self
        
        self.view.addSubview(storyView)
        
        var allConstraints: [NSLayoutConstraint] = []
        let horConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[storyView]-(0)-|",
                                                           options: [.alignAllLeading, .alignAllTrailing],
                                                           metrics: nil,
                                                           views: ["storyView": storyView!])
        allConstraints += horConstraint
        let vertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(16)-[storyView(180)]",
                                                            options: [.alignAllTop, .alignAllBottom],
                                                            metrics: nil,
                                                            views: ["storyView": storyView!])
        allConstraints += vertConstraint
        NSLayoutConstraint.activate(allConstraints)
        
        // running internal StoryView logic
        storyView.create()
    }
}

extension NotificationsController
{
    @objc func storyNotification(notification: Notification)
    {
        if notification.userInfo != nil {
            print("Notification UserInfo -> \n\((notification.userInfo as! Dictionary<String, Any>))")
        }
    }
}
