//
//  CelebrationView.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 3/30/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import SwiftUI
import ConfettiView

struct CelebrationView: View {
    
    @State var isShowingConfetti: Bool = true
    
    private var timeLimit: TimeInterval
    
    @State private var timer = Timer.publish(every: 0.0, on: .main, in: .common).autoconnect()
    
    private let backButtonTapped: (() -> Void)?
    
    init(backButtonTapped: @escaping (() -> Void), timeLimit: TimeInterval = 8.0) {
        self.timeLimit = timeLimit
        self.backButtonTapped = backButtonTapped
        NotificationCenter.default.post(name: Notification.Name.playConfettiCelebration, object: Bool.self)
    }
    
    var body: some View {
        
        let confetti = ConfettiView(confetti: [
            .shape(.circle, .appPurple),
            .shape(.square, .gray)
        ])
        .transition(.slowFadeOut)
        
        return NavigationView {
            ZStack {
            if isShowingConfetti {
                    confetti
                VStack {
                    Text("Thank you for helping the community 🙂. Your contribution helps other users find products they may use also 🙂 .")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    Spacer()
                }
            } else {
                EmptyView()
            }
        }
        .navigationBarItems(leading: Button(action: {
            backButtonTapped?()
        }, label: {
            Image(systemName: "multiply")
                .foregroundColor(.white)
        }))
        }.onReceive(NotificationCenter.default.publisher(for: Notification.Name.playConfettiCelebration)) { _ in
            self.resetTimerAndPlay()
        }
    }
    
    private func resetTimerAndPlay() {
        timer = Timer.publish(every: self.timeLimit, on: .main, in: .common).autoconnect()
        isShowingConfetti = true
    }
}

public extension Notification.Name {
    static let playConfettiCelebration = Notification.Name("play_confetti_celebration")
}

extension AnyTransition {
    static var slowFadeOut: AnyTransition {
        let insertion = AnyTransition.opacity
        let removal = AnyTransition.opacity.animation(.easeOut(duration: 1.5))
        return .asymmetric(insertion: insertion, removal: removal)
    }
    
    static var slowFadeIn: AnyTransition {
        let insertion = AnyTransition.opacity.animation(.easeIn(duration: 1.5))
        let removal = AnyTransition.opacity
        return .asymmetric(insertion: insertion, removal: removal)
    }
}
