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
    var nowindex: Int {
        get {
            for i in 0 ..< self.playinglist.count {
                if self.playinglist[i] == nowplaying {
                    return i
                }
            }
            return 0
        }
        set {
            self.nowplaying = self.playinglist[newValue % self.playinglist.count]
        }
    }
    
    private override init() {
        
    }
    
    func setNowPlaying(path: NSURL) {
        self.nowplaying = Music(path: path)
    }
    
    func addMusic(music: Music) {
        playinglist.append(music)
    }
    
    func searchMusic(keyword: String) -> [Music] {
        if keyword.isEmpty {
            return playinglist
        }
        var result: [Music] = []
        let match = ".*".join(keyword.componentsSeparatedByString(" ").map { String($0) } )
        for music in playinglist {
            if music.match(match) {
                result.append(music)
            }
        }
        return result
    }
    
    func getPrevMusic() -> Music {
        return playinglist[(nowindex - 1) % playinglist.count]
    }
    
    func getNextMusic() -> Music {
        return playinglist[(nowindex + 1) % playinglist.count]
    }
    
}
