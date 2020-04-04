//
//  ControlCenterVolumeUpItem.swift
//  Pock
//
//  Created by Pierluigi Galdi on 16/02/2019.
//  Copyright © 2019 Pierluigi Galdi. All rights reserved.
//

import Foundation
import Defaults

class CCVolumeUpItem: ControlCenterItem {
    
    var value_corrected: Float = 0
    
    override var enabled: Bool { return Defaults[.shouldShowVolumeItem] && Defaults[.shouldShowVolumeUpItem] }
    
    private let key: KeySender = KeySender(keyCode: NX_KEYTYPE_SOUND_UP, isAux: true)
    
    override var title: String { return "volume-up" }
    
    override var icon:  NSImage { return NSImage(named: NSImage.touchBarVolumeUpTemplateName)! }
    
    override func action() -> Any? {
        Defaults[.isVolumeMute] = false
        key.send()
        NSWorkspace.shared.notificationCenter.post(name: .shouldReloadControlCenterWidget, object: nil)
        return NSSound.systemVolume()
    }
    
    override func longPressAction() {
        parentWidget?.showSlideableController(for: self, currentValue: value_corrected)
    }
    
    override func didSlide(at value: Double) {
        //I've noticed that if you try to quickly flick the slider to the left to mute the volume, it often doesn't go all the way to the left which makes the volume really low, but not muted. This part fixes this behaviour by muting the volume when the slider is almost fully to the left.
        
        if Float(value)<0.07 {
            NSSound.setSystemVolume(0.01)
            value_corrected = 0
            Defaults[.isVolumeMute] = true

        }
        else {
            value_corrected = Float(value)
            Defaults[.isVolumeMute] = false
        }
        NSSound.setSystemVolume(Float(value_corrected))
        NSWorkspace.shared.notificationCenter.post(name: .shouldReloadControlCenterWidget, object: nil)
        DK_OSDUIHelper.showHUD(type: NSSound.isMuted() ? .mute : .volume, filled: CUnsignedInt(value_corrected * 16))
    }
    
}
