//
//  ToolView.swift
//  openLiveDemo
//
//  Created by 寇松涛 on 2019/9/30.
//  Copyright © 2019 寇松涛. All rights reserved.
//

import UIKit

enum ToolType: Int {
    case broadcast = 100
    case camera
    case audioMute
    case beautyEffect
    case superResolution
}

protocol ToolViewDelegate {
    //摄像机开关
    func doBroadcastPressed()
    //摄像头切换
    func doSwitchCameraPressed(_ btn: UIButton)
    //话筒开关
    func doMutePressed(_ btn: UIButton)
    //美颜
    func doBeautyEffect(_ btn: UIButton)
    //超高分辨率
    func doSuperResolutionPressed(_ btn: UIButton)
}

class ToolView: UIView {

    var broadcastButton: UIButton!
    var sessionButtons: [UIButton]!
    var cameraButton: UIButton!
    var audioMuteButton: UIButton!
    var beautyEffectButton: UIButton!
    var superResolutionButton: UIButton!
    
    var screenShareButton: UIButton!
    
    var delegate: ToolViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubViews(){
        
        broadcastButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        broadcastButton.tag = ToolType.broadcast.rawValue
        broadcastButton.setTitle("广播", for: .normal)
        broadcastButton.backgroundColor = .red
        broadcastButton.addTarget(self, action: #selector(toolBtnDo(btn:)), for: .touchUpInside)
        addSubview(broadcastButton)
        
        cameraButton = UIButton.init(frame: CGRect(x: 70, y: 0, width: 50, height: 50))
        cameraButton.tag = ToolType.camera.rawValue
        cameraButton.setTitle("相机", for: .normal)
        cameraButton.backgroundColor = .red
        cameraButton.addTarget(self, action: #selector(toolBtnDo(btn:)), for: .touchUpInside)
        addSubview(cameraButton)
        
        audioMuteButton = UIButton.init(frame: CGRect(x: 140, y: 0, width: 50, height: 50))
        audioMuteButton.tag = ToolType.audioMute.rawValue
        audioMuteButton.setTitle("话筒", for: .normal)
        audioMuteButton.backgroundColor = .red
        audioMuteButton.addTarget(self, action: #selector(toolBtnDo(btn:)), for: .touchUpInside)
        addSubview(audioMuteButton)
        
        beautyEffectButton = UIButton.init(frame: CGRect(x: 210, y: 0, width: 50, height: 50))
        beautyEffectButton.tag = ToolType.beautyEffect.rawValue
        beautyEffectButton.setTitle("美颜", for: .normal)
        beautyEffectButton.backgroundColor = .red
        beautyEffectButton.addTarget(self, action: #selector(toolBtnDo(btn:)), for: .touchUpInside)
        addSubview(beautyEffectButton)
                        
        superResolutionButton = UIButton.init(frame: CGRect(x: 330, y: 0, width: 50, height: 50))
        superResolutionButton.tag = ToolType.superResolution.rawValue
        superResolutionButton.setTitle("SR", for: .normal)
        superResolutionButton.backgroundColor = .red
        superResolutionButton.addTarget(self, action: #selector(toolBtnDo(btn:)), for: .touchUpInside)
        addSubview(superResolutionButton)
        
        sessionButtons = [cameraButton,audioMuteButton,beautyEffectButton]
        
        
    }
    
    
    @objc func toolBtnDo(btn: UIButton){
        
        switch ToolType.init(rawValue: btn.tag) {
        case .broadcast:
            delegate?.doBroadcastPressed()
        case .camera:
            delegate?.doSwitchCameraPressed(btn)
        case .audioMute:
            delegate?.doMutePressed(btn)
        case .beautyEffect:
            delegate?.doBeautyEffect(btn)
        case .superResolution:
            delegate?.doSuperResolutionPressed(btn)
        default:
            break
        }
        
    }
    
}
