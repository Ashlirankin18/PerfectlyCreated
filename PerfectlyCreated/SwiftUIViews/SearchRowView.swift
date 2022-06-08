//
//  SearchRowView.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 6/7/22.
//  Copyright © 2022 Ashli Rankin. All rights reserved.
//

import SwiftUI

struct SearchRowView: View {
    
    let name: String
    let category: String
    let imageURL: URL?
   
    var body: some View {
        ZStack {
            Color.white
                .clipShape(RoundedRectangle(cornerRadius: 12))
            HStack {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } placeholder: {
                    Image("placeholderProduct")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(name)
                        .font(.headline)
                        .lineLimit(2)
                    Text(category)
                        .font(.caption)
                }
                Spacer()
                Button {
                
                } label: {
                    Image(systemName: "suit.heart")
                        .font(.headline)
                }
            }
            .padding(8)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

struct SearchRowView_Previews: PreviewProvider {
    static var previews: some View {
        SearchRowView(name: "", category: "", imageURL: nil)
    }
}
