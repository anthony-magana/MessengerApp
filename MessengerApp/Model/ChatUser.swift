//
//  ChatUser.swift
//  MessengerApp
//
//  Created by Anthony Magana on 5/18/22.
//

import Foundation

struct ChatUser: Identifiable {
    
    var id: String { uid }
    let uid, email, username, profileImageUrl: String
    
    init(data: [String: Any]) {
        
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""

        var username = ""
        for char in self.email {
            if char == "@" { break }
            else { username += "\(char)" }
        }
        self.username = username
    }
}
