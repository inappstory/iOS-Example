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
        /// creation of observers for screening events via NotificationCenter
        addObservers()
        /// a more preferred method of tracking notifications from the SDK using closures
        createNotificationClosure()
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

extension NotificationsController {
    func createNotificationClosure() {
        InAppStory.shared.storiesEvent = {
            switch $0 {
            case .storiesLoaded(let feed, let stories):
                print("StoriesLoaded by \(String(describing: feed)) and count: \(stories.count)")
            case .ugcStoriesLoaded(let stories):
                print("UGCStoriesLoaded with count: \(stories.count)")
            case .clickOnStory(let storyData, let index):
                print("ClickOnStory at index: \(index)")
            case .showStory(let storyData, let action):
                print("ShowStory by action: \(action)")
            case .closeStory(let slideData, let action):
                print("CloseStory by action: \(action)")
            case .clickOnButton(let slideData, let link):
                print("ClickOnButton with link: \(link)")
            case .showSlide(let slideData):
                print("ShowSlide")
            case .likeStory(let slideData, let value):
                print("LikeStory with value: \(value)")
            case .dislikeStory(let slideData, let value):
                print("DislikeStory with value: \(value)")
            case .favoriteStory(let slideData, let value):
                print("FavoriteStory with value: \(value)")
            case .clickOnShareStory(let slideData):
                print("ClickOnShareStory")
            case .storyWidgetEvent(let slideData, let name, let data):
                print("StoryWidgetEvent with name \(name)")
            @unknown default:
                print("default")
            }
        }
        
        InAppStory.shared.gameEvent = {
            switch $0 {
            case .startGame(let gameData):
                print("StartGame")
            case .closeGame(let gameData):
                print("CloseGame")
            case .finishGame(let gameData, let result):
                print("FinishGame with result: \(result)")
            case .eventGame(let gameData, let name, let payload):
                print("EventGame with name: \(name) and payload: \(payload)")
            case .gameFailure(let gameData, let message):
                print("GameFailure with message: \(message)")
            @unknown default:
                print("default")
            }
        }
        
        InAppStory.shared.inAppMessagesEvent = {
            switch $0 {
            case .preloaded(let messages):
                print("IAM Preloaded with messages: \(messages.compactMap { $0.id })")
            case .show(let iamData):
                print("IAM Show with id: \(iamData.id ?? "") at campaign name: \(iamData.campaign ?? "")")
            case .close(let iamData):
                print("IAM Close with id: \(iamData.id ?? "") at campaign name: \(iamData.campaign ?? "")")
            case .clickOnButton(let iamData, let link):
                print("IAM Clisck on button with id: \(iamData.id ?? "") at campaign name: \(iamData.campaign ?? "") with link: \(link)")
            case .widgetEvent(let iamData, let name, let data):
                print("IAM Widget event with id: \(iamData.id ?? "") at campaign name: \(iamData.campaign ?? "") with name: \(name)")
            @unknown default:
                print("default")
            }
        }
        
        InAppStory.shared.failureEvent = {
            switch $0 {
            case .sessionFailure(let message):
                print("SessionFailure with maeesage: \(message)")
            case .storyFailure(let message):
                print("StoryFailure with maeesage: \(message)")
            case .currentStoryFailure(let message):
                print("CurrentStoryFailure with maeesage: \(message)")
            case .networkFailure(let message):
                print("NetworkFailure with maeesage: \(message)")
            case .requestFailure(let message, let statusCode):
                print("RequestFailure with maeesage: \(message) and code: \(statusCode)")
            case .inAppMessageFailure(message: let message):
                print("InAppMessagesFailure with maeesage: \(message)")
            @unknown default:
                break
            }
        }
    }
}
