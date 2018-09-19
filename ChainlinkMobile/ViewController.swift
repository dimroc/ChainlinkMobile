//
//  ViewController.swift
//  ChainlinkMobile
//
//  Created by Dimitri Roche on 9/19/18.
//  Copyright © 2018 Dimitri Roche. All rights reserved.
//

import UIKit
import Chainlink

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

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

