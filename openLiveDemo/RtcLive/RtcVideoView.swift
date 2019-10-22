//
//  LiveVideoView.swift
//  openLiveDemo
//
//  Created by 寇松涛 on 2019/10/11.
//  Copyright © 2019 寇松涛. All rights reserved.
//

import UIKit

enum RtcVideoViewType {
    case full
    case normal
}

typealias LiveVideoViewFullClosure = (_ uid: UInt) -> Void

class RtcVideoView: UIView {
    
    fileprivate(set) var videoView: UIView!
    private var fullBtn: UIButton!
    private var type: RtcVideoViewType!
    private var uid: UInt!
    private var closure: LiveVideoViewFullClosure!
    
    init(by uid: UInt) {
        super.init(frame: CGRect.zero)
        self.uid = uid
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubViews(){
        
        backgroundColor = UIColor.cyan
        //单击
        let showFull = UITapGestureRecognizer(target: self, action: #selector(showFullBtn))
        addGestureRecognizer(showFull)
        //双击
        let full = UITapGestureRecognizer(target: self, action: #selector(fullView))
        full.numberOfTapsRequired = 2
        addGestureRecognizer(full)
        showFull.require(toFail: full)
        
        videoView = UIView()
        videoView.backgroundColor = .clear
        addSubview(videoView)
        
        fullBtn = UIButton()
        fullBtn.backgroundColor = .clear
        fullBtn.setTitle("铺满", for: .normal)
        fullBtn.addTarget(self, action: #selector(fullView), for: .touchUpInside)
        fullBtn.isHidden = true
        addSubview(fullBtn)
        
    }
    
    //单击显示铺满按钮
    @objc private func showFullBtn() {
        if self.type == .normal{
            fullBtn.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.fullBtn.isHidden = true
            }
        }
    }
    
    //双击铺满
    @objc private func fullView() {
        if self.type == .normal{
            self.fullBtn.isHidden = true
            self.closure(uid)
        }
    }
    //设置frame 后面可以使用约束废弃该方法
    func setFrame(_ frame: CGRect ,type:RtcVideoViewType){
        self.frame = frame
        self.type = type
        videoView.frame = self.bounds
        fullBtn.frame = self.bounds
    }
    
    //更改FULL视图
    func fullViewClosure(_ closure: @escaping LiveVideoViewFullClosure){
        self.closure = closure
    }

}
