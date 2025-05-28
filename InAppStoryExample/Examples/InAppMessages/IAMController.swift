//
//  IAMController.swift
//  InAppStoryExample
//
//  Created by StPashik on 28.05.2025.
//

import UIKit
import InAppStorySDK

/// Starting from version 1.25.0, In-App-Messaging was added to the SDK.
/// 
/// This code example provides a guide on how to use the InAppMessaging (IAM) module,
/// which allows you to manage in-app messages (such as banners, notifications, etc.)
/// in your application. The module provides methods for preloading messages,
/// displaying them, and handling related events.
///
/// For faster display of InAppMessages on the screen,
/// it is possible to load their data in advance. To do this, call
/// the InAppStory.shared.preloadInAppMessages() method in advance and wait for it to execute.
///
/// - Warning: In order for the preload to be successful, the SDK must be initialized beforehand.
///
/// For InAppMessages, you can use tags for more precise control over the display of messages.
/// In order to perform preloading with known tags, it is necessary when calling
/// the preloadInAppMessages method, to specify the list of tags, by which messages should be received
///
/// - Warning: The same limitations are set for the list of tags as for showing storis. [more](https://docs.inappstory.com/sdk-guides/ios/tags.html)
///
/// To keep track of screen showing and closing, closures have been added, similar to storis in the InAppStory class
/// - `inAppMessageWillShow: (() -> Void)` - called when the InAppMessage screen is shown;
/// - `inAppMessageDidClose: (() -> Void)` - called when the InAppMessage screen has closed;
///
/// Also, the `InAppStory.shared.onActionWith` closure will be called to track user actions
/// within the message (see [link-handling](https://docs.inappstory.com/sdk-guides/ios/link-handling.html#simple-link-handling) for details)
///
/// To receive notifications, a separate closure `InAppStory.shared.inAppMessagesEvent` has been started.
/// The `InAppStory.shared.failureEvent` closure is used to track errors.
///
/// Event descriptions are listed [here](https://docs.inappstory.com/sdk-guides/ios/in-app-messaging.html#events)
class IAMController: UIViewController {
    fileprivate var isIAMPreloaded: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        /// Configuring `InAppStory` before use
        setupInAppStory()
        /// Create and add a button
        setupInterface()
    }
}

extension IAMController{
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// Setup `InAppStorySDK` for user with ID
        InAppStory.shared.settings = Settings(userID: "")
        /// For correct and faster display of InAppMessages it is desirable to preload from data.
        /// It is best to do it on SplashScreen, but if at that moment
        /// the data for SDK initialization (`InAppStory.shared.init(:)`) is not yet known,
        /// it is better to preload it immediately after receiving it.
        ///
        /// Also, preloads can be done by id or tag list.
        /// For more details see [here](https://docs.inappstory.com/sdk-guides/ios/in-app-messaging.html#preloading)
        InAppStory.shared.preloadInAppMessages { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                // data download was successful
                isIAMPreloaded = true
                break
            case .failure:
                // problems occurred during the download
                isIAMPreloaded = false
                break
            }
        }
        
        /// setting a closure on user action in stories
        InAppStory.shared.onActionWith = onActionWith
        /// setting the reader opening closure
        InAppStory.shared.inAppMessageWillShow = inAppMessageWillShow
        /// setting the reader closing closure
        InAppStory.shared.inAppMessageDidClose = inAppMessageDidClose
    }
    
    /// Creating and customizing the user change button
    fileprivate func setupInterface() {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show InAppMessage", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        view.addSubview(button)
        
        let centerXConstraint = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 130)
        let heightConstraint = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
        
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint, widthConstraint, heightConstraint])
    }
}

fileprivate extension IAMController {
    /// For displaying InAppMessages by ID, preloading is not necessary,
    /// but in this case, the display itself will take longer
    /// due to the loading of all necessary data.
    ///
    /// If the onlyPreloaded parameter is set when displaying InAppMessages,
    /// then preloading is required, otherwise nothing will be shown.
    func showIAMByID() {
        /// show InAppMessage by id
        InAppStory.shared.showInAppMessageWith(id: "", onlyPreloaded: false) { show in
            print("Show IAM: \(show)")
        }
    }
    
    /// For displaying InAppMessages by event, preloading is not necessary,
    /// but in this case, the display itself will take longer
    /// because of loading all the necessary data.
    ///
    /// If the onlyPreloaded parameter is set when displaying InAppMessages,
    /// then preloading is required, otherwise nothing will be shown.
    ///
    /// Also, when displaying by event, you can specify a list of tags
    /// by which the possible variants of displaying InAppMessages will be filtered.
    func showIAMByEvent() {
        guard isIAMPreloaded else { return }
        
        /// show InAppMessage by event
        InAppStory.shared.showInAppMessageWith(event: "", onlyPreloaded: false, tags: ["tag1", "tag2"]) { show in
            print("Show IAM by event: \(show)")
        }
    }
}

extension IAMController {
    /// Processing of showing InAppMessage
    @objc func buttonAction(sender: UIButton!) {
        showIAMByID()
        
//        showIAMByEvent()
    }
}

extension IAMController {
    /// closure, called when a button or SwipeUp event is triggered in the reader
    /// - Parameters:
    ///   - target: the action by which the link was obtained
    ///   - type: type of action that called this method
    ///   - storyType: the type of stories that have been opened, depending on the source
    ///
    /// ### ActionType
    /// - `.button` - push the button in story;
    /// - `.swipe` - swipe up slide in story;
    /// - `.game` - link from Game;
    /// - `.deeplink` - deeplink from cell in story list.
    ///
    /// ### StoriesType
    /// when calling an event from InAppMessage storyType will be equal to nil
    func onActionWith(_ target: String, _ type: ActionType, _ storyType: StoriesType?) {
        if let url = URL(string: target) {
            UIApplication.shared.open(url)
        }
    }
    
    /// closure, is called each time the IAM reader is opened
    func inAppMessageWillShow() {
        print("InAppMessage will show")
    }
    
    /// is called each time the IAM reader is closed
    func inAppMessageDidClose() {
        print("InAppMessage did close")
    }
}
