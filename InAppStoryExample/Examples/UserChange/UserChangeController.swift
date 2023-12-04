//
//  UserChangeController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of changing a user in an application
///
/// After initializing and configuring `InAppStory`, it may be necessary to change the user in the SDK,
///  for example after authorization. To do this, you need to create a new `Settings` object and set it to `InAppStory.shared.settings`.
///
/// If the application has a list of stories, then after setting a new UserID, you should call `StoryView` method `refresh()`.
/// Also, if the application significantly redraws the screen after changing the user, you can recreate `StoryView`.
///
/// If the application does not use the `StoryView` list, and only displays onboarding and single stories,
/// then after setting a new UserID, you don't need to do anything, the next time you call the reader,
/// the SDK will display stories for the new user.
///
/// - Note: If it is necessary to display the list of stories or the reader's appearance differently for different users, 
/// for example, an unauthorized user cannot like stories and add them to favorites,
/// it is recommended to set these settings immediately after setting a new UserID in `InAppStory`.
///
/// Also, if a new user needs to assign a new set of tags or display a different feed, they can be specified
/// when `refresh` is called. For more information on tags, see ``TagsPlaceholdersController``
/// ```
/// func changeUser() {
///     InAppStory.shared.settings = Settings(userID: <String>)
///     storyView.refresh(newFeed: "new_feed", newTags: ["newTag_1", "newTag_2"])
/// }
/// ```
///
/// For more information see: [User change](https://docs.inappstory.com/sdk-guides/ios/user-change.html#user-change)
class UserChangeController: UIViewController {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupInterface()
    }
}

extension UserChangeController {
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup `InAppStorySDK` for user with ID
        InAppStory.shared.settings = Settings(userID: "")
    }
    
    /// Creating and customizing the user change button
    fileprivate func setupInterface() {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Change User", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        view.addSubview(button)
        
        let centerXConstraint = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 130)
        let heightConstraint = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
        
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint, widthConstraint, heightConstraint])
    }
    
    /// Create and add a list of stories to the screen
    fileprivate func setupStoryView() {
        /// create instance of `StoryView`
        storyView = StoryView()
        storyView.translatesAutoresizingMaskIntoConstraints = false
        /// adding a point from where the reader will be shown
        storyView.target = self
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

extension UserChangeController {
    /// Processing of user change button pressing
    @objc func buttonAction(sender: UIButton!) {
        /// set setting with new uesrID
        InAppStory.shared.settings = Settings(userID: "newUser")
        /// for update data, need refres StoryView
        storyView.refresh()
    }
}
