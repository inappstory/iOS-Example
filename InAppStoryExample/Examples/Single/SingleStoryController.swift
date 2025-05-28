//
//  SingleStoryController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of using a single story display
///
/// To show a single story, you need to know its ID specified in the console.
/// To display stories on the screen, just call `InAppStory.shared.showSingle`.
///
/// As a target, it is desirable to specify the top controller in the screen hierarchy to properly display
/// the reader on top of all application elements.
///
/// If you want to change the appearance or animation of the reader's show, only for displaying single story,
/// you need to set parameters in `InAppStory` before calling `InAppStory.shared.showSingle`.
/// For more information on reader customization, see ``ReaderCustomizationController``.
///
/// - Warning: Changes set for single reader customization will be applied to the whole library.
/// In order to return the original settings for other readers, it is necessary in the `storyReaderDidClose` closure
/// to set the reader settings as they were before the single reader was displayed.
///
/// - Note: If initially, some display parameters were set by default and were not changed,
/// before displaying the single reader with custom settings, they should be saved and applied
/// to `InAppStory` after closing the reader.
///
/// The only thing that can be changed independently is the display of the bottom panel using the `PanelSettings` object
/// when `showSingle` is called, this change will not affect other readers and will only be used to display a particular story.
///
/// # PanelSettings
/// For an single reader instance, you can set unique bottom panel settings that will ignore those set for `StoryView`. 
/// In this way, you can disable the bottom panel functionality that is not required for onboarding.
/// ```
/// InAppStory.shared.showSingle(with: "StoryID", from: self, with: PanelSettings(like: false)) { show in }
/// ```
///
/// For more information see [Single story](https://docs.inappstory.com/sdk-guides/ios/single-story.html#single-story)
class SingleStoryController: UIViewController{
    /// List of stories
    fileprivate var storyView: StoryView!
    
    /// Customizing the appearance of the controller
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Configuring `InAppStory` before use
        setupInAppStory()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupInterface()
    }
}

extension SingleStoryController {
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup `InAppStorySDK` for user with ID
        InAppStory.shared.storiesDidUpdated = storiesDidUpdated
        /// setting a closure on user action in stories
        InAppStory.shared.onActionWith = onActionWith
        /// setting the reader opening closure
        InAppStory.shared.storyReaderWillShow = storyReaderWillShow(_:)
        /// setting the reader closing closure
        InAppStory.shared.storyReaderDidClose = storyReaderDidClose(_:)
    }
    
    /// Creating a button to show a single story when tapped
    fileprivate func setupInterface() {
        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 150.0, height: 30.0))
        button.setTitle("Show Single Story", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.center = CGPoint(x: view.frame.size.width  / 2,
                                y: view.frame.size.height / 2)
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view.addSubview(button)
    }
}

extension SingleStoryController {
    @objc func buttonAction(sender: UIButton!) {
        /// show singlel story reader with completion
        InAppStory.shared.showStory(with: "", from: self) { show in
            print("Story reader \(show ? "is" : "not") showing")
        }
    }
}

extension SingleStoryController {
    /// Closure, is called every time the content in the list is updated
    /// - Parameters:
    ///   - isContent: displays whether the content is present in the list
    ///   - storyType: the type of stories that have been opened, depending on the source
    ///
    /// ### StoriesType
    /// - `.list(feed: <String>?)` - type for StoryView, *feed* - id stories list;
    /// - `.single` - type for single story reader;
    /// - `.onboarding(feed: <String>)` - type for onboarding story reader, *feed* - id stories list.
    func storiesDidUpdated(_ isContent: Bool, _ storyType: StoriesType) {
        if isContent {
            switch storyType {
            case .list:
                print("StoryView has content")
            case .single:
                print("SingleStory has content")
            case .onboarding:
                print("Onboarding has content")
            case .ugcList:
                print("UGC StoryView has content")
            @unknown default:
                break
            }
        } else {
            print("No content")
        }
    }
    
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
    /// - `.list(feed: <String>?)` - type for StoryView, *feed* - id stories list;
    /// - `.single` - type for single story reader;
    /// - `.onboarding(feed: <String>)` - type for onboarding story reader, *feed* - id stories list.
    func onActionWith(_ target: String, _ type: ActionType, _ storyType: StoriesType?) {
        if let url = URL(string: target) {
            UIApplication.shared.open(url)
        }
    }
    
    /// closure, is called each time the reader is opened
    /// - Parameter storyType: the type of stories that have been opened, depending on the source
    ///
    /// ### StoriesType
    /// - `.list(feed: <String>?)` - type for StoryView, *feed* - id stories list;
    /// - `.single` - type for single story reader;
    /// - `.onboarding(feed: <String>)` - type for onboarding story reader, *feed* - id stories list.
    func storyReaderWillShow(_ storyType: StoriesType) {
        switch storyType {
        case .list:
            print("StoryView reader will show")
        case .single:
            print("SingleStory reader will show")
        case .onboarding:
            print("Onboarding reader will show")
        case .ugcList:
            print("UGC reader will show")
        @unknown default:
            break
        }
    }
    
    /// is called each time the reader is closed
    /// - Parameter storyType: the type of stories that have been opened, depending on the source
    ///
    /// ### StoriesType
    /// - `.list(feed: <String>?)` - type for StoryView, *feed* - id stories list;
    /// - `.single` - type for single story reader;
    /// - `.onboarding(feed: <String>)` - type for onboarding story reader, *feed* - id stories list.
    ///
    /// > Opening a link within a stories leading to another stories also closes the reader and causes this closure.
    /// > There are cases when the reader may not close when trying to open stories, if the given story is already in the list,
    /// > in this case it is simply flipping to the necessary index.
    /// >
    /// > Also the reader will not be closed if there is an attempt to open the game from stories.
    func storyReaderDidClose(_ storyType: StoriesType) {
        switch storyType {
        case .list:
            print("StoryView reader did close")
        case .single:
            print("SingleStory reader did close")
        case .onboarding:
            print("Onboarding reader did close")
        case .ugcList:
            print("UGC reader did close")
        @unknown default:
            break
        }
    }
}

