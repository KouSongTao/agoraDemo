//
//  LiveViewModel.swift
//  openLiveDemo
//
//  Created by 寇松涛 on 2019/10/11.
//  Copyright © 2019 寇松涛. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit
import AgoraRtmKit

typealias RtcUpdataClosure = (_ videoSessions :[RtcVideoSession], _ fullSession: RtcVideoSession?) -> Void
typealias RtmUpdataClosure = (_ type: Int, _ content :String, _ members:[AgoraRtmMember]) -> Void

class RtcViewModel: NSObject {
    
    var updataClosure: RtcUpdataClosure?
    
    private var videoSessions = Array<RtcVideoSession>()
    private var fullSession: RtcVideoSession?
    private var channelId: String!
    private var clientRole: AgoraClientRole!
    
    lazy fileprivate var rtcEngine: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: self)
        return engine
    }()
    
    lazy fileprivate var rtmKit: AgoraRtmKit = {
        let kit = AgoraRtmKit.init(appId: "ff157548d8bf441d90db56b877ee9b1c", delegate: self)
        return kit!
    }()
    
    lazy fileprivate var rtmChannel: AgoraRtmChannel = {
        let channel = self.rtmKit.createChannel(withId: channelId, delegate: self)
        return channel!
    }()
    
    private var channelMembers = Array<AgoraRtmMember>()


    init(channelId: String, clientRole: AgoraClientRole,_ closure: @escaping RtcUpdataClosure) {
        super.init()
        self.channelId = channelId
        self.clientRole = clientRole
        self.updataClosure = closure
        self.setupAgoraKit()
    }
    
    func setupAgoraKit() {
        
        rtcEngine.setChannelProfile(.liveBroadcasting)
        
        // Warning: only enable dual stream mode if there will be more than one broadcaster in the channel
        rtcEngine.enableDualStreamMode(true)
                
        rtcEngine.setDefaultAudioRouteToSpeakerphone(true)
        
        rtcEngine.setRemoteSubscribeFallbackOption(.audioOnly)
        
        rtcEngine.enableVideo()
        
        let VEConfig = AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x480, frameRate: .fps15, bitrate: AgoraVideoBitrateStandard, orientationMode: .adaptative)
        
        rtcEngine.setVideoEncoderConfiguration(VEConfig)
        
        rtcEngine.setClientRole(clientRole)
        
        if clientRole == .broadcaster {
            rtcEngine.startPreview()
            addLocalSession()
        }
        
        let code = rtcEngine.joinChannel(byToken: KeyCenter.Token, channelId: channelId, info: nil, uid: 0, joinSuccess: nil)
        if code == 0 {
            UIApplication.shared.isIdleTimerDisabled = true
            rtcEngine.setEnableSpeakerphone(true)
        } else {
            DispatchQueue.main.async(execute: {
//                self.alert(string: "Join channel failed: \(code)")
            })
        }
        
        weak var weakSelf = self
        rtmKit.login(byToken: nil, user: "123456", completion: { (code) in
            if code == .ok{
                weakSelf?.rtmChannel.join(completion: { (code) in
                    if code == .channelErrorOk{
                        print("加入房间")
                        
                        let attribute = AgoraRtmChannelAttribute.init()
                        attribute.key = "123456"
                        attribute.value = "1"
                        
                        let options = AgoraRtmChannelAttributeOptions.init()
                        options.enableNotificationToChannelMembers = true


                        weakSelf?.rtmKit.addOrUpdateChannel("1234", attributes: [attribute], options: options) { (code) in

                        }
                        
//                        weakSelf?.rtmKit.getChannelAllAttributes("1234", completion: { (attributes, code) in
//                            print(code,attributes)
//                        })
                        
                        
                        weakSelf?.rtmKit.getChannelAttributes("1234", byKeys: ["123456"]) { (attributes, code) in
                            print(code,attributes as Any)
                        }
                        
                    }
                })
            }
        })
        
    }

    
    //摄像头切换
    func doSwitchCameraPressed() {
        rtcEngine.switchCamera()
    }
    
    //话筒开关
    func doMutePressed(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
        rtcEngine.muteLocalAudioStream(btn.isSelected)
    }
    
    //美颜
    func doBeautyEffect(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
        let beautyOptions = AgoraBeautyOptions()
        beautyOptions.lighteningContrastLevel = .normal
        beautyOptions.lighteningLevel = 0.7
        beautyOptions.smoothnessLevel = 0.5
        beautyOptions.rednessLevel = 0.1
        rtcEngine.setBeautyEffectOptions(btn.isSelected, options: beautyOptions)
    }

    //超高分辨率
    func doSuperResolutionPressed(_ btn: UIButton) {
        rtcEngine.setRemoteUserPriority(fullSession!.uid, type: .high)
        
    }
    //更新RTC token
    func updateRtcToken(){
        
//        rtcEngine.renewToken("")
    }
    
    //退出
    func leaveChannel() {
        UIApplication.shared.isIdleTimerDisabled = false
        
        rtcEngine.setupLocalVideo(nil)
        rtcEngine.leaveChannel(nil)
        rtmChannel.leave(completion: nil)
        rtmKit.logout(completion: nil)
        
        for session in videoSessions {
            session.hostingView.removeFromSuperview()
        }
        videoSessions.removeAll()
        
        
    }
}

// MARK: - videoSessions操作
extension RtcViewModel{
    func fetchSession(ofUid uid: UInt) -> RtcVideoSession? {
        for session in videoSessions {
            if session.uid == uid {
                return session
            }
        }
        return nil
    }
    
    func videoSession(ofUid uid: UInt) -> RtcVideoSession {
        if let fetchedSession = fetchSession(ofUid: uid) {
            return fetchedSession
        } else {
            let newSession = RtcVideoSession(uid: uid)
            videoSessions.append(newSession)
            return newSession
        }
    }
    //添加本地VS
    func addLocalSession() {
        let localSession = RtcVideoSession.localSession()
        rtcEngine.setupLocalVideo(localSession.canvas)
        fullSession = localSession
        videoSessions.append(localSession)
    }
    //改变铺满VS
    func changeFullVideoSession(by uid:UInt){
        fullSession = videoSessions.first { (liveVideoSession) -> Bool in
            return liveVideoSession.uid == uid
        }
        sessionsDidUpdata()
    }
    //添加远端VS
    func addRemoteVideoSession(by uid: UInt){
        let session = videoSession(ofUid: uid)
        rtcEngine.setupRemoteVideo(session.canvas)
        if fullSession == nil{
            fullSession = session
        }
        sessionsDidUpdata()
    }
    //删除VS
    func deleteVideoSession(by uid: UInt){
        videoSessions.removeAll { (videoSession) -> Bool in
            return videoSession.uid == uid
        }
        
        if fullSession!.uid == uid {
            if videoSessions.count > 0{
                fullSession = videoSessions.first
            }else{
                fullSession = nil
            }
        }
        
        sessionsDidUpdata()
    }
    //VSs已经更新
    func sessionsDidUpdata(){
        if videoSessions.count > 0 {
            for videoSession in videoSessions {
                rtcEngine.setRemoteVideoStream(videoSession.uid, type: .low)
            }
            rtcEngine.setRemoteVideoStream(fullSession!.uid, type: .high)
        }
        updataClosure?(videoSessions, fullSession)
    }
}
// MARK: - AgoraRtcEngineDelegate
extension RtcViewModel: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        if uid == 100{//uid == 自己的uid表示开启了屏幕共享
            rtcEngine.stopPreview()
            rtcEngine.setClientRole(.audience)
            rtcEngine.setupLocalVideo(nil)
        }
        addRemoteVideoSession(by: uid)
    }
        
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFrameWith size: CGSize, elapsed: Int) {
        sessionsDidUpdata()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        if uid == 100 && clientRole == .broadcaster{//uid == 自己的uid表示关闭了屏幕共享
            rtcEngine.startPreview()
            rtcEngine.setClientRole(clientRole)
            addLocalSession()
        }
        deleteVideoSession(by: uid)
    }
    //token即将过期
    func rtcEngine(_ engine: AgoraRtcEngineKit, tokenPrivilegeWillExpire token: String) {
        //更新token
        updateRtcToken()
    }
    //token已经h过期
    func rtcEngineRequestToken(_ engine: AgoraRtcEngineKit) {
        //更新token
        updateRtcToken()
    }
    
}

// MARK: - AgoraRtmDelegate
extension RtcViewModel: AgoraRtmDelegate,AgoraRtmChannelDelegate {
    func rtmKit(_ kit: AgoraRtmKit, connectionStateChanged state: AgoraRtmConnectionState, reason: AgoraRtmConnectionChangeReason) {
        print(state.rawValue)
        
        if state == .aborted && reason == .remoteLogin{
            print("账号在别处登录")
        }
        
        if state == .disconnected && reason == .logout{
            print("登出")
        }
        
    }
    
    //远端用户加入频道
    func channel(_ channel: AgoraRtmChannel, memberJoined member: AgoraRtmMember) {
        print(member.channelId + member.userId + "加入房间")
    }
    //频道成员离开频道
    func channel(_ channel: AgoraRtmChannel, memberLeft member: AgoraRtmMember) {
        print(member.channelId + member.userId + "离开房间")
    }
    //房间属性发生改变
    func channel(_ channel: AgoraRtmChannel, attributeUpdate attributes: [AgoraRtmChannelAttribute]) {
        print(channel,attributes)
    }
    //收到频道消息
    func channel(_ channel: AgoraRtmChannel, messageReceived message: AgoraRtmMessage, from member: AgoraRtmMember) {
        
    }
    //频道成员人数更新回调。返回最新频道成员人数。
    func channel(_ channel: AgoraRtmChannel, memberCount count: Int32) {
        print("房间人数\(count)")
        channel.getMembersWithCompletion { (members, code) in
            if code == .ok && members != nil{
                self.channelMembers = members!
                print(members as Any)
            }
        }
    }
    
}
