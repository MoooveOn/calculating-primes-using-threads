//
//  DetailsViewController.swift
//  PrimesUsingThreads
//
//  Created by Pavel Selivanov on 2/27/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs
import RxSwift
import UIKit

protocol DetailsPresentableListener: class {
    var previewModel: MainPreviewModel { get }
    var primes: [Int64] { get }

    func onDoneAction()
}

final class DetailsViewController: UIViewController, DetailsPresentable, DetailsViewControllable {

    private struct Defaults {
        static let detailsCellHeight: CGFloat = 100
    }

    // MARK: - IBOutlets

    @IBOutlet weak var detailsTableView: UITableView! // for previewCell
    @IBOutlet weak var primesTableView: UITableView!

    weak var listener: DetailsPresentableListener?
    private let detailsDataSource = TableDataSourceProvider<MainPreviewModel, MainPreviewCell>(items: [])
    private let primesDataSource = TableDataSourceProvider<Int64, DetailsPrimeCell>(items: [])

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDetailsTableView()
        setupPrimesTableView()
    }

    private func setupDetailsTableView() {
        guard let record = listener?.previewModel else { return }

        detailsTableView.registerReusableCell(cell: MainPreviewCell.self)
        detailsDataSource.add(items: [record])
        detailsTableView.dataSource = detailsDataSource
        detailsTableView.rowHeight = Defaults.detailsCellHeight
        detailsTableView.tableFooterView = UIView()
    }

    private func setupPrimesTableView() {
        guard let primes = listener?.primes else { return }

        primesTableView.registerReusableCell(cell: DetailsPrimeCell.self)
        primesDataSource.add(items: primes)
        primesTableView.dataSource = primesDataSource
        primesTableView.tableFooterView = UIView()
    }
}

// MARK: - IBAction

extension DetailsViewController {
    @IBAction func doneTapped(_ sender: Any) {
        listener?.onDoneAction()
    }
}
