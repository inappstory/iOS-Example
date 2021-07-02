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
        InAppStory.shared.showSingleStory(with: "", from: self, delegate: self) {}
    }
}

extension SingleStoryController: SingleStoryDelegate
{
    // delegate method, called when the data in the single story is updated
    func singleStoryUpdated(isContent: Bool)
    {
        if isContent {
            print("StoryView has content")
        } else {
            print("No content")
        }
    }
    
    // delegate method, called when a button or SwipeUp event is triggered in the reader
    func singleStory(actionWith target: String, for type: ActionType)
    {
        if let url = URL(string: target) {
            UIApplication.shared.open(url)
        }
    }
    
    // delegate method, called when the reader will show
    func singleStoryReaderWillShow()
    {
        print("StoryView reader will show")
    }
    
    // delegate method, called when the reader did close
    func singleStoryReaderDidClose()
    {
        print("StoryView reader did close")
    }
}
