//
//  HairProductModel.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/18/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import Foundation

struct AllHairProducts: Codable, Hashable {
  let id: String
  let results: HairProductDetails
}

struct HairProductDetails: Codable, Hashable {
    
  let gtins: [String]
  let upc: String
  let created_at: Int
  let name: String
  let images: [URL]
  let sitedetails: [SiteDetails]
  let description: String
  let features: Features?
  let category: String
}

struct SiteDetails: Codable, Hashable {
  let url: URL
  let latestoffers: [LatestOffers]
}

struct Features: Codable, Hashable {
  let blob: String?
}

struct LatestOffers: Codable, Hashable {
  let price: String
  let lastrecorded_at: Int
  let isActive: Int?
  let currency: String
  let firstrecorded_at: Int
  let id: String
  let avalibility: String?
  let seller: String
}
