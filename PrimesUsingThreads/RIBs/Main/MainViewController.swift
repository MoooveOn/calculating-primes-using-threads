//
//  MainViewController.swift
//  Empty_RIB
//
//  Created by Pavel Selivanov on 2/22/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import RIBs
import RxSwift
import UIKit
import TransitionButton

protocol MainPresentableListener: class {
    var cacheRecordsCount: Int { get }

    func cacheRecord(at index: Int) -> MainPreviewModel
    func onDetailsAction(index: Int)
    func onStartButtonAction(upperBound: Int, threadCount: Int)
    func onCleanCacheButtonAction()
}

final class MainViewController: UIViewController, MainViewControllable {

    private struct Defaults {
        static let numberOfSection: Int = 1
        static let cellHeight: CGFloat = 100
    }

    // MARK: - IBOutlets

    @IBOutlet private weak var startButton: TransitionButton!
    @IBOutlet private weak var cleanCacheButton: TransitionButton!
    @IBOutlet private weak var upperBoundTextField: UITextField!
    @IBOutlet private weak var threadCountTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var progressLabel: UILabel!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    private func setupTableView() {
        tableView.registerReusableCell(cell: MainPreviewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }

    weak var listener: MainPresentableListener?
    var inProgress: Bool = false {
        didSet {
            if inProgress {
                startButton.startAnimation()
                upperBoundTextField.isEnabled = false
                threadCountTextField.isEnabled = false
                upperBoundTextField.backgroundColor = .lightGray
                threadCountTextField.backgroundColor = .lightGray
            } else {
                startButton.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.0, completion: nil)
                upperBoundTextField.isEnabled = true
                threadCountTextField.isEnabled = true
                upperBoundTextField.backgroundColor = .white
                threadCountTextField.backgroundColor = .white
            }
        }
    }

    fileprivate var upperBound: Int {
        return Int(upperBoundTextField.text ?? "") ?? -1
    }

    fileprivate var threadCount: Int {
        return Int(threadCountTextField.text ?? "") ?? 0
    }

    fileprivate func checkConditions() -> Bool {
        var message: String = ""
        if upperBound < 0 {
            message = "Upper bound should be >= 0"
        } else if !(1...10 ~= threadCount) {
            message = "Threads count should be in range (1...10)"
        } else {
            return true
        }

        let alert = UIAlertController(title: "The condition is violated", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)

        return false
    }
}

// MARK: - close keyboard by tapping outside of textFields

extension MainViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - MainPresentable

extension MainViewController: MainPresentable {
    func progressView(isEnable: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.progressView.isHidden = !isEnable
            self.progressLabel.isHidden = !isEnable

            if !isEnable {
                self.progressView.progress = 0.0
                self.progressLabel.text = ""
            }
        }
    }

    func setProgressView(to: Double) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.progressView.progress = Float(to)
            self.progressLabel.text = #"Progress \#(round(to * 1000) / 10)%"#
        }
    }

    func insertRow(at indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    func cleanCacheFinished() {
        tableView.reloadData()
        cleanCacheButton.stopAnimation(animationStyle: .normal, revertAfterDelay: 0.0, completion: nil)
    }
}

// MARK: - IBActions

extension MainViewController {
    @IBAction func startButtonTapped(_ sender: Any) {
        guard checkConditions() else { return }

        inProgress = true
        listener?.onStartButtonAction(upperBound: upperBound, threadCount: threadCount)
    }

    @IBAction func cleanCacheButtonTapped(_ sender: Any) {
        cleanCacheButton.startAnimation()
        listener?.onCleanCacheButtonAction()
    }
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listener?.onDetailsAction(index: indexPath.row)
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Defaults.numberOfSection
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listener?.cacheRecordsCount ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
          let cell = tableView.dequeueReusableCell(withIdentifier: MainPreviewCell.reuseIdentifier, for: indexPath) as? MainPreviewCell,
          let record = listener?.cacheRecord(at: indexPath.row)
          else {
            return UITableViewCell()
        }

        cell.configure(record, at: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Defaults.cellHeight
    }
}
