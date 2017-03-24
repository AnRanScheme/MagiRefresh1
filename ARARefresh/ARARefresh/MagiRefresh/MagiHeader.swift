//
//  MagiHeader.swift
//  ARARefresh
//
//  Created by 安然 on 17/3/24.
//  Copyright © 2017年 安然. All rights reserved.
//

import UIKit

class MagiHeader: UIView {

    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "arrow_down")
        iv.m_size = CGSize(width: 36, height: 36)
        return iv
    }()
    
    lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = false
        indicator.isHidden = false
        indicator.sizeToFit()
        indicator.m_size = CGSize(width: 40, height: 40)
        return indicator
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "下拉刷新"
        label.font = UIFont(name: "Helvetica Neue", size: 15.0)
        label.sizeToFit()
        return label
    }()
    
    lazy var lastTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "上次刷新的时间: 18:40"
        label.font = UIFont(name: "Helvetica Neue", size: 15.0)
        label.sizeToFit()
        return label
    }()
    
    public typealias SetDescriptionClosure = (_ refreshState: MagiRefreshState, _ refreshComponentType: MagiRefreshComponentType) -> String
    
    public typealias SetLastTimeClosure = (_ date: Date) -> String
    
    fileprivate var setupDesctiptionClosure: SetDescriptionClosure?
    
    fileprivate var setupLastTimeClosure: SetLastTimeClosure?
    
    /// 是否刷新完成后自动隐藏 默认为false
    /// 这个属性是协议定义的, 当写在class里面可以供外界修改, 如果写在extension里面只能是可读的
    open var isAutomaticlyHidden: Bool = false
    /// 这个key如果不指定或者为nil,将使用默认的key那么所有的未指定key的header和footer公用一个刷新时间
    open var lastRefreshTimeKey: String? = nil
    
    /// 耗时
    fileprivate lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    /// 耗时
    fileprivate lazy var calendar: Calendar = Calendar.current
    
    open func setupDescriptionForState(_ closure: @escaping SetDescriptionClosure) {
        setupDesctiptionClosure = closure
    }
    
    open func setupLastFreshTime(_ closure: @escaping SetLastTimeClosure) {
        setupLastTimeClosure = closure
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(indicatorView)
        addSubview(descriptionLabel)
        addSubview(lastTimeLabel)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !descriptionLabel.isHidden {
            if lastTimeLabel.isHidden {
                descriptionLabel.sizeToFit()
                descriptionLabel.center = center
            } else {
                descriptionLabel.sizeToFit()
                lastTimeLabel.sizeToFit()
                indicatorView.sizeToFit()
                descriptionLabel.m_y = bounds.height / 2 - descriptionLabel.bounds.height
                lastTimeLabel.m_y = descriptionLabel.frame.maxY + 8.0
                descriptionLabel.center.x = center.x
                lastTimeLabel.center.x = center.x
                indicatorView.m_x = lastTimeLabel.frame.minX - 8.0 - indicatorView.m_width
                imageView.m_x = lastTimeLabel.frame.minX - 8.0 - imageView.m_width
                indicatorView.center.y = bounds.height / 2
                imageView.center = indicatorView.center
            }
        }
    }
    
}

extension MagiHeader: MagiRefreshComponentDelegate {
    
    public func refreshComponentDidPrepare(_ refreshComponent: MagiRefreshComponent, refreshComponentType: MagiRefreshComponentType) {
        if refreshComponentType == .header {
        } else {
            lastTimeLabel.isHidden = true
            rotateArrowToUpAnimated(false)
        }
        setupLastTime()
    }
    
    // 开始刷新
    public func refreshDidBegin(_ refreshComponent: MagiRefreshComponent, refreshComponentType: MagiRefreshComponentType) {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
    }
    
    // 刷新完成
    public func refreshDidEnd(_ refreshComponent: MagiRefreshComponent, refreshComponentType: MagiRefreshComponentType) {
         indicatorView.stopAnimating()
    }
    
    public func refreshDidChangeProgress(_ refreshComponent: MagiRefreshComponent, progress: CGFloat, refreshComponentType: MagiRefreshComponentType) {
        
    }
    // 刷新状态发生改变 --- 可以更改提示文字...
    public func refreshDidChangeState(_ refreshComponent: MagiRefreshComponent, fromState: MagiRefreshState, toState: MagiRefreshState, refreshComponentType: MagiRefreshComponentType) {

        setupDescriptionForState(toState, type: refreshComponentType)
        
        switch toState {
        case .loading:
            imageView.isHidden = true
        case .normal:
            
            setupLastTime()
            imageView.isHidden = false
            ///恢复
            if refreshComponentType == .header {
                rotateArrowToDownAnimated(false)
                
            } else {
                rotateArrowToUpAnimated(false)
            }
            
        case .pullToRefresh:
            if refreshComponentType == .header {
                
                if fromState == .releaseToFresh {
                    rotateArrowToDownAnimated(true)
                }
                
            } else {
                
                if fromState == .releaseToFresh {
                    rotateArrowToUpAnimated(true)
                }
            }
            imageView.isHidden = false
            
        case .releaseToFresh:
            
            imageView.isHidden = false
            if refreshComponentType == .header {
                rotateArrowToUpAnimated(true)
            } else {
                rotateArrowToDownAnimated(true)
            }
        default: break
        }

    }
    
    fileprivate func rotateArrowToDownAnimated(_ animated: Bool) {
        let time = animated ? 0.2 : 0.0
        UIView.animate(withDuration: time, animations: {
            self.imageView.transform = CGAffineTransform.identity
        })
    }
    
    fileprivate func rotateArrowToUpAnimated(_ animated: Bool) {
        let time = animated ? 0.2 : 0.0
        UIView.animate(withDuration: time, animations: {
            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            
        })
    }
    
    fileprivate func setupLastTime() {
        if lastTimeLabel.isHidden {
            lastTimeLabel.text = ""
        } else {
            guard let lastDate = lastRefreshTime else {
                lastTimeLabel.text = "首次刷新"
                return
            }
            
            if let closure = setupLastTimeClosure {
                lastTimeLabel.text = closure(lastDate as Date)
            } else {
                let lastComponent = (calendar as NSCalendar).components([.day, .year], from: lastDate as Date)
                let currentComponent = (calendar as NSCalendar).components([.day, .year], from: Date())
                var todayString = ""
                if lastComponent.day == currentComponent.day {
                    formatter.dateFormat = "HH:mm"
                    todayString = "今天 "
                } else if lastComponent.year == currentComponent.year {
                    formatter.dateFormat = "MM-dd HH:mm"
                } else {
                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                }
                let timeString = formatter.string(from: lastDate as Date)
                lastTimeLabel.text = "上次刷新时间:" + todayString + timeString
            }
        }
    }
    
    fileprivate func setupDescriptionForState(_ state: MagiRefreshState, type: MagiRefreshComponentType) {
        if descriptionLabel.isHidden {
            descriptionLabel.text = ""
        } else {
            if let closure = setupDesctiptionClosure {
                descriptionLabel.text = closure(state, type)
            } else {
                switch state {
                case .normal:
                    descriptionLabel.text = "正常状态"
                case .loading:
                    descriptionLabel.text = "加载数据中..."
                case .pullToRefresh:
                    if type == .header {
                        descriptionLabel.text = "下拉刷新"
                    } else {
                        descriptionLabel.text = "上拉加载更多"
                    }
                case .releaseToFresh:
                    descriptionLabel.text = "松开手刷新"
                   
                default: break
                }
            }
        }
    }
    
}
