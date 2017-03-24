//
//  MagiRefreshComponent.swift
//  ARARefresh
//
//  Created by 安然 on 17/3/24.
//  Copyright © 2017年 安然. All rights reserved.
//

import UIKit

/// 下拉状态枚举
///
/// - loading: 正在加载状态
/// - normal: 正常状态
/// - pullToRefresh: 下拉状态
/// - releaseToFresh: 松开手即进入刷新状态
/// - noMoreData: 没有数据
public enum MagiRefreshState{
    case loading
    case normal
    case pullToRefresh
    case releaseToFresh
    case noMoreData
}

public enum MagiRefreshComponentType {
    case header, footer
}

public protocol MagiRefreshComponentDelegate {
    /// 要为每一个header或者footer设置一个不同的key来保存时间, 否则将公用同一个key使用相同的时间
    var lastRefreshTimeKey: String? { get }
    /// 是否刷新完成后自动隐藏 默认为false
    var isAutomaticlyHidden: Bool { get }
    /// 上次刷新时间, 有默认赋值和返回
    var lastRefreshTime: Date? { get set }
    
    
    /// repuired 三个必须实现的代理方法
    /// 开始进入刷新(loading)状态, 这个时候应该开启自定义的(动画)刷新
    func refreshDidBegin(_ refreshComponent: MagiRefreshComponent, refreshComponentType: MagiRefreshComponentType)
    
    /// 刷新结束状态, 这个时候应该关闭自定义的(动画)刷新
    func refreshDidEnd(_ refreshComponent: MagiRefreshComponent, refreshComponentType: MagiRefreshComponentType)
    
    /// 刷新状态变为新的状态, 这个时候可以自定义设置各个状态对应的属性
    func refreshDidChangeState(_ refreshComponent: MagiRefreshComponent, fromState: MagiRefreshState, toState: MagiRefreshState, refreshComponentType: MagiRefreshComponentType)
    
    
    /// optional 两个可选的实现方法
    /// 允许在控件添加到scrollView之前的准备
    func refreshComponentDidPrepare(_ refreshComponent: MagiRefreshComponent, refreshComponentType: MagiRefreshComponentType)
    
    /// 拖拽的进度, 可用于自定义实现拖拽过程中的动画
    func refreshDidChangeProgress(_ refreshComponent: MagiRefreshComponent, progress: CGFloat, refreshComponentType: MagiRefreshComponentType)
}

/// default doing
extension MagiRefreshComponentDelegate {
    
    /// 属性
    public var isAutomaticlyHidden: Bool { return false }
    public var lastRefreshTime: Date? {
        get {
            return UserDefaults.standard.object(forKey: lastRefreshTimeKey ?? MagiRefreshComponent.ConstantValue.commonRefreshTimeKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: lastRefreshTimeKey ?? MagiRefreshComponent.ConstantValue.commonRefreshTimeKey)
            UserDefaults.standard.synchronize()
        }
    }
    public var lastRefreshTimeKey: String? {
        return nil
    }
    
    
    /// optional 两个可选方法的实现
    public func refreshComponentDidPrepare(_ refreshComponent: MagiRefreshComponent, refreshComponentType: MagiRefreshComponentType) { }
    public func refreshDidChangeProgress(_ refreshComponent: MagiRefreshComponent, progress: CGFloat, refreshComponentType: MagiRefreshComponentType) { }
}

open class MagiRefreshComponent: UIView {
    
    /// KVO Constant
    struct ConstantValue {
        static var RefreshViewContext: UInt8 = 0
        static let ScrollViewContentOffsetPath = "contentOffset"
        static let ScrollViewContentSizePath = "contentSize"
        static let commonRefreshTimeKey = "magiCommonRefreshTimeKey"
        static let LastRefreshTimeKey = ProcessInfo().globallyUniqueString
    }
    
    ///
    typealias RefreshHandler = (Void) -> Void
    
    // MARK: - internal property
    var canBegin = false {
        didSet {
            if canBegin == oldValue { return }
            if canBegin {
                // 开始
                // startAnimation()
            } else {
                // 结束
                // stopAnimation()
            }
        }
    }
    
    // MARK: - private property
    fileprivate var magiRefreshState: MagiRefreshState = .normal {
        didSet {
            if magiRefreshState == .normal {
                //isHidden = refreshAnimator.isAutomaticlyHidden
            } else {
                isHidden = false
            }
            
            if magiRefreshState != oldValue {
                if magiRefreshState == .loading {
                    // refreshAnimator.lastRefreshTime = Date()
                } else {
                    // refreshAnimator.refreshDidChangeState(self, fromState: oldValue, toState: refreshViewState, refreshViewType: refreshViewType)
                }
            }
        }
    }

}
