//
//  case.swift
//  dans une case
//
//  Created by Antoine FeuFeu on 22/05/2016.
//  Copyright © 2016 Antoine FeuFeu. All rights reserved.
//

import Foundation
import SpriteKit

class case_type: SKSpriteNode {
    
    enum activiter {
        case actif
        case inactif
        case inintervenant
        mutating func changer() {
            switch self {
            case .actif:
                self = .inactif
            case .inactif:
                self = .actif
            default:
                self = .inintervenant
            }
        }
    }
    
    private func animerVers(couleur color: UIColor) {
        self.runAction(SKAction.colorizeWithColor(color, colorBlendFactor: 1.0, duration: 0.2))
    }
    
    var actif: activiter = .inintervenant
    var colonne: Int = 0
    var ranger: Int = 0
    var repere: Int = 0
    
    func PasserActif() {
        self.actif = .actif
        self.animerVers(couleur: UIColor.greenColor())
    }
    func PasserInactif() {
        self.actif = .inactif
        self.animerVers(couleur: UIColor.redColor())
    }
    func PasserInintervenant() {
        self.actif = .inintervenant
        self.animerVers(couleur: UIColor.blueColor())
    }
    func Interchanger() {
        switch actif {
        case .actif:
            self.actif = .inactif
        case .inactif:
            self.actif = .actif
        default:
            break
        }
    }
    
    func PoserColonne(a: Int) {
        self.colonne = a
    }
    func PoserRanger(a: Int) {
        self.ranger = a
    }
    func Syncroniser() {
        self.repere = colonne*10+ranger
    }
    
    
    
}










