//
//  ObservableService.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 15/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
public final class BroadcastUniqueTool<VT: Equatable>: BroadcastTool<VT> {
    private(set) public var cachedValue: VT?
    
    public func broadcast(_ value: VT, tag: BroadcastToolTag? = nil, force: Bool) {
        guard value != cachedValue || force else { return }
        cachedValue = value
        
        super.broadcast(value, tag: tag)
    }
    
    public override func broadcast(_ value: VT, tag: BroadcastToolTag? = nil) {
        broadcast(value, tag: tag, force: false)
    }
}
