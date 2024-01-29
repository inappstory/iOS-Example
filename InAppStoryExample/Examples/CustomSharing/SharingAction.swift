//
//  SharingAction.swift
//  InAppStoryExample_SwiftUI
//

import Foundation
import InAppStorySDK

/// enumeration of events available for sharing
enum SharingAction {
    case telegram, whatsapp, instagram, sms
    
    /// link with url scheme for each action
    var url: String {
        switch self {
        case .telegram:
            return "tg://msg_url"
        case .whatsapp:
            return "whatsapp://send"
        case .instagram:
            return "instagram-stories://share"
        case .sms:
            return "sms://share"
        }
    }
    
    /// icons
    var icon: String {
        switch self {
        case .telegram:
            return "tg_icon"
        case .whatsapp:
            return "what_icon"
        case .instagram:
            return "inst_icon"
        case .sms:
            return "sms_icon"
        }
    }
    
    /// titles
    var title: String {
        switch self {
        case .telegram:
            return "Telegram"
        case .whatsapp:
            return "WhatsApp"
        case .instagram:
            return "Instagram"
        case .sms:
            return "Messages"
        }
    }
    
    /// generate full link
    /// - Parameter sharingObject: object that contains data to be shared
    /// - Returns: full sharings link
    ///
    /// ### SharingObject
    /// - `text` - plain text <String?>;
    /// - `images` - image array <Array<UIImage>?>;
    /// - `link` -  link <String?>;
    /// - `payload` - custom data set in the console when creating the widget "Share <String?>;
    func generateURL(sharingObject: SharingObject) -> URL? {
        switch self {
        case .telegram:
            return generateTelegramURL(sharingObject: sharingObject)
        case .whatsapp:
            return generateWhatsappURL(sharingObject: sharingObject)
        case .instagram:
            return generateStoriesURL(sharingObject: sharingObject)
        case .sms:
            return generateSMSURL(sharingObject: sharingObject)
        }
    }
    
    /// generate a link for WhatsApp
    private func generateWhatsappURL(sharingObject: SharingObject) -> URL? {
        var urlString = "whatsapp://send"
        if let url = sharingObject.link {
            urlString += "?text=\(url)"
        }
        
        guard let finalString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: finalString)
    }
    
    /// generate a link for Telegram
    private func generateTelegramURL(sharingObject: SharingObject) -> URL? {
        var urlString = "tg://msg_url?"
        if let url = sharingObject.link {
            urlString += "url=\(url)"
        }
        
        if let title = sharingObject.text {
            urlString += (sharingObject.link != nil ? "&text=" : "text=") + title
        }
        
        guard let finalString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: finalString)
    }
    
    /// generate a link for iMessage
    private func generateSMSURL(sharingObject: SharingObject) -> URL? {
        var urlString = "sms://"
        if let url = sharingObject.link {
            urlString += "&body=\(url)"
        }
        
        guard let finalString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: finalString)
    }
    
    /// generate a link for Instagram
    private func generateStoriesURL(sharingObject: SharingObject) -> URL? {
        guard let images = sharingObject.images else { return nil }
        let image = images[0]
        
        guard let imageData = image.pngData() else { return nil }
        
        let pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.backgroundImage" : imageData
        ]
        
        let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)]
        UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
        
        /// you need to replace "<Application key>" with the one obtained in the Instagram developer console
        return URL(string: "instagram-stories://share?source_application=<Application key>")
    }
}
