//
//  SampleHandler.swift
//  openLiveDemoScreenShare
//
//  Created by 寇松涛 on 2019/10/8.
//  Copyright © 2019 寇松涛. All rights reserved.
//

import ReplayKit

class SampleHandler: RPBroadcastSampleHandler {

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        
        if let setupInfo = setupInfo, let channel = setupInfo["channelName"] as? String {
            //In-App Screen Capture
            AgoraUploader.startBroadcast(to: channel)
        } else {
            //iOS Screen Record and Broadcast
            AgoraUploader.startBroadcast(to: "channel")
        }
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        AgoraUploader.finishedBroadcast()
        // User has requested to finish the broadcast.
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        DispatchQueue.main.async {
            switch sampleBufferType {
            case .video:
                AgoraUploader.sendVideoBuffer(sampleBuffer)
            case .audioApp:
                AgoraUploader.sendAudioAppBuffer(sampleBuffer)
            case .audioMic:
                AgoraUploader.sendAudioMicBuffer(sampleBuffer)
            @unknown default:
                break
            }
        }
    }
}
