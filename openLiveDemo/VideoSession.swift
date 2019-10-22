//
//  VideoSession.swift
//  OpenLive
//
//  Created by GongYuhua on 6/25/16.
//  Copyright © 2016 Agora. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit

class VideoSession: NSObject {
    
    var uid: UInt
    var hostingView: VideoView!
    var canvas: AgoraRtcVideoCanvas
    
    init(uid: UInt) {
        self.uid = uid
        
        hostingView = VideoView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        canvas = AgoraRtcVideoCanvas()
        canvas.uid = uid
        canvas.view = hostingView.videoView
        canvas.renderMode = .hidden

    }
}

extension VideoSession {
    static func localSession() -> VideoSession {
        return VideoSession(uid: 100)
    }
}
