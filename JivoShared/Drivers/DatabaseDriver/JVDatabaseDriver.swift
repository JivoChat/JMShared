//
//  JVDatabaseDriver.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 03/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import CoreData
import JMTimelineKit

public enum JVDatabaseDriverWriting {
    case anyThread
    case backgroundThread
}
