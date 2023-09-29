//
//  WebSocketManager.swift
//  ShareProject
//
//  Created by Ilia Ilia on 09.09.2023.
//

import UIKit

protocol WebSocketManagerDelegate {
    func didUpdateCandle(_ websocketManager: WebSocketManager, candleModel: CurrentCandleModel)
    func didUpdateMarkPriceStream(_ websocketManager: WebSocketManager, dataModel: MarkPriceStreamModel)
    func didUpdateIndividualSymbolTicker(_ websocketManager: WebSocketManager, dataModel: IndividualSymbolTickerStreamsModel)
    func didUpdateminiTicker(_ websocketManager: WebSocketManager, dataModel: [Symbol])
}

enum State: CaseIterable {
    case markPriceStream
    case individualSymbolTickerStreams
    case currentCandleData
    case tickerarr
}

class WebSocketManager: NSObject, URLSessionWebSocketDelegate {
    private var webSocket: URLSessionWebSocketTask?
    var delegate: WebSocketManagerDelegate?
    var actualState = State.currentCandleData
    
    //    var timeFrame: String = "1m"
    
    func webSocketConnect(symbol: String, timeFrame: String) {
        var url: String
        let coinSymbol = symbol.lowercased()
        
        switch actualState {
        case .markPriceStream:
            url = "wss://fstream.binance.com:443/ws/\(coinSymbol)@markPrice"
            
        case .individualSymbolTickerStreams:
            url = "wss://fstream.binance.com:443/ws/\(coinSymbol)@ticker"
            
        case .currentCandleData:
            url = "wss://fstream.binance.com:443/ws/\(coinSymbol)_perpetual@continuousKline_\(timeFrame)"
            
        case .tickerarr:
            url = "wss://fstream.binance.com:443/ws/!ticker@arr"
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        
        guard let url = URL(string: url) else { return }
        print(url)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
    }
    
    func ping() {
        webSocket?.sendPing { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        }
    }
    
    func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
    
    func recieve() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Got data: \(data)")
                case .string(let message):
                    if let state = self?.actualState {
                        self?.parseJSONWeb(socketString: message, state: state)
                    }
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive error: \(error)")
            }
            self?.recieve()
        })
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        ping()
        recieve()
//        send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connection with reason")
    }
    
    func parseJSONWeb(socketString: String, state: State) {
        guard let socketData = socketString.data(using: String.Encoding.utf8) else { return }
        let decoder = JSONDecoder()
        switch state {
        case .markPriceStream:
            do {
                let decodedData = try decoder.decode(MarkPriceStreamData.self, from: socketData)
                let markPriceStreamModel = MarkPriceStreamModel(symbol: decodedData.s,
                                                                markPrice: decodedData.p,
                                                                indexPrice: decodedData.i,
                                                                fundingRate: decodedData.r,
                                                                nextFundingTime: decodedData.T)
                
                if delegate != nil {
                    delegate!.didUpdateMarkPriceStream(self, dataModel: markPriceStreamModel)
                }
            } catch {
                print("Error JSON: \(error)")
            }
        case .individualSymbolTickerStreams:
            do {
                let decodedData = try decoder.decode(IndividualSymbolTickerStreamsData.self, from: socketData)
                let IndividualSymbolTickerStreamsModel = IndividualSymbolTickerStreamsModel(symbol: decodedData.s,
                                                                                            volumeBase: decodedData.v,
                                                                                            volumeQuote: decodedData.q,
                                                                                            closePrice: decodedData.c,
                                                                                            openPrice: decodedData.o,
                                                                                            highPrice: decodedData.h,
                                                                                            lowPrice: decodedData.l, priceChangePercent: decodedData.P)
                if delegate != nil {
                    delegate!.didUpdateIndividualSymbolTicker(self, dataModel: IndividualSymbolTickerStreamsModel)
                }
            } catch {
                print("Error JSON: \(error)")
            }
        case .currentCandleData:
            do {
                let decodedData = try decoder.decode(CurrentCandleData.self, from: socketData)
                let currentCandleModel = CurrentCandleModel(eventTime: decodedData.E,
                                                            pair: decodedData.ps,
                                                            interval: decodedData.k.i,
                                                            openPrice: decodedData.k.o,
                                                            closePrice: decodedData.k.c,
                                                            highPrice: decodedData.k.h,
                                                            lowPrice: decodedData.k.l,
                                                            isKlineClose: decodedData.k.x)
                if delegate != nil {
                    delegate!.didUpdateCandle(self, candleModel: currentCandleModel)
                }
            } catch {
                print("Error JSON: \(error)")
            }
        case .tickerarr:
            do {
                let decodedData = try decoder.decode([FullSymbolData].self, from: socketData)
                
                let array = FullSymbolsArray.fullSymbols
                for data in decodedData.sorted(by: { $0.s < $1.s }) {
                    if !FullSymbolsArray.fullSymbols.contains(where: { $0.s == data.s }) {
                        FullSymbolsArray.fullSymbols.append(FullSymbolData(symbol: data.s,
                                                                           priceChangePercent: data.P,
                                                                           markPrice: data.c,
                                                                           volume: data.q))
                    }
                }
                let defaults = DataLoader(keys: "savedFullSymbolsData")
                defaults.loadUserSymbols()
                
                let newSymbolModel = SymbolsArray.symbols
                
                for model in array {
                    if let index = newSymbolModel.firstIndex(where: { $0.symbol == model.s }) {
                        newSymbolModel[index].volume = model.q
                        newSymbolModel[index].priceChangePercent = model.P
                    }
                }
                
//                let miniTickerSYmbolModel = FullSymbolModel(symbol: decodedData.s,
//                                                            markPrice: decodedData.c,
//                                                            volume: decodedData.q)
                
                if delegate != nil {
                    delegate!.didUpdateminiTicker(self, dataModel: newSymbolModel)
                }
            } catch {
                print("Error JSON: \(error)")
            }
        }
    }
    
    /*func send() {
        if !isClose {
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                self.send()
                self.webSocket?.send(.string("Send new message: \(Int.random(in: 0...1000))"), completionHandler: { error in
                    if let error = error {
                        print("Send error: \(error)")
                    }
                })
            }
        }
    }*/
    
}



