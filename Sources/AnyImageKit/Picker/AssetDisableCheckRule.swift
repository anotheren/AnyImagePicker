//
//  AssetDisableCheckRule.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/11/17.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import Photos

public protocol AssetDisableCheckRule {
    
    func isDisable(for asset: Asset<PHAsset>) -> Bool
    func alertMessage(for asset: Asset<PHAsset>) -> String
}

public struct VideoDurationDisableCheckRule: AssetDisableCheckRule {
    
    public let minDuration: TimeInterval
    public let maxDuration: TimeInterval
    
    public init(min: TimeInterval, max: TimeInterval) {
        self.minDuration = min
        self.maxDuration = max
    }
    
    public func isDisable(for asset: Asset<PHAsset>) -> Bool {
        guard asset.mediaType.isVideo else { return false }
        return asset.phAsset.duration < minDuration || asset.phAsset.duration > maxDuration
    }
    
    public func alertMessage(for asset: Asset<PHAsset>) -> String {
        let message = BundleHelper.localizedString(key: "DURATION_OF_SELECTED_VIDEO_RANGE", module: .picker)
        return String(format: message, arguments: [Int(minDuration), Int(maxDuration)])
    }
}