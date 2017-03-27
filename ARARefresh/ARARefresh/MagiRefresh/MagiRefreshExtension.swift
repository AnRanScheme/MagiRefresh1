//
//  MagiRefreshExtension.swift
//  ARARefresh
//
//  Created by 安然 on 17/3/24.
//  Copyright © 2017年 安然. All rights reserved.
//

import UIKit
import ObjectiveC

private var M_HeaderKey: UInt8 = 0
private var M_FooterKey: UInt8 = 0

// MARK: - 提供一些对外的方法
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


// MARK: - 关于UIScrollView的一些属性设置
extension UIScrollView {
    
    var m_insetTop: CGFloat {
        get { return contentInset.top }
        set {
            var inset = self.contentInset
            inset.top = newValue
            self.contentInset = inset
        }
    }
    
    var m_insetBottom: CGFloat {
        get { return contentInset.bottom }
        set {
            var inset = self.contentInset
            inset.bottom = newValue
            self.contentInset = inset
        }
    }
    
    var m_insetLeft: CGFloat {
        get { return contentInset.left }
        set {
            var inset = self.contentInset
            inset.left = newValue
            self.contentInset = inset
        }
    }
    
    var m_insetRight: CGFloat {
        get { return contentInset.right }
        set {
            var inset = self.contentInset
            inset.right = newValue
            self.contentInset = inset
        }
    }
    
    var m_offsetX: CGFloat {
        get { return contentOffset.x }
        set {
            var offset = self.contentOffset
            offset.x = newValue
            self.contentOffset = offset
        }
    }
    
    var m_offsetY: CGFloat {
        get { return contentOffset.y }
        set {
            var offset = self.contentOffset
            offset.y = newValue
            self.contentOffset = offset
        }
    }
    
    
    var m_contentWidth: CGFloat {
        get { return contentSize.width }
        set {
            var size = self.contentSize
            size.width = newValue
            self.contentSize = size
        }
    }
    
    var m_contentHeight: CGFloat {
        get { return contentSize.height }
        set {
            var size = self.contentSize
            size.height = newValue
            self.contentSize = size
        }
    }
    
}

extension UIView {
    
    var m_x: CGFloat {
        get { return frame.origin.x }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    var m_y: CGFloat {
        get { return frame.origin.y }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    var m_width: CGFloat {
        get { return frame.size.width }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var m_height: CGFloat {
        get { return frame.size.height }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    var m_size: CGSize {
        get { return frame.size }
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
    var m_origin: CGPoint {
        get { return frame.origin }
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
    
    var m_center: CGPoint {
        get { return CGPoint(x: (frame.size.width-frame.origin.x)*0.5, y: (frame.size.height-frame.origin.y)*0.5) }
        set {
            var frame = self.frame
            frame.origin = CGPoint(x: newValue.x - frame.size.width*0.5, y: newValue.y - frame.size.height*0.5)
            self.frame = frame
        }
    }
    
}
