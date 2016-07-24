//
//  GameScene.swift
//  dans une case
//
//  Created by Antoine FeuFeu on 21/05/2016.
//  Copyright (c) 2016 Antoine FeuFeu. All rights reserved.
//

import SpriteKit



class GameScene: SKScene {
    
    
    let Noeud = SKNode()
    let son_actif = SKAction.playSoundFileNamed("gravity_on.caf", waitForCompletion: false)
    let son_inactif = SKAction.playSoundFileNamed("gravity_off.caf", waitForCompletion: false)
    let son_tap = SKAction.playSoundFileNamed("tap.caf", waitForCompletion: false)
    let son_defaite = SKAction.playSoundFileNamed("monster_sad.caf", waitForCompletion: false)
    let son_victoire = SKAction.playSoundFileNamed("win.caf", waitForCompletion: false)
    
    var collection: [Int:case_type] = [:]
    
    var colonne_global: Int = 0
    var ranger_global: Int = 0
    var mouvement: Int = 0 {
        didSet {
            if self.mouvement <= 0 {
                if !self.fini {
               self.fin()
                }
            } else {
               self.label_mouvement.text = "mouvement: \(mouvement)"
            }
        }
    }
    var fini = false
    let label_mouvement = SKLabelNode(fontNamed: "AdvancedLEDBoard-7")
    
    override init(size: CGSize) {
        super.init(size: size)
    
        let fond = SKSpriteNode(color: UIColor.grayColor(), size: CGSize(width: self.frame.width, height: self.frame.width))
        fond.zPosition = -1
        self.backgroundColor = UIColor.whiteColor()
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.addChild(fond)
        self.addChild(Noeud)
        
        if let dico = Dictionary<String, AnyObject>.lectureJSON("niveau1") {
            
            if let n_colonne = dico["colonne"] {
                colonne_global = n_colonne as! Int
            }
            if let n_ranger = dico["ranger"] {
                ranger_global = n_ranger as! Int
            }
            if let n_mouvement = dico["mouvement"] {
                mouvement = n_mouvement as! Int
            }
            
            for colonne in 1...colonne_global {
                for ranger in 1...ranger_global {
            
                        let sprite = case_type(color: UIColor.greenColor(), size: CGSize(width: self.frame.width/7, height: self.frame.width/7))
                        sprite.PasserActif()
                        sprite.colonne = colonne
                        sprite.ranger = ranger
                        sprite.Syncroniser()
                        sprite.position = Point(colonne, ranger: ranger)
                        sprite.zPosition = 2
                        self.Noeud.addChild(sprite)
                        collection[sprite.repere] = sprite
                        print("generer :", sprite.colonne, sprite.ranger, sprite.actif, sprite.repere)
                }
            }
            
            
            if let caseRouge = dico["grille"] as? [[Int]] {
                var r = ranger_global
                for ranger in caseRouge { // json : de haut en bas puis (n) de gauche a droite
                    var c = colonne_global
                    for n in ranger {
                        if n == 0 {
                            if let carreau = collection[c*10+r] {
                               carreau.PasserInactif()
                            }
                        }
                        c -= 1
                    }
                    r -= 1
                }
                
            }
            
            /* if let tuple = dico["inut"] { // case inutilsable ( bleu ) ici
              
                for (_, data) in EnumerateSequence(tuple as! [[Int]])  {
                    
                    for (colonne, ranger) in EnumerateSequence(data) {
                        
                        if colonne >= 1 && ranger >= 1 {
                        
                            let repere = colonne*10 + ranger
                            if let cible = collection[repere] {
                                
                                cible.PasserInintervenant()
                                cible.color = UIColor.blueColor()
                                print(colonne, ranger)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            */
            
            
        }
        
        // label_mouvement.position = CGPoint(x: self.frame.width/2, y: self.frame.height - self.frame.width/7)
        label_mouvement.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMaxY(fond.frame) + self.frame.height/16)
        label_mouvement.text = "mouvement : \(mouvement)"
        label_mouvement.fontSize = 77
        label_mouvement.fontColor = UIColor.greenColor()
        label_mouvement.horizontalAlignmentMode = .Center
        label_mouvement.verticalAlignmentMode = .Center
        label_mouvement.zPosition = 5
        self.addChild(label_mouvement)
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            
            let location_case = touch.locationInNode(Noeud)
            
            if self.fini {
               self.runAction(SKAction.sequence([
                son_tap,
                SKAction.waitForDuration(0.1),
                SKAction.runBlock({
                    let scene = GameScene(size: self.frame.size)
                    scene.scaleMode = .AspectFill
                    let trans = SKTransition.moveInWithDirection(SKTransitionDirection.Down, duration: 1)
                    self.view?.presentScene(scene, transition: trans)
                })
                ]))
                return
            }
            
            for sprite in Noeud.children {
                
                let sprite_t = sprite as! case_type
                    
                    if sprite_t.containsPoint(location_case) {
                        
                        Quadriller(sprite_t.colonne, ranger: sprite_t.ranger)
                        mouvement -= 1
                        switch sprite_t.actif {
                        case .actif:
                            self.runAction(son_actif)
                        case .inactif:
                            self.runAction(son_inactif)
                        default:
                            break
                        }
                        if evaluer() {
                            
                            self.fin()
                            
                        }
                    }
                
                
            }
            
            
        }
    }
    
    
    func Quadriller(colonne: Int, ranger: Int) {
        
        let origine = colonne*10 + ranger
        let sprite_origine = collection[origine]!
        EtatChange(sprite_origine)
        
        // les 4 aux alentours :
        let dessus = (colonne+1)*10 + ranger
        if let sprite = collection[dessus] {
            EtatChange(sprite)
        }
        let dessous = (colonne-1)*10 + ranger
        if let sprite = collection[dessous] {
            EtatChange(sprite)
        }
        let coterD = colonne*10 + ranger-1
        if let sprite = collection[coterD] {
            EtatChange(sprite)
        }
        let coterG = colonne*10 + ranger+1
        if let sprite = collection[coterG] {
            EtatChange(sprite)
        }
        
    }
    
    func EtatChange(sprite_t: case_type) {
        switch sprite_t.actif {
        case .actif:
            sprite_t.PasserInactif()
        case .inactif:
            sprite_t.PasserActif()
        default:
            print("case type declarer comme inactive", sprite_t.actif)
        }
    }
    
    func Point(colonne: Int, ranger: Int) -> CGPoint {
        
        return CGPoint(x: self.frame.origin.x + CGFloat(colonne) * self.frame.width/6, y: (self.frame.width - self.frame.height)*1.5 + CGFloat(ranger) * self.frame.width/6)
        // supr le *1.5 pour passer de l'ipad a l'iphone 
        
    }
    
    func evaluer() -> Bool {
        
        var totalVert = 0
        for carreau in collection {
            if carreau.1.actif == case_type.activiter.inactif {
                totalVert += 1
            }
        }
        
        return totalVert == 0
    }
    
    func fin() {
        
        switch self.evaluer() {
        case false:
            self.label_mouvement.text = "perdu"
            self.label_mouvement.fontColor = UIColor.orangeColor()
            self.runAction(son_defaite)
        case true:
            self.label_mouvement.text = "victoire !"
            self.label_mouvement.fontColor = UIColor.blueColor()
            self.runAction(son_victoire)
        }
        self.fini = true
    }
    
}












