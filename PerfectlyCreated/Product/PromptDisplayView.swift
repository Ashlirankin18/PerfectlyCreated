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
    
    var body: some View {
        Text(displayText)
    }
}

struct PromptDispllayView_Previews: PreviewProvider {
    static var previews: some View {
        PromptDisplayView(displayText: "Display Text goes here")
    }
}
