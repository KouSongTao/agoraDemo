//
//  ViewController.swift
//  openLiveDemo
//
//  Created by 寇松涛 on 2019/9/29.
//  Copyright © 2019 寇松涛. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit

let Screen_Height = UIScreen.main.bounds.height
let Screen_Width = UIScreen.main.bounds.width

class ViewController: UIViewController {
    
    var roomNameTextField: UITextField!
    var clientRoleBtn: UIButton!
    var pushBtn: UIButton!

    var clientRole = AgoraClientRole.audience

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view.backgroundColor = .white
        setupSubViews()
    }
    
    func setupSubViews(){
        
        roomNameTextField = UITextField.init(frame: CGRect(x: 0, y: 200, width: Screen_Width, height: 50))
        roomNameTextField.placeholder = "请输入房间号"
        roomNameTextField.textAlignment = .center
        roomNameTextField.backgroundColor = .cyan
        view.addSubview(roomNameTextField)
        
        clientRoleBtn = UIButton.init(frame: CGRect(x: (Screen_Width - 200) * 0.5, y: 300, width: 200, height: 50))
        clientRoleBtn.setTitle("观众", for: .normal)
        clientRoleBtn.setTitle("主播", for: .selected)
        clientRoleBtn.setTitleColor(.black, for: .normal)
        clientRoleBtn.addTarget(self, action: #selector(clientRoleBtnClike(btn:)), for: .touchUpInside)
        view.addSubview(clientRoleBtn)

        pushBtn = UIButton.init(frame: CGRect(x: (Screen_Width - 200) * 0.5, y: 400, width: 200, height: 50))
        pushBtn.setTitle("加入房间", for: .normal)
        pushBtn.setTitleColor(.black, for: .normal)
        pushBtn.addTarget(self, action: #selector(pushToRoom), for: .touchUpInside)
        view.addSubview(pushBtn)
        
    }

    @objc func clientRoleBtnClike(btn: UIButton){
        btn.isSelected = !btn.isSelected
        clientRole = btn.isSelected ? .broadcaster:.audience
    }
        
    @objc func pushToRoom(){

        self.view.endEditing(true)
//        let roomVc = LiveRoomViewController()
//        roomVc.roomName = roomNameTextField.text
//        roomVc.clientRole = .audience
//        self.navigationController?.pushViewController(roomVc, animated: true)

        let roomVc = RtcLiveRoomVC()
        roomVc.roomName = roomNameTextField.text
        roomVc.clientRole = clientRole
        self.navigationController?.pushViewController(roomVc, animated: true)

    }
}


