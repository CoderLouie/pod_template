//
//  ViewController.swift
//  PROJECT
//
//  Created by USER_NAME on TODAYS_DATE.
//

import UIKit
import SwifterKnife

fileprivate class TestCaseCell: UITableViewCell, Reusable {
}

fileprivate enum TestCase: String, CaseIterable {
    case one = "one"
    
    func perform(from vc: ViewController) {
        switch self {
        case .one:
            print("one")
        }
    }
    
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView = UITableView().then {
            $0.backgroundColor = .clear
            $0.tableFooterView = UIView()
            $0.contentInsetAdjustmentBehavior = .never
            $0.separatorStyle = .none
            $0.delegate = self
            $0.dataSource = self
            $0.rowHeight = 45
            $0.register(cellType: TestCaseCell.self)
            view.addSubview($0)
            $0.contentInset = UIEdgeInsets(top: Screen.navbarH, left: 0, bottom: Screen.safeAreaB, right: 0)
            $0.frame = view.bounds
        }
    }
    private unowned var tableView: UITableView!
    private lazy var items: [TestCase] = TestCase.allCases
}

// MARK: - Delegate
extension ViewController: UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       items.count
   }
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell: TestCaseCell = tableView.dequeueReusableCell(for: indexPath)
       let index = indexPath.row
       let text = String(format: "%02d. ", index) + items[index].rawValue
       cell.textLabel?.text = text
       return cell
   }
}

extension ViewController: UITableViewDelegate {
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       tableView.deselectRow(at: indexPath, animated: true)
       items[indexPath.row].perform(from: self)
   }
}

