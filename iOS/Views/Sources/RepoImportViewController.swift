//
//  RepoImportViewController.swift
//  feather
//
//  Created by HAHALOSAH on 8/27/24.
//

import Foundation
import UIKit

class RepoImportViewController: UIViewController, UITextViewDelegate {
    let textView = UITextView()
    
    override func viewDidLoad() {
        view.addSubview(textView)
        textView.font = .monospacedSystemFont(ofSize: 16, weight: .regular)
        textViewDidEndEditing(textView)
        textView.delegate = self
        view.backgroundColor = .systemBackground
        title = "Import Repositories"
        textView.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(donePressed))
        navigationController?.navigationBar.prefersLargeTitles = true
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.secondaryLabel {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Paste your repos here, one URL per line"
            textView.textColor = UIColor.secondaryLabel
        }
    }
    
    @objc func donePressed() {
        dismiss(animated: true)
        let text = textView.text!
        DispatchQueue(label: "import").async {
            var success = 0
            for line in text.split(separator: "\n") {
                let str = String(line)
                if str.starts(with: "http") {
                    let sem = DispatchSemaphore(value: 0)
                    CoreDataManager.shared.getSourceData(urlString: str) { error in
                        if let error = error {
                            Debug.shared.log(message: "SourcesViewController.sourcesAddButtonTapped: \(error)", type: .critical)
                        } else {
                            NotificationCenter.default.post(name: Notification.Name("sfetch"), object: nil)
                            success += 1
                        }
                        sem.signal()
                    }
                    sem.wait()
                }
            }
            Debug.shared.showSuccessAlert(with: "Successfully imported \(success) repos", subtitle: "")
        }
    }
    
    @objc func cancelPressed() {
        dismiss(animated: true)
    }
}
