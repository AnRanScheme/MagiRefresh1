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
                startAnimation()
            } else {
                // 结束
                stopAnimation()
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
    
    /// action handler
    fileprivate var refreshHandler: RefreshHandler
    /// handler refresh !! must be UIView which conform to RefreshViewDelegate protocol
    fileprivate var refreshAnimator: MagiRefreshComponentDelegate
    /// header or footer
    fileprivate var refreshComponentType: MagiRefreshComponentType = .header
    /// to distinguish if is refreshing
    fileprivate var isRefreshing = false
    /// to distinguish if dragging begins
    fileprivate var isGestureBegin = false
    /// save scrollView's contentOffsetY when the footer should appear
    fileprivate var beginAnimatingOffsetY: CGFloat = 0
    
    fileprivate var insetTopDelta: CGFloat = 0
    /// 标注结束的动画是否执行完成
    fileprivate var isAnimating = false
    /// store it to reset scrollView' after animating
    fileprivate var scrollViewOriginalValue:(bounces: Bool, contentInsetTop: CGFloat, contentInsetBottom: CGFloat, contentOffset: CGPoint) = (false, 0.0, 0.0, CGPoint())
    /// superView
    fileprivate weak var scrollView: UIScrollView? {
        return self.superview as? UIScrollView
    }
    
    init<Animator: UIView>(frame: CGRect,
         refreshComponentType: MagiRefreshComponentType,
         refreshAnimator: Animator,
         refreshHandler: @escaping RefreshHandler)
        where Animator: MagiRefreshComponentDelegate {
            self.refreshComponentType = refreshComponentType
            self.refreshAnimator = refreshAnimator
            self.refreshHandler = refreshHandler
            super.init(frame: frame)
            // 添加刷新控件
            addSubview(refreshAnimator)
            /// needed 添加约束
            autoresizingMask = .flexibleWidth
            addConstraint()
            /// animator can prepare to do something 调用代理 准备的方法
            self.refreshAnimator.refreshComponentDidPrepare(self,
                                                            refreshComponentType: self.refreshComponentType)

            isHidden = refreshAnimator.isAutomaticlyHidden
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraint() {
        guard let refreshAnimatorView = refreshAnimator as? UIView else { return }
        let leading = NSLayoutConstraint(item: refreshAnimatorView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let top = NSLayoutConstraint(item: refreshAnimatorView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let trailing = NSLayoutConstraint(item: refreshAnimatorView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: refreshAnimatorView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        refreshAnimatorView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([leading, top, trailing, bottom])
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            // 移除kvo监听者
            // removeObserverOf(scrollView)
        }
        
        if let newScrollView = newSuperview as? UIScrollView {
            ///  can drag anytime 开启始终支持bounces
            newScrollView.alwaysBounceVertical = true
            // 添加kvo监听者
            // addObserverOf(newScrollView)
            // 记录scrollView初始的状态, 便于在执行完成之后恢复
            scrollViewOriginalValue = (newScrollView.bounces, newScrollView.contentInset.top, newScrollView.contentInset.bottom, newScrollView.contentOffset)
            if refreshComponentType == .footer {
                self.frame.origin.y = newScrollView.contentSize.height
            } else {
                self.frame.origin.y = -self.frame.size.height
            }
        }
    }
    
    deinit {
        // removeObserverOf(scrollView)
    }

}

extension MagiRefreshComponent {
    
    fileprivate func startAnimation() {
        guard let validScrollView = scrollView else { return }
        validScrollView.bounces = false
        isRefreshing = true
        
        DispatchQueue.main.async {[weak self] in
            guard let validSelf = self else { return }
            UIView.animate(withDuration: 0.25, animations: {
                if validSelf.refreshComponentType == .header {
                    validScrollView.contentInset.top = validSelf.scrollViewOriginalValue.contentInsetTop + validSelf.bounds.height
                } else {
                    let offPartHeight = validScrollView.contentSize.height - validSelf.heightOfContentOnScreenOfScrollView(scrollView: validScrollView)
                    /// contentSize改变的时候设置的self.y不同导致不同的结果
                    /// 所有内容高度>屏幕上显示的内容高度
                    let notSureBottom = validSelf.scrollViewOriginalValue.contentInsetBottom + validSelf.bounds.height
                    validScrollView.contentInset.bottom = offPartHeight>=0 ? notSureBottom : notSureBottom - offPartHeight // 加上
                }
                
            }, completion: { (_) in
                /// 这个时候才正式刷新
                validScrollView.bounces = true
                validSelf.isGestureBegin = false
                validSelf.magiRefreshState = .loading
                validSelf.refreshAnimator.refreshDidBegin(validSelf,refreshComponentType: validSelf.refreshComponentType)
                validSelf.refreshHandler()
            })
        }
    }
    
    fileprivate func stopAnimation() {
        
    }
    
    /// 显示在屏幕上的内容高度
    fileprivate func heightOfContentOnScreenOfScrollView(scrollView: UIScrollView) -> CGFloat {
        return scrollView.bounds.height - scrollView.contentInset.top - scrollView.contentInset.bottom
    }
}

extension MagiRefreshComponent {
    
    
}

