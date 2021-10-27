//
//  GoodsView.swift
//  InAppStoryApp
//
//  Created by StPashik on 21.10.2021.
//

import UIKit
import InAppStorySDK

class GoodsView: CustomGoodsView
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        
        let singleFingerTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        self.addGestureRecognizer(singleFingerTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // set list of SKUs from InAppStory reader
    override func setSKUItems(_ items: Array<String>) {
        super.setSKUItems(items)
        
        print("Get widget skus - \(items.joined(separator: ","))")
    }
    
    // set reader frame? actual for iPads
    override func setReaderFrame(_ frame: CGRect) {
        super.setReaderFrame(frame)
        
        print("Reader frame = CGRect(x: \(frame.origin.x), y: \(frame.origin.y), width: \(frame.width), height: \(frame.height)")
    }
    
    // single tap for close widget in reader
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer?) {
        super.close()
    }
}
