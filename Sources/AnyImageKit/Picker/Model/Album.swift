//
//  Album.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import Photos

class Album: IdentifiableResource {
    
    let fetchResult: PHFetchResult<PHAsset>
    
    let identifier: String
    let title: String
    let isUserLibrary: Bool
    private(set) var assets: [AssetOld] = []
    
    init(fetchResult: PHFetchResult<PHAsset>, identifier: String, title: String?, isCameraRoll: Bool, selectOptions: MediaSelectOption) {
        self.fetchResult = fetchResult
        self.identifier = identifier
        self.title = title ?? ""
        self.isUserLibrary = isCameraRoll
        fetchAssets(result: fetchResult, selectOptions: selectOptions)
    }
}

extension Album {
    
    private func fetchAssets(result: PHFetchResult<PHAsset>, selectOptions: MediaSelectOption) {
        var array: [AssetOld] = []
        let selectPhoto = selectOptions.contains(.photo)
        let selectVideo = selectOptions.contains(.video)
        let selectPhotoGIF = selectOptions.contains(.photoGIF)
        let selectPhotoLive = selectOptions.contains(.photoLive)
        
        for phAsset in result.objects() {
            let asset = AssetOld(idx: array.count, asset: phAsset, selectOptions: selectOptions)
            switch asset.mediaType {
            case .photo:
                if selectPhoto {
                    array.append(asset)
                }
            case .video:
                if selectVideo {
                    array.append(asset)
                }
            case .photoGIF:
                if selectPhotoGIF {
                    array.append(asset)
                }
            case .photoLive:
                if selectPhotoLive {
                    array.append(asset)
                }
            }
        }
        assets = array
    }
}

// MARK: - Capture
extension Album {
    
    func insertAsset(_ asset: AssetOld, at: Int, sort: Sort) {
        assets.insert(asset, at: at)
        reloadIndex(sort: sort)
    }
    
    func addAsset(_ asset: AssetOld, atLast: Bool) {
        if atLast {
            assets.append(asset)
        } else {
            assets.insert(asset, at: assets.count-1)
        }
    }
    
    private func reloadIndex(sort: Sort) {
        var idx = 0
        let array: [AssetOld]
        switch sort {
        case .asc:
            array = Array(assets[0..<assets.count-1])
        case .desc:
            array = Array(assets[1..<assets.count])
        }
        for asset in array {
            asset.idx = idx
            idx += 1
        }
    }
}

extension Album {
    
    var count: Int {
        if hasCamera {
            return assets.count - 1
        } else {
            return assets.count
        }
    }
    
    var hasCamera: Bool {
        return false
//        return (assets.first?.isCamera ?? false) || (assets.last?.isCamera ?? false)
    }
}

extension Album: CustomStringConvertible {
    
    var description: String {
        return "Album<\(title)>"
    }
}
