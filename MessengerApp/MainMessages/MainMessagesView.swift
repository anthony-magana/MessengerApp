//
//  MainMessagesView.swift
//  MessengerApp
//
//  Created by Anthony Magana on 5/17/22.
//

import SwiftUI
import SDWebImageSwiftUI

class MainMessagesViewModel: ObservableObject {
    @Published var errMessage = ""
    @Published var chatUser: ChatUser?
    
    init() {
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errMessage = "Could not find firebase uid"
            return
        }

        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let err = error {
                self.errMessage = "Failed to fetch current user: \(err)"
                print("Failed to fetch current user: \(err)")
                return
            }
                        
            guard let data = snapshot?.data() else {
                self.errMessage = "No data found"
                return
            }
            
            self.chatUser = .init(data: data)
            
        }
    }
    
    @Published var isUserCurrentlyLoggedOut = false
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}

struct MainMessagesView: View {
    
    @State var shouldShowLogOut = false
    @State var shouldNavigateToChatLogView = false
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    var body: some View {
        NavigationView {
            
            VStack {
                customNavBar
                messagesView
                
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(chatUser: self.chatUser)
                }
            }
            .overlay(
                newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color(.label), lineWidth: 2))
                .shadow(radius: 5)
                
            VStack(alignment: .leading, spacing: 4) {
                Text("\(vm.chatUser?.username ?? "")")
                    .font(.system(size: 24, weight: .bold))
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 11)
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            Spacer()
            Button {
                shouldShowLogOut.toggle()
            } label: {
                Image(systemName: "gear")
                    .foregroundColor(Color(.label))
                    .font(.system(size: 24, weight: .bold))
            }
        }
        .padding(.vertical, 10).padding(.horizontal)
        .actionSheet(isPresented: $shouldShowLogOut) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("Handle sign out")
                    vm.handleSignOut()
                }),
//                        .default(Text("Default Button")),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
            })
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self){ num in
                VStack {
                    NavigationLink {
                        Text("Destination")
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1))
                            VStack(alignment: .leading) {
                                Text("username")
                                    .font(.system(size: 14, weight: .bold))
                                Text("message sent to user")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.lightGray))
                            }
                            Spacer()
                            Text("12d")
                                .font(.system(size: 14, weight: .semibold))
                        }.foregroundColor(Color(.label))
                    }
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
            }.padding(.top, 1)
        }.padding(.bottom, 46)
    }
    
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View {
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 5)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen, onDismiss: nil) {
            NewMessageView(didSelectNewUser: { user in
                self.chatUser = user
                self.shouldNavigateToChatLogView.toggle()
            })
        }
    }
    
    @State var chatUser: ChatUser?
}

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    var body: some View {
        ScrollView{
            ForEach(0..<10) { num in
                Text("Fake Message")
            }
        }.navigationTitle(chatUser?.username ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
//            .preferredColorScheme(.dark)
    }
}
