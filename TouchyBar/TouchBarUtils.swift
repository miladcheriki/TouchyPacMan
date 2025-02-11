//
//  TouchBarUtils.swift
//  TouchyBar
//
//  Created by Milad Cheriki on 1/30/25.
//

import Foundation

func hasTouchBar() -> Bool {
    // Get the Mac's model identifier
    var size = 0
    sysctlbyname("hw.model", nil, &size, nil, 0)
    var model = [CChar](repeating: 0, count: size)
    sysctlbyname("hw.model", &model, &size, nil, 0)
    let modelIdentifier = String(cString: model)
    
    // List of MacBook models with Touch Bars
    let touchBarModels = [
        "MacBookPro15,1", // 2018 MacBook Pro 13"
        "MacBookPro15,2", // 2018 MacBook Pro 13"
        "MacBookPro15,3", // 2018 MacBook Pro 15"
        "MacBookPro15,4", // 2019 MacBook Pro 13"
        "MacBookPro16,1", // 2019 MacBook Pro 16"
        "MacBookPro16,2", // 2019 MacBook Pro 13"
        "MacBookPro16,3", // 2020 MacBook Pro 13"
        "MacBookPro16,4", // 2020 MacBook Pro 16"
        "MacBookPro17,1", // 2020 MacBook Pro 13" (M1)
        "MacBookPro18,1", // 2021 MacBook Pro 14" (M1 Pro/Max)
        "MacBookPro18,2", // 2021 MacBook Pro 16" (M1 Pro/Max)
        "MacBookPro18,3", // 2021 MacBook Pro 14" (M1 Pro/Max)
        "MacBookPro18,4", // 2021 MacBook Pro 16" (M1 Pro/Max)
    ]
    
    // Check if the model identifier is in the list
    return touchBarModels.contains(modelIdentifier)
}
