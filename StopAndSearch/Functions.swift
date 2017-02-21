//
//  Functions.swift
//  StopAndSearch
//
//  Created by edit on 21/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import Foundation
let MyManagedObjectContextSaveDidFailNotification = Notification.Name(
  rawValue: "MyManagedObjectContextSaveDidFailNotification")
func fatalCoreDataError(_ error: Error) {
  print("*** Fatal error: \(error)")
  NotificationCenter.default.post(name: MyManagedObjectContextSaveDidFailNotification, object: nil)
}
