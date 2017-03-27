//
//  ViewController.swift
//  ARARefresh
//
//  Created by 安然 on 17/3/24.
//  Copyright © 2017年 安然. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    static let cellID = "cellID"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sectionHeaderHeight = 30.0
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        print("\(self.debugDescription)------被销毁了")
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: ViewController.cellID)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: ViewController.cellID)
        }
        var text = ""
        
        switch indexPath.row {
        case 0:
            text = "使用正常状态且不自定义的header和footer"
        case 1:
            text = "使用正常状态且隐藏的header的显示时间"
        case 2:
            text = "使用正常状态且自定义文字提示和时间显示"
        /*
        case 3:
            text = "使用gif图片且不自定义"
        case 4:
            text = "使用gif图片且隐藏文字提示"
        case 5:
            text = "使用gif图片且自定义文字提示"
        */
        default:
            text = "分离开自定义的设置"
        }
        
        cell?.textLabel?.text = text
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "header"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ARANomalViewController()
        vc.row = indexPath.row
        show(vc, sender: nil)
    }

}

