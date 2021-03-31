//
//  PromptDisplayView.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 3/29/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import SwiftUI

struct PromptDisplayView: View {
    
    var displayText: String
    
    var addButtonTapped: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            Text(displayText)
                .foregroundColor(.black)
            Button(action: {
                addButtonTapped?()
            }, label: {
                Text("Select another image")
            })
            .frame(width: 200, height: 48, alignment: .center)
            .foregroundColor(.white)
            .background(Color(.appPurple))
            .clipShape(Capsule())
        }
    }
}

struct PromptDispllayView_Previews: PreviewProvider {
    static var previews: some View {
        PromptDisplayView(displayText: "Display Text goes here")
    }
}
