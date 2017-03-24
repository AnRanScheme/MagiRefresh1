//
//  MagiRefreshConstant.swift
//  ARARefresh
//
//  Created by 安然 on 17/3/24.
//  Copyright © 2017年 安然. All rights reserved.
//

import Foundation

class MagiRefreshConstant {
    static let slowAnimationDuration: TimeInterval = 0.4
    static let fastAnimationDuration: TimeInterval = 0.25
    
    static let keyPathContentOffset: String = "contentOffset"
    static let keyPathContentInset: String = "contentInset"
    static let keyPathContentSize: String = "contentSize"
    static let keyPathPanState: String = "state"
    
    static var associatedObjectMagiHeader = 0
    static var associatedObjectMagiFooter = 1
}

public func MagiLocalize(_ string:String)->String{
    return NSLocalizedString(string,
                             tableName: "Localize",
                             bundle: Bundle(for: MagiHeader.self),
                             value: "",
                             comment: "")
}

public struct MagiHeaderString{
    static public let pullDownToRefresh = MagiLocalize("pullDownToRefresh")
    static public let releaseToRefresh = MagiLocalize("releaseToRefresh")
    static public let refreshSuccess = MagiLocalize("refreshSuccess")
    static public let refreshFailure = MagiLocalize("refreshFailure")
    static public let refreshing = MagiLocalize("refreshing")
}

public struct MagiFooterString{
    static public let pullUpToRefresh = MagiLocalize("pullUpToRefresh")
    static public let loadding = MagiLocalize("loadMore")
    static public let noMoreData = MagiLocalize("noMoreData")
    static public let releaseLoadMore = MagiLocalize("releaseLoadMore")
    static public let scrollAndTapToRefresh = MagiLocalize("scrollAndTapToRefresh")
}
