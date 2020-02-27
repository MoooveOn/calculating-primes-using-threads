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

    func onDoneAction()
}

final class DetailsViewController: UIViewController, DetailsPresentable, DetailsViewControllable {

    // MARK: - IBOutlets

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var upperBoundLabel: UILabel!
    @IBOutlet weak var threadsCountLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    //@IBOutlet weak var tabelView: UITableView! // for previewCell
    @IBOutlet weak var tabelView: UITableView!

    weak var listener: DetailsPresentableListener?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    private func setupTableView() {
//        tabelView.registerReusableCell(cell: MainPreviewCell.self)
//        tabelView.dataSource = self
//        tabelView.tableFooterView = UIView()

        guard let record = listener?.previewModel else { return }

        startTimeLabel.text = #"Start time: \#(record.startTime.beautyStyle)"#
        upperBoundLabel.text = #"Upper bound: \#(record.upperBound)"#
        threadsCountLabel.text = #"Threads count: \#(record.threadsCount)"#
        let elapsedTime = getFormatted(elapsedTime: round(record.elapsedTime * 1000) / 1000)
        elapsedTimeLabel.text = #"Elapsed time: \#(elapsedTime)"#
    }
}

// MARK: - IBAction

extension DetailsViewController {
    @IBAction func doneTapped(_ sender: Any) {
        listener?.onDoneAction()
    }
}

// MARK: - UITableViewDataSource

extension DetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
          let cell = tableView.dequeueReusableCell(withIdentifier: MainPreviewCell.reuseIdentifier, for: indexPath) as? MainPreviewCell,
          let record = listener?.previewModel
          else {
            return UITableViewCell()
        }

        cell.configure(record, at: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
