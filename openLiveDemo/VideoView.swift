//
//  VideoView.swift
//  OpenVideoCall
//
//  Created by GongYuhua on 2/14/16.
//  Copyright © 2016 Agora. All rights reserved.
//

import UIKit

class VideoView: UIView {
    
    fileprivate(set) var videoView: UIView!
    
    override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white
        
        addVideoView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension VideoView {
    func addVideoView() {
        videoView = UIView()
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.backgroundColor = UIColor.clear
        addSubview(videoView)
        
        let videoViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[video]|", options: [], metrics: nil, views: ["video": videoView])
        let videoViewV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[video]|", options: [], metrics: nil, views: ["video": videoView])
        NSLayoutConstraint.activate(videoViewH + videoViewV)
    }
    
}
