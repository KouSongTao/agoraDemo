//
//  LiveRoomVC.swift
//  openLiveDemo
//
//  Created by 寇松涛 on 2019/10/11.
//  Copyright © 2019 寇松涛. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit
import ReplayKit

class RtcLiveRoomVC: UIViewController {

    var backButton: UIButton!
    var roomNameLabel: UILabel!
    var containerView: RtcVSContainerView!
    var toolView: ToolView!
    var roomName: String!
    var liveViewModel: RtcViewModel!

    var clientRole = AgoraClientRole.audience
    
    fileprivate weak var broadcastActivityVC: RPBroadcastActivityViewController?
    fileprivate weak var broadcastController: RPBroadcastController?

    private var isBroadcasting = false

    private lazy var broadcastButton: UIView! = {
        if #available(iOS 12.0, *) {
            let frame = CGRect(x: 0, y:view.frame.size.height - 60, width: 60, height: 60)
            let systemBroadcastPicker = RPSystemBroadcastPickerView(frame: frame)
            systemBroadcastPicker.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
            
            if let url = Bundle.main.url(forResource: "openLiveDemoScreenShare", withExtension: "appex", subdirectory: "PlugIns") {
                if let bundle = Bundle(url: url) {
                    systemBroadcastPicker.preferredExtension = bundle.bundleIdentifier
                }
            }
            
            return systemBroadcastPicker
        }
        else {
            let appBroadcastButton = UIButton(type: .custom)
            appBroadcastButton.backgroundColor = .red
            appBroadcastButton.frame = CGRect(x: 10, y:view.frame.size.height - 50, width: 40, height: 40)
            appBroadcastButton.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
            appBroadcastButton.addTarget(self, action: #selector(doBroadcast), for: .touchUpInside)
            return appBroadcastButton
        }
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        weak var weakSelf = self
        
        containerView = RtcVSContainerView(frame: CGRect(x: 0, y: 0, width: Screen_Width, height: Screen_Height), closure: { (uid) in
            weakSelf?.liveViewModel.changeFullVideoSession(by: uid)
        })
        
        containerView.backgroundColor = .white
        view.addSubview(containerView)

        liveViewModel = RtcViewModel.init(channelId: roomName, clientRole: clientRole, { (videoSessions, fullSession) in
            weakSelf?.containerView.refreshUI(videoSessions, fullSession)
        })

        self.setupSubViews()
    }
    
    func setupSubViews(){
        
        roomNameLabel = UILabel.init(frame: CGRect(x: 0, y: 50, width: Screen_Width, height: 30))
        roomNameLabel.textAlignment = .center
        roomNameLabel.textColor = .black
        roomNameLabel.text = roomName
        view.addSubview(roomNameLabel)
        
        backButton = UIButton.init(frame: CGRect(x: Screen_Width - 100, y: 50, width: 50, height: 50))
        backButton.setTitle("X", for: .normal)
        backButton.backgroundColor = .red
        backButton.addTarget(self, action: #selector(doLeavePressed), for: .touchUpInside)
        view.addSubview(backButton)
        
        if clientRole == .broadcaster{
            UserDefaults.init(suiteName: "group.com.zgtfintech")?.set(roomName, forKey: "channelId")
            UserDefaults.init(suiteName: "group.com.zgtfintech")?.set(KeyCenter.Token, forKey: "token")
            UserDefaults.init(suiteName: "group.com.zgtfintech")?.set(100, forKey: "uid")
            view.addSubview(self.broadcastButton)
        }
    }
    
    @objc func doLeavePressed(){
        liveViewModel.leaveChannel()
        self.navigationController?.popViewController(animated: true)
    }
    

    
}


private extension RtcLiveRoomVC {
    
    //屏幕录制
    @objc func doBroadcast() {
        isBroadcasting = !isBroadcasting
        
        if isBroadcasting {
            startReplayKitBroadcasting()
        } else {
            stopReplayKitBroadcasting()
        }
    }
    
    func startReplayKitBroadcasting() {
        guard RPScreenRecorder.shared().isAvailable else {
            return
        }
        
        RPScreenRecorder.shared().isCameraEnabled = true
        RPScreenRecorder.shared().isMicrophoneEnabled = true
        
        // Broadcast Pairing
        var bundleID : String? = nil
        if let url = Bundle.main.url(forResource: "openLiveDemoScreenShare", withExtension: "appex", subdirectory: "PlugIns") {
            if let bundle = Bundle(url: url) {
                bundleID = bundle.bundleIdentifier
            }
        }
        
        RPBroadcastActivityViewController.load(withPreferredExtension: bundleID) { (broadcastActivityViewController, _) in
            guard let broadcastActivityViewController = broadcastActivityViewController else {
                return
            }
            self.broadcastActivityVC = broadcastActivityViewController
            self.broadcastActivityVC!.delegate = self
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.broadcastActivityVC!.modalPresentationStyle = .popover
                self.broadcastActivityVC?.popoverPresentationController?.permittedArrowDirections = .down
            }
            self.present(self.broadcastActivityVC!, animated: true, completion: nil)
        }
    }
        
    func stopReplayKitBroadcasting() {
        if let broadcastController = broadcastController {
            broadcastController.finishBroadcast(handler: { (error) in
                
            })
        }
    }
}

extension RtcLiveRoomVC: RPBroadcastActivityViewControllerDelegate {
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
