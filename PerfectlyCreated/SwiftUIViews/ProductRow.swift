//
//  ProductRow.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 6/7/22.
//  Copyright © 2022 Ashli Rankin. All rights reserved.
//

import SwiftUI

struct ProductRow: View {
    
    let name: String
    let category: String
    let imageURL: URL?
    
    var body: some View {
        ZStack(alignment: .center) {
            Color(uiColor: UIColor(named: "appBlue")!)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .center, spacing: 8) {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .frame(width: 140, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } placeholder: {
                    Image("placeholderProduct")
                        .resizable()
                        .frame(width: 140, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.headline)
                        .lineLimit(2)
                    Text(category)
                        .font(.caption)
                }
            }
            .padding(8)
            Spacer()
        }
        .padding()
        
    }
}

struct ProductRow_Previews: PreviewProvider {
    static var previews: some View {
        ProductRow(name: "", category: "", imageURL: nil)
    }
}
