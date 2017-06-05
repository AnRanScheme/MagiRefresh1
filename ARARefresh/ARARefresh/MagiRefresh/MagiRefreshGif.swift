//
//  MagiRefreshGif.swift
//  ARARefresh
//
//  Created by 安然 on 2017/3/29.
//  Copyright © 2017年 安然. All rights reserved.
//

import UIKit

class MagiRefreshGif: UIView {
   /** 
    *  为不同的state设置不同的图片
    *  闭包需要返回一个元组: 图片数组和gif动画每一帧的执行时间
    *  一般需要设置loading状态的图片(必须), 作为加载的gif
    *  和pullToRefresh状态的图片数组(可选择设置), 作为拖拽时的加载动画
   **/
    typealias SetImagesForStateClosure = (_ refreshState: MagiRefreshState) -> (images:[UIImage], duration:Double)?
    /// 为header或者footer的不同的state设置显示的文字
    typealias SetDescriptionClosure = (_ refreshState: MagiRefreshState, _ refreshType: MagiRefreshComponentType) -> String
    /// 设置显示上次刷新时间的显示格式
    typealias SetLastTimeClosure = (_ date: Date) -> String
}
