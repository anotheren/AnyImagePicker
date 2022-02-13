//
//  UserInteractionResult.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2022/1/20.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Foundation

public enum UserInteractionResult<Result> {
    
    case interaction(Result)
    case cancel
}

extension UserInteractionResult {
    
    public var result: Result? {
        switch self {
        case .interaction(let result):
            return result
        case .cancel:
            return nil
        }
    }
}
