//
//  EditorRotationDirection.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/3.
//  Copyright © 2021 AnyImageProject.org. All rights reserved.
//

import Foundation

public enum EditorRotationDirection {
    
    /// Turn off rotation feature
    case none
    
    /// Turn left
    case turnLeft
    
    /// Turn right
    case turnRight
}

extension EditorRotationDirection {
    
    var imageName: String {
        switch self {
        case .none:
            return ""
        case .turnLeft:
            return "PhotoToolCropTrunLeft"
        case .turnRight:
            return "PhotoToolCropTrunRight"
        }
    }
}