//
//  scrollView+magi.swift
//  ARARefresh
//
//  Created by 安然 on 17/3/27.
//  Copyright © 2017年 安然. All rights reserved.
//

import UIKit

private var M_HeaderKey: UInt8 = 0
private var M_FooterKey: UInt8 = 0

extension UIScrollView {
    
    public typealias RefreshHandler = () -> Void
    /// 下拉刷新
    private var m_refreshHeader: MagiRefreshComponent? {
        set {
            objc_setAssociatedObject(self, &M_HeaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &M_HeaderKey) as? MagiRefreshComponent
        }
    }
    
    /// 上拉刷新
    private var m_refreshFooter: MagiRefreshComponent? {
        set {
            objc_setAssociatedObject(self, &M_FooterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &M_FooterKey) as? MagiRefreshComponent
        }
    }
    
    /**
     添加下拉刷新
     
     - parameter headerAnimator: 下拉刷新控件 -- 继承自UIView同时遵守RefreshViewDelegate
     - parameter refreshHandler: 处理刷新过程的闭包
     */
    public func m_addRefreshHeader<Animator>(headerAnimator: Animator, refreshHandler: @escaping RefreshHandler ) where Animator: UIView, Animator: MagiRefreshComponentDelegate {
        
        if let header = m_refreshHeader {
            header.removeFromSuperview()
        }
        /// 设置frame --- 注意是添加到scrollView的顶部的外面--- 即 y = -headerAnimator.bounds.height
        let frame = CGRect(x: 0.0, y: -headerAnimator.bounds.height, width: bounds.width, height: headerAnimator.bounds.height)
        m_refreshHeader = MagiRefreshComponent(frame: frame, refreshComponentType: .header, refreshAnimator: headerAnimator, refreshHandler: refreshHandler)
        addSubview(m_refreshHeader!)
        
    }
    
    /**
     添加上拉刷新
     
     - parameter footerAnimator: 上拉刷新控件 -- 继承自UIView同时遵守RefreshViewDelegate
     - parameter refreshHandler: 处理刷新过程的闭包
     */
    public func m_addRefreshFooter<Animator>(footerAnimator: Animator, refreshHandler: @escaping RefreshHandler ) where Animator: UIView, Animator: MagiRefreshComponentDelegate {
        if let footer = m_refreshFooter {
            footer.removeFromSuperview()
        }
        /// this may not the final position
        let frame = CGRect(x: 0.0, y: contentSize.height, width: bounds.width, height: footerAnimator.bounds.height)
        m_refreshFooter = MagiRefreshComponent(frame: frame,
                                               refreshComponentType: .footer,
                                               refreshAnimator: footerAnimator,
                                               refreshHandler: refreshHandler)
        addSubview(m_refreshFooter!)
    }
    
    /// 开启header刷新
    public func m_startHeaderAnimation() {
        m_refreshHeader?.canBegin = true
    }
    /// 结束header刷新
    public func m_stopHeaderAnimation() {
        m_refreshHeader?.canBegin = false
    }
    /// 开启footer刷新
    public func m_startFooterAnimation() {
        m_refreshFooter?.canBegin = true
    }
    /// 结束footer刷新
    public func m_stopFooterAnimation() {
        m_refreshFooter?.canBegin = false
    }
    
}
