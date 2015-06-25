//
//  PlayList.swift
//  muse
//
//  Created by 咲衣憧 on 15/6/24.
//  Copyright (c) 2015年 Kingfree. All rights reserved.
//

import Cocoa

class PlayList : NSObject {
    
    class var sharedInstance : PlayList {
        struct Static {
            static let instance : PlayList = PlayList()
        }
        return Static.instance
    }
    
    var nowplaying: Music!
    var playinglist: [Music] = []
    
    private override init() {
        
    }
    
    func setNowPlaying(path: NSURL) {
        self.nowplaying = Music(path: path)
    }
    
    func addMusic(music: Music) {
        playinglist.append(music)
    }

}
