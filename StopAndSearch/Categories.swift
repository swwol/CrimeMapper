//
//  Categories.swift
//  StopAndSearch
//
//  Created by edit on 04/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

struct Categories {
  
  
 
  
  public static var categories: [CrimeCategory] = [
    
    CrimeCategory(category:   "Burglary",url:"burglary", color:.flatPlumDark, type: "theft", enabled: true),
    CrimeCategory(category:   "Robbery", url:"robbery", color: .flatPurpleDark, type: "theft", enabled: true),
    CrimeCategory(category:   "Shoplifting", url:"shoplifting", color: .flatMagentaDark, type: "theft", enabled: true),
    CrimeCategory(category:   "Theft from the person", url:"theft-from-the-person", color:.flatBlueDark , type: "theft", enabled: true),
    CrimeCategory(category:   "Other theft",url:"other-theft", color: .flatPowderBlueDark, type: "theft", enabled: true),
    
    CrimeCategory(category:   "Anti-social behaviour",url:"anti-social-behaviour", color: .flatOrangeDark, type: "public order", enabled: true),
    CrimeCategory(category:   "Criminal damage and arson",url:"criminal-damage-arson", color: .flatYellowDark, type: "public order", enabled: true),
    CrimeCategory(category:   "Public order",url:"public-order", color: .flatSand, type: "public order", enabled: true),
   
    CrimeCategory(category:   "Possession of weapons",url:"possession-of-weapons", color: .flatForestGreenDark, type: "possession", enabled: true),
    CrimeCategory(category:   "Drugs",url:"drugs", color:.flatLimeDark, type: "possession, enabled: true", enabled: true),
   
 
    CrimeCategory(category:    "Vehicle crime", url:"vehicle-crime", color: .flatBrown, type: "vehicle crime", enabled: true),
    CrimeCategory(category:    "Bicycle theft",url:"bicycle-theft", color:.flatCoffeeDark, type: "vehicle crime", enabled: true),
    
    CrimeCategory(category:    "Violence and sexual offences", url:"violent-crime", color: .flatRed, type: "violence", enabled: true),
    
    CrimeCategory(category:    "Other crime", url:"other-crime", color: .flatGray, type: "other", enabled: true)]
  

  public static var types = ["theft", "public order","possession","vehicle crime","violence","other"]
  

}


