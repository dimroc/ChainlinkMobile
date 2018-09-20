//
//  ViewController.swift
//  ChainlinkMobile
//
//  Created by Dimitri Roche on 9/19/18.
//  Copyright © 2018 Dimitri Roche. All rights reserved.
//

import UIKit
import Chainlink
import SwiftyJSON

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private let es = EchoServer()
    private var echoes = [JSON]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        es.start() { json in
            self.echoes.append(json)
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
        }

        initializeAccountKey()
        let pwd = Bundle.main.path(forResource: "password", ofType: ".txt")
        let api = Bundle.main.path(forResource: "apicredentials", ofType: "")
        DispatchQueue.global(qos: .utility).async {
            ChainlinkStart(pwd, api)
        }
    }

    private func initializeAccountKey() {
        let paths = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask)
        let keysFolder = paths[0]
            .appendingPathComponent("Chainlink")
            .appendingPathComponent("keys")

        try? FileManager.default.createDirectory(at: keysFolder, withIntermediateDirectories: true)

        let src = Bundle.main.url(forResource: "UTC--2017-01-05T20-42-24.637Z--9ca9d2d5e04012c9ed24c0e513c9bfaa4a2dd77f", withExtension: "")
        let dst = keysFolder.appendingPathComponent("UTC--2017-01-05T20-42-24.637Z--9ca9d2d5e04012c9ed24c0e513c9bfaa4a2dd77f")
        try? FileManager.default.copyItem(at: src!, to: dst)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return echoes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let echo = echoes[indexPath.row]
        return updateCell(echo, cell)
    }

    func updateCell(_ echo: JSON, _ cell: UITableViewCell) -> UITableViewCell {
        cell.textLabel?.text = echo["address"].string
        return cell
    }
}
