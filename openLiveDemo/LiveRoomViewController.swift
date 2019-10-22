//
//  LiveRoomViewController.swift
//  openLiveDemo
//
//  Created by 寇松涛 on 2019/9/29.
//  Copyright © 2019 寇松涛. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit
import ReplayKit

class LiveRoomViewController: UIViewController {
    
    var backButton: UIButton!
    var roomNameLabel: UILabel!
    var remoteContainerView: UIView!
    var toolView: ToolView!
    var roomName: String!
    
    fileprivate weak var broadcastActivityVC: RPBroadcastActivityViewController?
    fileprivate weak var broadcastController: RPBroadcastController?

    private var isBroadcasting = false
    
    //MARK: - engine & session view
    lazy fileprivate var rtcEngine: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: self)
        return engine
    }()

    var clientRole = AgoraClientRole.audience
    
    fileprivate var videoSessions = [VideoSession](){
        didSet {
            //remoteContainerView : 窗口视图
            guard remoteContainerView != nil else {
                return
            }
            updateInterface()
        }
    }
    fileprivate var fullSession: VideoSession? {
        didSet {
            if fullSession != oldValue && remoteContainerView != nil {
                updateInterface()
            }
        }
    }
    
    fileprivate let viewLayouter = VideoViewLayouter()
    
    private lazy var broadcastButton: UIView! = {
        if #available(iOS 12.0, *) {
            let frame = CGRect(x: 0, y:view.frame.size.height - 60, width: 60, height: 60)
            let systemBroadcastPicker = RPSystemBroadcastPickerView(frame: frame)
            systemBroadcastPicker.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]

            if let url = Bundle.main.url(forResource: "Agora-Screen-Sharing-iOS-Broadcast", withExtension: "appex", subdirectory: "PlugIns") {
                if let bundle = Bundle(url: url) {
                    systemBroadcastPicker.preferredExtension = bundle.bundleIdentifier
                }
            }

            return systemBroadcastPicker
        }
        else {
            let appBroadcastButton = UIButton(type: .custom)
            appBroadcastButton.frame = CGRect(x: 10, y:view.frame.size.height - 50, width: 40, height: 40)
            appBroadcastButton.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
            appBroadcastButton.addTarget(self, action: #selector(doBroadcastPressed(_:)), for: .touchUpInside)
            return appBroadcastButton
        }
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        setupSubViews()
        
        //房间名字
        roomNameLabel.text = roomName
        
        UserDefaults.init(suiteName: "group.com.ycky")?.set(roomName, forKey: "channelId")
        
        loadAgoraKit()
    }
    
    func setupSubViews(){
        
        remoteContainerView = UIView.init(frame: CGRect(x: 0, y: 0, width: Screen_Width, height: Screen_Height))
        remoteContainerView.backgroundColor = .white
        view.addSubview(remoteContainerView)
        
        roomNameLabel = UILabel.init(frame: CGRect(x: 0, y: 50, width: Screen_Width, height: 30))
        roomNameLabel.textAlignment = .center
        roomNameLabel.textColor = .black
        view.addSubview(roomNameLabel)

        backButton = UIButton.init(frame: CGRect(x: Screen_Width - 100, y: 50, width: 50, height: 50))
        backButton.setTitle("X", for: .normal)
        backButton.backgroundColor = .red
        backButton.addTarget(self, action: #selector(doLeavePressed(_:)), for: .touchUpInside)
        view.addSubview(backButton)
        
        toolView = ToolView.init(frame: CGRect(x: 0, y: Screen_Height - 50, width: Screen_Width, height: 50))
        toolView.delegate = self
        view.addSubview(toolView)

//        view.addSubview(broadcastButton)
        
        

    }
    
    //屏幕录制
    @objc func doBroadcastPressed(_ sender: UIButton) {
        isBroadcasting = !isBroadcasting
        
        if isBroadcasting {
            startReplayKitBroadcasting()
        } else {
            stopReplayKitBroadcasting()
        }
    }

    //美颜
    func beautyOptions() -> AgoraBeautyOptions{
        let options = AgoraBeautyOptions()
        options.lighteningContrastLevel = .normal
        options.lighteningLevel = 0.7
        options.smoothnessLevel = 0.5
        options.rednessLevel = 0.1
        return options
    }
    
    //退出
    @objc func doLeavePressed(_ sender: UIButton) {
        leaveChannel()
    }
    
    
}

//MARK: - tool Action

extension LiveRoomViewController: ToolViewDelegate{
    
    
    //摄像机开关
    func doBroadcastPressed() {
        
        if clientRole == .broadcaster {
            clientRole = .audience
            if fullSession?.uid == 0 {
                fullSession = nil
            }
        } else {
            clientRole = .broadcaster
        }
        
        rtcEngine.stopPreview()
        for btn in toolView.sessionButtons {
            btn.isHidden = !(clientRole == .broadcaster)
        }
        
        rtcEngine.setClientRole(clientRole)
        updateInterface()
    }
    
    //摄像头切换
    func doSwitchCameraPressed(_ btn: UIButton) {
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
        rtcEngine.setBeautyEffectOptions(btn.isSelected, options: beautyOptions())
    }
    
    //超高分辨率
    func doSuperResolutionPressed(_ btn: UIButton) {
        rtcEngine.setRemoteUserPriority(videoSessions.first!.uid, type: .high)
        
    }
    
}


private extension LiveRoomViewController {

    func leaveChannel() {
        setIdleTimerActive(true)
        
        rtcEngine.setupLocalVideo(nil)
        rtcEngine.leaveChannel(nil)
        
        for session in videoSessions {
            session.hostingView.removeFromSuperview()
        }
        videoSessions.removeAll()
        self.navigationController?.popViewController(animated: true)
    }
    
    func setIdleTimerActive(_ active: Bool) {
        UIApplication.shared.isIdleTimerDisabled = !active
    }
    
    func alert(string: String) {
        guard !string.isEmpty else {
            return
        }
        
        let alert = UIAlertController(title: nil, message: string, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

private extension LiveRoomViewController {
    
    func updateInterface() {
        
        var displaySessions = self.videoSessions
        if !(clientRole == .broadcaster) && !displaySessions.isEmpty {
            displaySessions.removeFirst()
        }
        //remoteContainerView : 窗口视图
        viewLayouter.layout(sessions: displaySessions, fullSession: fullSession, inContainer: remoteContainerView)
    }
    
    func addLocalSession() {
        let localSession = VideoSession.localSession()
        videoSessions.append(localSession)
        rtcEngine.setupLocalVideo(localSession.canvas)
    }
    
    func fetchSession(ofUid uid: UInt) -> VideoSession? {
        for session in videoSessions {
            if session.uid == uid {
                return session
            }
        }
        return nil
    }
    
    func videoSession(ofUid uid: UInt) -> VideoSession {
        if let fetchedSession = fetchSession(ofUid: uid) {
            return fetchedSession
        } else {
            let newSession = VideoSession(uid: uid)
            videoSessions.append(newSession)
            return newSession
        }
    }
}

//MARK: - Agora Media SDK
private extension LiveRoomViewController {
    func loadAgoraKit() {
        rtcEngine.setChannelProfile(.liveBroadcasting)
        
        // Warning: only enable dual stream mode if there will be more than one broadcaster in the channel
        rtcEngine.enableDualStreamMode(true)
                
        rtcEngine.enableVideo()
        rtcEngine.setVideoEncoderConfiguration(
            AgoraVideoEncoderConfiguration(
                size: AgoraVideoDimension1280x720,
                frameRate: .fps30,
                bitrate: AgoraVideoBitrateStandard,
                orientationMode: .adaptative
            )
        )
        
        
        rtcEngine.setDefaultAudioRouteToSpeakerphone(true)

        
        rtcEngine.setClientRole(clientRole)

        if clientRole == .broadcaster {
            rtcEngine.startPreview()
        }
        
        addLocalSession()
        
        let code = rtcEngine.joinChannel(byToken: KeyCenter.Token, channelId: roomName, info: nil, uid: 0, joinSuccess: nil)
        if code == 0 {
            setIdleTimerActive(false)
            rtcEngine.setEnableSpeakerphone(true)
        } else {
            DispatchQueue.main.async(execute: {
                self.alert(string: "Join channel failed: \(code)")
            })
        }
    }
}


extension LiveRoomViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let userSession = videoSession(ofUid: uid)
        rtcEngine.setupRemoteVideo(userSession.canvas)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFrameWith size: CGSize, elapsed: Int) {
        updateInterface()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        var indexToDelete: Int?
        for (index, session) in videoSessions.enumerated() {
            if session.uid == uid {
                indexToDelete = index
            }
        }
        
        if let indexToDelete = indexToDelete {
            let deletedSession = videoSessions.remove(at: indexToDelete)
            deletedSession.hostingView.removeFromSuperview()
            
            if deletedSession == fullSession {
                fullSession = nil
            }
        }
    }
}


private extension LiveRoomViewController {
    func startReplayKitBroadcasting() {
        guard RPScreenRecorder.shared().isAvailable else {
            return
        }
        
        RPScreenRecorder.shared().isCameraEnabled = true
        RPScreenRecorder.shared().isMicrophoneEnabled = true
        
        // Broadcast Pairing
        var bundleID : String? = nil
        if let url = Bundle.main.url(forResource: "openLiveDemoScreenShareSetupUI", withExtension: "appex", subdirectory: "PlugIns") {
            if let bundle = Bundle(url: url) {
                bundleID = bundle.bundleIdentifier
            }
        }
        
        RPBroadcastActivityViewController.load(withPreferredExtension: bundleID) { (broadcastActivityViewController, _) in
            self.presentBroadcastActivityVC(broadcastActivityVC: broadcastActivityViewController)
        }
    }
    
    func presentBroadcastActivityVC(broadcastActivityVC: RPBroadcastActivityViewController?) {
        guard let broadcastActivityVC = broadcastActivityVC else {
            return
        }
        broadcastActivityVC.delegate = self
        if UIDevice.current.userInterfaceIdiom == .pad {
            broadcastActivityVC.modalPresentationStyle = .popover
            broadcastActivityVC.popoverPresentationController?.permittedArrowDirections = .down
        }
        present(broadcastActivityVC, animated: true, completion: nil)
        
        self.broadcastActivityVC = broadcastActivityVC
    }
    
    func stopReplayKitBroadcasting() {
        if let broadcastController = broadcastController {
            broadcastController.finishBroadcast(handler: { (error) in
                
            })
        }
    }
}

extension LiveRoomViewController: RPBroadcastActivityViewControllerDelegate {
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController, didFinishWith broadcastController: RPBroadcastController?, error: Error?) {
        DispatchQueue.main.async { [unowned self] in
            if let broadcastActivityVC = self.broadcastActivityVC {
                broadcastActivityVC.dismiss(animated: true, completion: nil)
            }
            
            self.broadcastController = broadcastController
            
            if let broadcastController = broadcastController {
                broadcastController.startBroadcast(handler: { (error) in
                    if let error = error {
                        print("startBroadcastWithHandler error: \(error.localizedDescription)")
                    } else {
                        
                    }
                })
            }
        }
    }
}
