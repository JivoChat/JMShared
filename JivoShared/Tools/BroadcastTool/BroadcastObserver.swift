//
//  BroadcastObserver.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 14/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
public final class BroadcastObserver<VT> {
    public let ID: BroadcastObserverID
    private weak var broadcastTool: BroadcastTool<VT>?
        public init(ID: BroadcastObserverID, broadcastTool: BroadcastTool<VT>) {
        self.ID = ID
        self.broadcastTool = broadcastTool
    }
    
    deinit {
        broadcastTool?.removeObserver(self)
    }
}
