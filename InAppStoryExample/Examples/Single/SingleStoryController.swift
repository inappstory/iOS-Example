//
//  SingleStoryController.swift
//  InAppStoryExample
//
//  For more information see: https://github.com/inappstory/ios-sdk/blob/main/Samples/SingleStory.md
//

import UIKit
import InAppStorySDK

class SingleStoryController: UIViewController
{
    fileprivate var storyView: StoryView!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupInAppStory()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupInterface()
    }
}

extension SingleStoryController
{
    fileprivate func setupInAppStory()
    {
        // setup InAppStorySDK for user with ID
        InAppStory.shared.settings = Settings(userID: "")
    }
    
    fileprivate func setupInterface()
    {
        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 150.0, height: 30.0))
        button.setTitle("Show Single Story", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.center = CGPoint(x: view.frame.size.width  / 2,
                                y: view.frame.size.height / 2)
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view.addSubview(button)
    }
}

extension SingleStoryController
{
    @objc func buttonAction(sender: UIButton!)
    {
        // show singlel story reader with completion
        InAppStory.shared.showSingle(with: "", from: self, delegate: self) { show in
            print("Story reader \(show ? "is" : "not") showing")
        }
    }
}

extension SingleStoryController: InAppStoryDelegate
{
    // delegate method, called when the data is updated
    func storiesDidUpdated(isContent: Bool, from storyType: StoriesType)
    {
        guard let currentStoryView = storyView else {
            return
        }
        
        if currentStoryView.isContent {
            switch storyType {
            case .list:
                print("StoryView has content")
            case .single:
                print("SingleStory has content")
            case .onboarding:
                print("Onboarding has content")
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
        case .list:
            print("StoryView reader will show")
        case .single:
            print("SingleStory reader will show")
        case .onboarding:
            print("Onboarding reader will show")
        }
    }
    
    // delegate method, called when the reader did close
    func storyReaderDidClose(with storyType: StoriesType)
    {
        switch storyType {
        case .list:
            print("StoryView reader did close")
        case .single:
            print("SingleStory reader did close")
        case .onboarding:
            print("Onboarding reader did close")
        }
    }
}

