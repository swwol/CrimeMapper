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
    
    CrimeCategory(category:   "Burglary",url:"burglary", color:.flatPlumDark, type: "theft"),
    CrimeCategory(category:   "Robbery", url:"robbery", color: .flatPurpleDark, type: "theft"),
    CrimeCategory(category:   "Shoplifting", url:"shoplifting", color: .flatMagentaDark, type: "theft"),
    CrimeCategory(category:   "Theft from the person", url:"theft-from-the-person", color:.flatBlueDark , type: "theft"),
    CrimeCategory(category:   "Other theft",url:"other-theft", color: .flatPowderBlueDark, type: "theft"),
    
    CrimeCategory(category:   "Anti-social behaviour",url:"anti-social-behaviour", color: .flatOrangeDark, type: "public order"),
    CrimeCategory(category:   "Criminal damage and arson",url:"criminal-damage-arson", color: .flatYellowDark, type: "public order"),
    CrimeCategory(category:   "Public order",url:"public-order", color: .flatSand, type: "public order"),
   
    CrimeCategory(category:   "Possession of weapons",url:"possession-of-weapons", color: .flatForestGreenDark, type: "possession"),
    CrimeCategory(category:   "Drugs",url:"drugs", color:.flatLimeDark, type: "possession"),
   
 
    CrimeCategory(category:    "Vehicle crime", url:"vehicle-crime", color: .flatBrown, type: "vehicle crime"),
    CrimeCategory(category:    "Bicycle theft",url:"bicycle-theft", color:.flatCoffeeDark, type: "vehicle crime"),
    
    CrimeCategory(category:    "Violence and sexual offences", url:"violent-crime", color: .flatRed, type: "violence"),
    
    CrimeCategory(category:    "Other crime", url:"other-crime", color: .flatGray, type: "other")]
  

  public static var types = ["theft", "public order","possession","vehicle crime","violence","other"]
  

}


