//
//  ChatLogView.swift
//  MessengerApp
//
//  Created by Anthony Magana on 5/26/22.
//

import SwiftUI
import Firebase

struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
}

struct ChatMessage: Identifiable {
    var id: String { documentId }
    
    let documentId: String
    let fromId, toId, text: String
    
    init(documentId: String, data: [String: Any]){
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}

class ChatLogViewModel: ObservableObject {
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    @Published var chatMessages = [ChatMessage]()
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    private func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let err = error {
                    self.errorMessage = "Failed to listen for messages : \(err)"
                    print(err)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                    }
                })
                
//                querySnapshot?.documents.forEach({ QueryDocumentSnapshot in
//                    let data = QueryDocumentSnapshot.data()
//                    let docId = QueryDocumentSnapshot.documentID
//                    self.chatMessages.append(.init(documentId: docId, data: data))
//                })
            }
    }
    
    func handleSend() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText, "timestamp": Timestamp()] as [String: Any]
        
        document.setData(messageData) { error in
            if let err = error {
                self.errorMessage = "Failed to save message to Firestore \(err)"
                return
            }
            self.chatText = ""
            print("Successfully sent and saved message")
        }
        
        let recipientDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        recipientDocument.setData(messageData) { error in
            if let err = error {
                self.errorMessage = "Failed to save message to Firestore \(err)"
                return
            }
            print("Recipient Successfully recieved message")
        }
    }
}

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    
    @ObservedObject var vm: ChatLogViewModel
    
    var body: some View {
        ZStack {
            chatMessagesView
            Text(vm.errorMessage)
        }
        .navigationTitle(chatUser?.username ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    private var chatMessagesView: some View {
        VStack {
            ScrollView{
                ForEach(vm.chatMessages) { message in
                    VStack {
                        if message.fromId == FirebaseManager.shared.auth.currentUser?.uid{
                            HStack {
                                Spacer()
                                HStack {
                                    Text(message.text)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                                
                            }
                        } else {
                            HStack {
                                HStack {
                                    Text(message.text)
                                        .foregroundColor(.black)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                HStack {Spacer()}
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
            .safeAreaInset(edge: .bottom) {
                chatBottomBar
                    .background(Color(.systemBackground).ignoresSafeArea())
            }
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing:16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            TextField("Send a message...", text: $vm.chatText)
            Button {
                vm.handleSend()
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
//        NavigationView {
//            ChatLogView(chatUser: .init(data: ["uid": "aToAMj1bt7V48bAZZOc5m7NEHEc2", "email": "test@gmail.com"]))
//        }
        MainMessagesView()
    }
}
