//
//  EchoServer.swift
//  ChainlinkMobile
//
//  Created by Dimitri Roche on 9/20/18.
//  Copyright © 2018 Dimitri Roche. All rights reserved.
//

import Foundation
import Embassy

class EchoServer {
    let loop = try! SelectorEventLoop(selector: try! KqueueSelector())
    let server: DefaultHTTPServer

    init() {
        server = DefaultHTTPServer(eventLoop: loop, port: 6690) {(
            environ: [String: Any],
            startResponse: ((String, [(String, String)]) -> Void),
            sendBody: ((Data) -> Void)) in

            print("--- Received POST environ", environ)

            let input = environ["swsgi.input"] as! SWSGIInput
            var data = Data()
            input { d in data.append(d) }

            guard let dataString = String(data: data, encoding: .utf8) else {
                print("--- Unable to decode input as string", data)
                startResponse("500 Internal Server Error", [])
                sendBody(Data())
                return
            }

            print("--- Received POST content", dataString)
            startResponse("200 OK", [])
            sendBody(Data())
        }
    }

    func start() {
        try! server.start()
        DispatchQueue.global(qos: .utility).async {
            self.loop.runForever()
        }
    }
}
