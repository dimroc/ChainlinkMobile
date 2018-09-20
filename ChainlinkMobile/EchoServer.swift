//
//  EchoServer.swift
//  ChainlinkMobile
//
//  Created by Dimitri Roche on 9/20/18.
//  Copyright © 2018 Dimitri Roche. All rights reserved.
//

import Embassy
import SwiftyJSON

class EchoServer {
    typealias Callback = (JSON) -> Void
    let loop = try! SelectorEventLoop(selector: try! KqueueSelector())
    var server: DefaultHTTPServer!

    func start(_ callback: @escaping Callback = { _ in }) {
        server = DefaultHTTPServer(eventLoop: loop, port: 6690, app: handler(callback))
        try! server.start()
        DispatchQueue.global(qos: .utility).async {
            self.loop.runForever()
        }
    }

    private func handler(_ callback: @escaping Callback) -> SWSGI {
        return {
            (
            environ: [String: Any],
            startResponse: ((String, [(String, String)]) -> Void),
            sendBody: ((Data) -> Void)
            ) in
            print("--- Received POST environ", environ)

            let input = environ["swsgi.input"] as! SWSGIInput
            var data = Data()
            input { d in data.append(d) }

            guard let json = try? JSON(data: data) else {
                return self.decodeError(data, startResponse: startResponse, sendBody: sendBody)
            }

            print("--- Received POST content", json)
            startResponse("200 OK", [])
            sendBody(Data())
            callback(json)
        }
    }

    private func decodeError(_ data: Data, startResponse: ((String, [(String, String)]) -> Void), sendBody: ((Data) -> Void)) -> Void {
        print("--- Unable to decode input", data)
        startResponse("500 Internal Server Error", [])
        sendBody(Data())
    }
}
