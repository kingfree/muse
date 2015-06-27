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
    var nowselected: Music!
    var playinglist: [Music] = []
    var playlist: [Music] = []
    var nowindex: Int {
        get {
            return getIndex(nowplaying)
        }
        set {
            self.nowplaying = self.playinglist[newValue % self.playinglist.count]
        }
    }
    
    func getIndex(music: Music) -> Int {
        for i in 0 ..< self.playinglist.count {
            if self.playinglist[i] == nowplaying {
                return i
            }
        }
        return -1
    }
    
    private override init() {
        
    }
    
    func setNowPlaying(path: NSURL) {
        self.nowplaying = Music(path: path)
        self.nowselected = self.nowplaying
    }
    
    func addMusic(music: Music) {
        playlist.append(music)
        playinglist.append(music)
    }
    
    func searchMusic(keyword: String) -> [Music] {
        if keyword.isEmpty {
            playinglist = playlist
            return playlist
        }
        playinglist = []
        let match = ".*".join(keyword.componentsSeparatedByString(" ").map { String($0) } )
        for music in playlist {
            if music.match(match) {
                playinglist.append(music)
            }
        }
        return playinglist
    }
    
    func getPrevMusic() -> Music {
        return playinglist[(nowindex - 1) % playinglist.count]
    }
    
    func getNextMusic() -> Music {
        return playinglist[(nowindex + 1) % playinglist.count]
    }
    
}
