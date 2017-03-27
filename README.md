# MagiRefresh
Swift版MJRefresh,但是肯定不是一样的思路都应该一样,另外我使用了runtime,也就是Swift的外衣下面也用了OC如果以后有解决办法,之后肯定会更新的

1. 首先现在,这个知识基础版本,后面还会继续完善,对于重写这个控件,主要是为了练习Swift中的runTime的使用与一些分装的思路,同时可以保持代码的一致性

- 默认的样式
![这是列子](https://github.com/AnRanScheme/ARARefresh/raw/master/picture1.gif)

        let header = MagiHeader()
        header.lastRefreshTimeKey = "dsadsa"
        let footer = MagiHeader()
        footer.lastRefreshTimeKey = "asdas"
        addHeader(header: header, footer: footer)
       

- 自定义样式
![这是列子](https://github.com/AnRanScheme/ARARefresh/raw/master/picture2.gif)
        let normalHeader = MagiHeader()
        normalHeader.lastRefreshTimeKey = "exampleHeader3"
        
        /// 自定义提示文字

        normalHeader.setupDescriptionForState { (refreshState, refreshType) -> String in
            switch refreshState {
            case .loading:
                return "努力加载中"
            case .normal:
                return "休息中"
            case .pullToRefresh:
                if refreshType == .header {
                    return "继续下下下下"
                } else {
                    return "继续上上上上"
                }
            case .releaseToFresh:
                return "放开我"
            default:
                return ""
            }
        }
        let normalFooter = MagiHeader()
        normalFooter.lastRefreshTimeKey = "exampleFooter3"
        addHeader(header: normalHeader, footer: normalFooter)
        
        
        - 公共调用方法
        
        func addHeader<Animator: UIView>(header: Animator, footer: Animator) where Animator: MagiRefreshComponentDelegate{
        tableView.m_addRefreshHeader(headerAnimator: header) { [weak self] in
            DispatchQueue.global().async {
                for i in 0...50000 {
                    if i <= 10 {
                        self?.data.append(i)
                    }
                    //print("加载数据中")
                }
                self?.Delay(3, completion: {
                    self?.tableView.reloadData()
                    /// 刷新完毕, 停止动画
                    self?.tableView.m_stopHeaderAnimation()
                })
            }
        }
   
   
        tableView.m_addRefreshFooter(footerAnimator: footer) { [weak self] in
            DispatchQueue.global().async {
                for i in 0...50000 {
                    if i <= 10 {
                        self?.data.append(i)
                        
                    }
                    /// 延时
                    print("加载数据中")
                }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.tableView.m_stopFooterAnimation()
                }
            }
        }
      }
    
        func Delay(_ seconds: Double, completion:@escaping ()->()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
      }
