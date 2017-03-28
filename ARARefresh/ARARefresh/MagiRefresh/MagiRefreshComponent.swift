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
            return UserDefaults.standard.object(forKey: lastRefreshTimeKey
                ?? MagiRefreshComponent.ConstantValue.commonRefreshTimeKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: lastRefreshTimeKey
                ?? MagiRefreshComponent.ConstantValue.commonRefreshTimeKey)
            UserDefaults.standard.synchronize()
        }
    }
    public var lastRefreshTimeKey: String? {
        return nil
    }
    
    
    /// optional 两个可选方法的实现
    public func refreshComponentDidPrepare(_ refreshComponent: MagiRefreshComponent,
                                           refreshComponentType: MagiRefreshComponentType) { }
    public func refreshDidChangeProgress(_ refreshComponent: MagiRefreshComponent,
                                         progress: CGFloat,
                                         refreshComponentType: MagiRefreshComponentType) { }
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
    
    typealias RefreshHandler = () -> Void
    
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
    fileprivate var refreshState: MagiRefreshState = .normal {
        didSet {
            if refreshState == .normal {
                isHidden = refreshAnimator.isAutomaticlyHidden
            } else {
                isHidden = false
            }
            
            if refreshState != oldValue {
                if refreshState == .loading {
                    refreshAnimator.lastRefreshTime = Date()
                }
                refreshAnimator.refreshDidChangeState(self,
                                                      fromState: oldValue,
                                                      toState: refreshState,
                                                      refreshComponentType: refreshComponentType)
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
        let leading = NSLayoutConstraint(item: refreshAnimatorView,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 0.0)
        let top = NSLayoutConstraint(item: refreshAnimatorView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: self,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 0.0)
        let trailing = NSLayoutConstraint(item: refreshAnimatorView,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: self,
                                          attribute: .trailing,
                                          multiplier: 1.0,
                                          constant: 0.0)
        let bottom = NSLayoutConstraint(item: refreshAnimatorView,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: self,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 0.0)
        refreshAnimatorView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([leading, top, trailing, bottom])
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            // 移除kvo监听者
            removeObserver(scrollView)
        }
        
        if let newScrollView = newSuperview as? UIScrollView {
            ///  can drag anytime 开启始终支持bounces
            newScrollView.alwaysBounceVertical = true
            // 添加kvo监听者
            addObserver(newScrollView)
            // 记录scrollView初始的状态, 便于在执行完成之后恢复
            scrollViewOriginalValue = (newScrollView.bounces,
                                       newScrollView.contentInset.top,
                                       newScrollView.contentInset.bottom,
                                       newScrollView.contentOffset)
            if refreshComponentType == .footer {
                self.frame.origin.y = newScrollView.contentSize.height
            } else {
                self.frame.origin.y = -self.frame.size.height
            }
        }
    }
    
    deinit {
        removeObserver(scrollView)
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
                    let offPartHeight = validScrollView.contentSize.height - validSelf.heightOfContentOnScreenOfScrollView(validScrollView)
                    /// contentSize改变的时候设置的self.y不同导致不同的结果
                    /// 所有内容高度 > 屏幕上显示的内容高度
                    let notSureBottom = validSelf.scrollViewOriginalValue.contentInsetBottom + validSelf.bounds.height
                    validScrollView.contentInset.bottom =
                                          offPartHeight >= 0
                                                        ? notSureBottom
                                                        : notSureBottom - offPartHeight // 加上
                }
                
            }, completion: { (_) in
                /// 这个时候才正式刷新
                validScrollView.bounces = true
                validSelf.isGestureBegin = false
                validSelf.refreshState = .loading
                validSelf.refreshAnimator.refreshDidBegin(validSelf,refreshComponentType: validSelf.refreshComponentType)
                validSelf.refreshHandler()
            })
        }
    }
    
    fileprivate func stopAnimation() {
        guard let validScrollView = scrollView else { return }
        if !isRefreshing { return }
        isRefreshing = false
        isAnimating = true
        
        // print("endAnimation ---    \(self.scrollViewOriginalValue.contentInsetTop)")
        
        DispatchQueue.main.async {[weak self] in
            guard let validSelf = self else { return }
            
            UIView.animate(withDuration: 0.25, animations: {
                if validSelf.refreshComponentType == .header {
                    validScrollView.contentInset.top += validSelf.insetTopDelta;
                } else {
                    validScrollView.contentInset.bottom = validSelf.scrollViewOriginalValue.contentInsetBottom
                }
                
            }, completion: { (_) in
                
                // refresh end
                validScrollView.bounces = validSelf.scrollViewOriginalValue.bounces
                
                
                print("endAnimation ---    \(String(describing: self!.scrollView?.contentInset.top))")
                
                validSelf.isAnimating = false
                validSelf.refreshAnimator.refreshDidChangeProgress(validSelf,
                                                                   progress: 1.0,
                                                                   refreshComponentType: validSelf.refreshComponentType)
                validSelf.refreshAnimator.refreshDidEnd(validSelf,
                                                        refreshComponentType: validSelf.refreshComponentType)
                validSelf.refreshState = .normal
                validSelf.isHidden = validSelf.refreshAnimator.isAutomaticlyHidden
            })
        }
    }
    
}

extension MagiRefreshComponent {
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &ConstantValue.RefreshViewContext {
            
            if keyPath == ConstantValue.ScrollViewContentSizePath {
                
                guard let validScrollView = scrollView,
                    let oldSize = (change?[.oldKey] as AnyObject).cgSizeValue,
                    let newSize = (change?[.newKey] as AnyObject).cgSizeValue,
                    (oldSize != newSize) && (refreshComponentType == .footer)
                    else { return }
                // print("-------\(heightOfContentOnScreenOfScrollView(validScrollView))")
                /// 设置刷新控件self的位置
                let contentOnScreenHeight = heightOfContentOnScreenOfScrollView(validScrollView)
                /// 添加在scrollView"外面"
                // 当scrollView的内容总高度 < scrollView的高度的时候, 设置为contentOnScreenHeight
                self.frame.origin.y = max(newSize.height, contentOnScreenHeight)
                //                print("old--*\(oldSize.height)--------*\(newSize.height)")
                
            } else if keyPath == ConstantValue.ScrollViewContentOffsetPath {
                if let validScrollView = scrollView, object as? UIScrollView == validScrollView {
                    //                    print(validScrollView.contentInset.top);
                    if refreshComponentType == .header {
                        adjustHeaderWhenScrollViewIsScrolling(scrollView: validScrollView)
                    } else {
                        adjustFooterWhenScrollViewIsScrolling(scrollView: validScrollView)
                    }
                }
            } else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
            
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    fileprivate func adjustFooterWhenScrollViewIsScrolling(scrollView: UIScrollView) {
        
        if isRefreshing || isAnimating {/**正在刷新直接返回*/ return }
        
        scrollViewOriginalValue.contentInsetBottom = scrollView.contentInset.bottom
        if scrollView.panGestureRecognizer.state == .began {// 手势拖拽才能进入下拉状态
            isGestureBegin = true
            /// 计算将出现的OffsetY
            beginAnimatingOffsetY = frame.origin.y - scrollView.bounds.height
            
            isHidden = false
            return
        }
        
        if !isGestureBegin {/**没有拖拽直接返回*/ return }
        
        // 还未出现
        if scrollView.contentOffset.y < beginAnimatingOffsetY {/**底部视图(隐藏)并且还没到显示的临界点*/ return }
        // 计算出现的比例
        let progress = (scrollView.contentOffset.y - beginAnimatingOffsetY) / self.bounds.height
        // 处理状态的改变 -- 和 下拉刷新完全一样
        adjustRefreshViewWithProgress(progress: progress, scrollView: scrollView)
        
    }
    
    
    fileprivate func adjustHeaderWhenScrollViewIsScrolling(scrollView: UIScrollView) {
        if isRefreshing {/**正在刷新直接返回*/
            
            if self.window == nil {
                return
            }
            /// 需要处理这个时候滚动时sectionHeader悬停的问题
            /// 参照MJRefresh
            var insetsTop: CGFloat = 0
            if scrollView.contentOffset.y > -scrollViewOriginalValue.contentInsetTop {
                insetsTop = scrollViewOriginalValue.contentInsetTop
            } else {
                insetsTop = -scrollView.contentOffset.y
            }
            
            insetsTop = min(scrollViewOriginalValue.contentInsetTop + self.bounds.height, insetsTop)
            scrollView.contentInset.top = insetsTop
            insetTopDelta = scrollViewOriginalValue.contentInsetTop - insetsTop;
            //            print("--------******   \(scrollView.contentInset.top)")
            return
        }
        /// 刷新状态的时候不能记录为原始的
        if isAnimating {/**stop动画还未执行完成*/ return }
        /// 不在刷新状态的时候都随时记录原始的contentInset
        
        scrollViewOriginalValue.contentInsetTop = scrollView.contentInset.top
        if scrollView.panGestureRecognizer.state == .began {// 手势拖拽才能进入下拉状态
            isGestureBegin = true
            isHidden = false
            return
        }
        
        
        if !isGestureBegin {/**没有拖拽直接返回*/ return }
        
        
        //        print("\(scrollView.contentOffset.y)------*\(-scrollViewOriginalValue.contentInset.top)")
        if scrollView.contentOffset.y > -scrollViewOriginalValue.contentInsetTop {/**头部视图(隐藏)并且还没到显示的临界点*/ return }
        
        // 已经进入拖拽状态, 刷新控件将出现 进行相关操作
        let progress = (-scrollViewOriginalValue.contentInsetTop - scrollView.contentOffset.y) / self.bounds.height
        
        adjustRefreshViewWithProgress(progress: progress,
                                      scrollView: scrollView)
    }
    
    fileprivate func adjustRefreshViewWithProgress(progress: CGFloat, scrollView: UIScrollView) {
        
        //        print(progress)
        
        if scrollView.isTracking {
            if progress >= 1.0 {
                refreshState = .releaseToFresh
            } else if progress <= 0.0 {
                refreshState = .normal
            } else {
                refreshState = .pullToRefresh
            }
        } else if refreshState == .releaseToFresh {
            // releaseToFreah 2 refresh
            canBegin = true
            // begin refresh
        } else {// release
            if progress <= 0.0 {
                refreshState = .normal
            }
        }
        
        var actualProgress = min(1.0, progress)
        actualProgress = max(0.0, actualProgress)
        refreshAnimator.refreshDidChangeProgress(self,
                                                 progress: actualProgress,
                                                 refreshComponentType: refreshComponentType)
    }
    
    /// 显示在屏幕上的内容高度
    
    fileprivate func heightOfContentOnScreenOfScrollView( _ scrollView:UIScrollView) -> CGFloat {
        return scrollView.bounds.height - scrollView.contentInset.top - scrollView.contentInset.bottom
    }
    
    fileprivate func addObserver( _ scrollView: UIScrollView?) {
        scrollView?.addObserver(self,
                                forKeyPath: ConstantValue.ScrollViewContentOffsetPath,
                                options: .initial,
                                context: &ConstantValue.RefreshViewContext)
        
        scrollView?.addObserver(self,
                                forKeyPath: ConstantValue.ScrollViewContentSizePath,
                                options: [.old, .new],
                                context: &ConstantValue.RefreshViewContext)
    }
    
    fileprivate func removeObserver( _ scrollView: UIScrollView?) {
        scrollView?.removeObserver(self,
                                   forKeyPath: ConstantValue.ScrollViewContentOffsetPath,
                                   context: &ConstantValue.RefreshViewContext)
        
        scrollView?.removeObserver(self,
                                   forKeyPath: ConstantValue.ScrollViewContentSizePath,
                                   context: &ConstantValue.RefreshViewContext)
    }

    
}

