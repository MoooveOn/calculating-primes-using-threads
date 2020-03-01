//
//  DataSourceProvider.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/28/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import UIKit.UITableView

typealias WorkingCell = ReusableCell & ConfigurableCell & UITableViewCell

class TableDataSourceProvider<T, U>: NSObject, UITableViewDataSource where U: WorkingCell {

    private let dataManager: DataManager = DataManager<T>()

    init(items: [T]) {
        dataManager.add(portion: items)
    }

    func add(items: [T]) {
        dataManager.add(portion: items)
    }

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { dataManager.itemsCount }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
          let cell = tableView.dequeueReusableCell(withIdentifier: U.reuseIdentifier, for: indexPath) as? U,
          let item = dataManager.item(at: indexPath.row) as? U.T
          else {
            return UITableViewCell()
        }

        cell.configure(item, at: indexPath)

        return cell
    }
}
