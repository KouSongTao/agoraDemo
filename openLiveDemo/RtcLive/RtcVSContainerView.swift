//
//  VideoSessionContainerView.swift
//  openLiveDemo
//
//  Created by 寇松涛 on 2019/10/9.
//  Copyright © 2019 寇松涛. All rights reserved.
//


import UIKit

// VS == VideoSession
typealias RtcFullVSUpdataClosure = (_ uid :UInt) -> Void

class RtcVSContainerView: UIView {

    private var videoSessions = Array<RtcVideoSession>()
    private var fullSession: RtcVideoSession?
    private var closure: RtcFullVSUpdataClosure!

    init(frame: CGRect,closure: @escaping RtcFullVSUpdataClosure) {
        super.init(frame: frame)
        self.closure = closure
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var nomalVideoSessions:[RtcVideoSession]{
        get{
            var videoSessions = self.videoSessions
            
            for (index,videoSession) in videoSessions.enumerated() {
                if self.fullSession!.uid == videoSession.uid {
                    videoSessions.remove(at: index)
                    break
                }
            }
            return videoSessions
        }
    }

    //刷新UI
    func refreshUI(_ videoSessions: [RtcVideoSession],_ fullSession: RtcVideoSession?){
        
        self.videoSessions = videoSessions
        self.fullSession = fullSession
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        if fullSession != nil{
            addSubview(self.fullSession!.hostingView)
            self.fullSession?.hostingView.setFrame(self.bounds, type: .full)
        }
        
        layoutNomalVideoSessions()
   
    }
    
    //布局普通悬浮小窗视图
    private func layoutNomalVideoSessions(){
        
        if videoSessions.count <= 1 {
            return
        }
        
        let hMargin:CGFloat = 20.0
        let columnNum:CGFloat = 3

        let nomalW:CGFloat = (Screen_Width - (columnNum + 1) * hMargin) / columnNum
        let nomalH:CGFloat = nomalW * 16 / 9

        for (index,videoSession) in nomalVideoSessions.enumerated() {
            
            let left:CGFloat = CGFloat(index) * (hMargin + nomalW) + hMargin
            videoSession.hostingView.setFrame(CGRect(x: left, y: 100, width: nomalW, height: nomalH), type: .normal)
            videoSession.hostingView.fullViewClosure { (uid) in
                self.closure(uid)
            }
            addSubview(videoSession.hostingView)
        }
    }
}
