//
//  ARANomalViewController.swift
//  ARARefresh
//
//  Created by 安然 on 17/3/27.
//  Copyright © 2017年 安然. All rights reserved.
//

import UIKit

class ARANomalViewController: UITableViewController {
    
    static let cellID = "cellID"
    
    var data: [Int] = [1,2,3,4]
    
    var row: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        tableView.sectionHeaderHeight = 100.0
        
        guard let selectRow = row else { return }
        
        switch selectRow {
        case 0:
            example1()
        case 1:
            example2()
        case 2:
            example3()
        case 3:
            example4()
        case 4:
            example5()
        case 5:
            example6()
        case 6:
            example7()
        default:
            break
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ARANomalViewController.cellID, for: indexPath)
cell.textLabel?.text
        

        return cell
    }
 
    func example1() {
    }
    
    func example2() {
    }
    
    func example3() {
    }
    
    func example4() {
    }
    
    func example5() {
    }
    
    func example6() {
    }
    
    func example7() {
    }

    
}
