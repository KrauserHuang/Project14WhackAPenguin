//
//  WhackSlot.swift
//  Project14WhackAPenguin
//
//  Created by Tai Chin Huang on 2021/9/11.
//

import UIKit
import SpriteKit

class WhackSlot: SKNode {
    
    var charNode: SKSpriteNode!
    // 可見才可以點擊
    var isVisible = false
    // 點擊只能點擊一次
    var isHit = false
    
    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        // with crop nodes everything with a color is visible, and everything transparent is invisible
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        // crop = 裁切，作為遮蔽物的maskNode，若載入的圖面有顏色的部分就會被遮擋，外面透明的部分就不影響
        // 可以這樣理解，crop的child是不可見的，而maskNode是可以讓child可見的裁剪區域
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)
        
        addChild(cropNode)
    }
    // 將會被view controller重複的呼叫，會跟popupTime互相連動
    func show(hideTime: Double) {
        // 判斷isVisible是false才可以執行show
        if isVisible { return }
        
        charNode.xScale = 1
        charNode.yScale = 1
        
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        // SKTexture之於SKSpriteNode等於UIImage之於UIImageView,一個負責image data,一個負責顯示
        // 可以不用建立新的SKSpriteNode，只要更改SKTexture就可以變換圖片
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        // can't add emitter, bug need to be fixed
        setEmitter(called: "mud", at: CGPoint(x: 10, y: -30))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) { [weak self] in
            self?.hide()
        }
    }
    func hide() {
        // 與show相反，isVisible需要是true才能hide起來
        if !isVisible { return }
        
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
    
    func hit() {
        isHit = true
        // can't add emitter, bug need to be fixed
        setEmitter(called: "smoke", at: charNode.position, with: 2)
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        // .run跑所有closure裡面的code
        let notVisible = SKAction.run { [unowned self] in
            self.isVisible = false
        }
        // 整個動作就是點擊後過幾秒企鵝會往下移動然後消失
        charNode.run(SKAction.sequence([delay, hide, notVisible]))
    }
    
    func setEmitter(called name: String,
                    at position: CGPoint,
                    with zPosition: CGFloat = 0) {
        if let emitter = SKEmitterNode(fileNamed: name) {
            emitter.position = position
            emitter.zPosition = zPosition
            
            let numParticles = Double(emitter.numParticlesToEmit)
            let lifeTime = Double(emitter.particleLifetime)
            let emitterDuration = numParticles * lifeTime
            
            let addEmitterAction = SKAction.run {
                self.addChild(emitter)
            }
            let waitAction = SKAction.wait(forDuration: emitterDuration)
            let removeAction = SKAction.run {
                emitter.removeFromParent()
            }
            let actions = [addEmitterAction, waitAction, removeAction]
            let sequence = SKAction.sequence(actions)
            
            run(sequence)
        }
    }
}
