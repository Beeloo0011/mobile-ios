//
//  EndpointManager.swift
//  PIALibrary
//  
//  Created by Jose Blaya on 15/09/2020.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software 
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import Foundation

public struct PinningEndpoint {
    let host: String
    let useCertificatePinning: Bool?
    let commonName: String?
    
    init(host: String, useCertificatePinning: Bool? = false, commonName: String? = nil) {
        self.host = host
        self.useCertificatePinning = useCertificatePinning
        self.commonName = commonName
    }
}

public class EndpointManager {
    
    private let internalUrl = "10.0.0.1"
    private let proxy = "piaproxy.net"
    private let pia = "www.privateinternetaccess.com"
    private let region = "serverlist.piaservers.net"

    public static let shared = EndpointManager()

    private func availableMetaEndpoints(_ availableEndpoints: inout [PinningEndpoint]) {
        var currentServers = Client.providers.serverProvider.currentServers.filter { $0.serverNetwork == .gen4 }
        currentServers = currentServers.sorted(by: { $0.pingTime ?? 1000 < $1.pingTime ?? 1000 })
        
        if currentServers.count > 2 {
            availableEndpoints.append(PinningEndpoint(host: currentServers[0].meta!.ip, useCertificatePinning: true, commonName: currentServers[0].meta?.cn))
            availableEndpoints.append(PinningEndpoint(host: currentServers[1].meta!.ip, useCertificatePinning: true, commonName: currentServers[1].meta?.cn))
        }
    }
    
    public func availableRegionEndpoints() -> [PinningEndpoint] {
    
        if Client.configuration.currentServerNetwork() == .gen4 {
            
            if Client.providers.vpnProvider.isVPNConnected {
                return [PinningEndpoint(host: internalUrl),
                        PinningEndpoint(host: region)]
            }
            
            var availableEndpoints = [PinningEndpoint]()
            availableMetaEndpoints(&availableEndpoints)
            
            availableEndpoints.append(PinningEndpoint(host: region))
            
            return availableEndpoints

        } else {
            return [PinningEndpoint(host: region)]
        }
    }
    
    public func availableEndpoints() -> [PinningEndpoint] {
    
        if Client.configuration.currentServerNetwork() == .gen4 {
            
            if Client.providers.vpnProvider.isVPNConnected {
                return [PinningEndpoint(host: internalUrl),
                        PinningEndpoint(host: pia),
                        PinningEndpoint(host: proxy)]
            }
            
            var availableEndpoints = [PinningEndpoint]()
            availableMetaEndpoints(&availableEndpoints)

            availableEndpoints.append(PinningEndpoint(host: pia))
            availableEndpoints.append(PinningEndpoint(host: proxy))
            
            return availableEndpoints

        } else {
            return [PinningEndpoint(host: pia),
                    PinningEndpoint(host: proxy)]
        }
    }
    
}
