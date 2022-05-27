//
//  ChatLogView.swift
//  MessengerApp
//
//  Created by Anthony Magana on 5/26/22.
//

import SwiftUI

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    @State var chatText = ""
    
    var body: some View {
        ZStack {
            chatMessagesView
            
            VStack{
                Spacer()
                chatBottomBar
                    .background(Color.white)
            }
        }
        .navigationTitle(chatUser?.username ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    private var chatMessagesView: some View {
        ScrollView{
            ForEach(0..<20) { num in
                HStack {
                    Spacer()
                    HStack {
                        Text("Fake Message")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            HStack {Spacer()}
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
        .padding(.bottom, 55)
    }
    
    private var chatBottomBar: some View {
        HStack(spacing:16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            TextField("Send a message...", text: $chatText)
            Button {
                
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatLogView(chatUser: .init(data: ["uid": "aToAMj1bt7V48bAZZOc5m7NEHEc2", "email": "test@gmail.com"]))
        }
    }
}
