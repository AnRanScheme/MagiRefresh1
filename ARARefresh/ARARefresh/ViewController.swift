//
//  ViewController.swift
//  ARARefresh
//
//  Created by 安然 on 17/3/24.
//  Copyright © 2017年 安然. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let header = MagiHeader()
        header.frame.size = CGSize(width: UIScreen.main.bounds.size.width, height: 80)
        header.center = view.center
        view.addSubview(header)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

