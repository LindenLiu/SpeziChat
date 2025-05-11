//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziChat
import SwiftUI


struct ChatTestView: View {
    @State private var chat: Chat = [
        ChatEntity(role: .hidden(type: .unknown), content: "Hidden Message!"),
        ChatEntity(role: .assistant, content: "**Assistant** Message!")
    ]
    @State private var muted = true
    
    
    var body: some View {
        ChatView(
            $chat,
            exportFormat: .pdf,
            messagePendingAnimation: .automatic
        )
            .speak(chat, muted: muted)
            .speechToolbarButton(muted: $muted)
            .navigationTitle("SpeziChat")
            .padding(.top, 16)
            .onChange(of: chat) { _, newValue in
                // Append a new assistant message to the chat after sleeping for 5 seconds.
                if newValue.last?.role == .user {
                    Task {
                        try await Task.sleep(for: .seconds(3))
                        
                        if newValue.last?.content == "Call some function" {
                            await MainActor.run {
                                chat.append(.init(role: .assistantToolCall, content: "call_test_func({ test: true })"))
                            }
                            try await Task.sleep(for: .seconds(1))
                            
                            await MainActor.run {
                                chat.append(.init(role: .assistantToolResponse, content: "{ some: response }"))
                              chat.append(.init(role: .user, content: "Markdown image: ![picnic](https://photos.tryotter.com/cdn-cgi/image/fit=crop,width=80,height=60,quality=60,format=auto/menu-photos/ea4dd323-b90e-47c8-abd4-07fe54e95956.jpeg)"))
                            }
                            try await Task.sleep(for: .seconds(1))
                        }
                        
                        await MainActor.run {
                            chat.append(.init(role: .assistant, content: "**Assistant** Message Response!"))
                        }
                    }
                }
            }
    }
}


#if DEBUG
#Preview {
    ChatTestView()
}
#endif
