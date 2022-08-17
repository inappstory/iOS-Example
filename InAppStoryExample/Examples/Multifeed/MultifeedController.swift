//
//  MultifeedController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

class MultifeedController: UIViewController
{
    fileprivate var storyView: StoryView!
    fileprivate var customFeedStoryView: StoryView!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupInAppStory()

        setupStoryViews()
    }
}

extension MultifeedController
{
    fileprivate func setupInAppStory()
    {
        // setup InAppStorySDK for user with ID
        InAppStory.shared.settings = Settings(userID: "")
    }
    
    fileprivate func setupStoryViews()
    {
        // create instance of StoryView with default feed
        storyView = StoryView(favorite: false)
        storyView.translatesAutoresizingMaskIntoConstraints = false
        // adding a point from where the reader will be shown
        storyView.target = self
        // set StoryView delegate
        storyView.storiesDelegate = self
        
        self.view.addSubview(storyView)
        
        // create instance of StoryView with custom feed id - "custom_feed"
        customFeedStoryView = StoryView(feed: "custom_feed", favorite: false)
        customFeedStoryView.translatesAutoresizingMaskIntoConstraints = false
        // adding a point from where the reader will be shown
        customFeedStoryView.target = self
        // set StoryView delegate
        customFeedStoryView.storiesDelegate = self
        
        self.view.addSubview(customFeedStoryView)
        
        var allConstraints: [NSLayoutConstraint] = []
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[storyView]-(0)-|",
                                                         options: [.alignAllLeading, .alignAllTrailing],
                                                         metrics: nil,
                                                         views: ["storyView": storyView!])
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[customFeedStoryView]-(0)-|",
                                                         options: [.alignAllLeading, .alignAllTrailing],
                                                         metrics: nil,
                                                         views: ["customFeedStoryView": customFeedStoryView!])
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(16)-[storyView(180)]-(16)-[customFeedStoryView(180)]",
                                                         options: [.alignAllLeft],
                                                         metrics: nil,
                                                         views: ["storyView": storyView!, "customFeedStoryView": customFeedStoryView!])
        NSLayoutConstraint.activate(allConstraints)
        
        // running internal StoryView logic
        storyView.create()
        customFeedStoryView.create()
    }
}

extension MultifeedController: InAppStoryDelegate
{
    // delegate method, called when the data is updated
    func storiesDidUpdated(isContent: Bool, from storyType: StoriesType)
    {
        guard let currentStoryView = storyView else {
            return
        }
        
        if currentStoryView.isContent {
            switch storyType {
            case .list(let feed):
                print("StoryView has content in feed \(feed ?? "")")
            case .single:
                print("SingleStory has content")
            case .onboarding(let feed):
                print("Onboarding has content in feed \(feed)")
            }
        } else {
            print("No content")
        }
    }
    
    // delegate method, called when a button or SwipeUp event is triggered in the reader
    // types is .button, .game, .deeplink, .swipe
    func storyReader(actionWith target: String, for type: ActionType, from storyType: StoriesType) {
        if let url = URL(string: target) {
            UIApplication.shared.open(url)
        }
    }
    
    // delegate method, called when the reader will show
    func storyReaderWillShow(with storyType: StoriesType)
    {
        switch storyType {
        case .list(let feed):
            print("StoryView reader will show from feed \(feed ?? "")")
        case .single:
            print("SingleStory reader will show")
        case .onboarding(let feed):
            print("Onboarding reader will show from feed \(feed)")
        }
    }
    
    // delegate method, called when the reader did close
    func storyReaderDidClose(with storyType: StoriesType)
    {
        switch storyType {
        case .list(let feed):
            print("StoryView reader did close to feed \(feed ?? "")")
        case .single:
            print("SingleStory reader did close")
        case .onboarding(let feed):
            print("Onboarding reader did close to feed \(feed)")
        }
    }
}
