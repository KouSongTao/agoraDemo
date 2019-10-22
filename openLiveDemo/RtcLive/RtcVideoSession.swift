//
//  LiveVideoSession.swift
//  openLiveDemo
//
//  Created by 寇松涛 on 2019/10/11.
//  Copyright © 2019 寇松涛. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit

class RtcVideoSession: NSObject {
    
    var uid: UInt
    var hostingView: RtcVideoView!
    var canvas: AgoraRtcVideoCanvas
    
    static func localSession() -> RtcVideoSession {
         //这里上uid 传用户的uid
         return RtcVideoSession(uid: 100)
     }
    
    init(uid: UInt) {
        self.uid = uid
        
        hostingView = RtcVideoView(by: uid)
                
        canvas = AgoraRtcVideoCanvas()
        canvas.uid = uid
        canvas.view = hostingView.videoView
        canvas.renderMode = .hidden
        
    }
}
