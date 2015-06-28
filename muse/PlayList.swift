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
    var playedlist: [Music] = []
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
    var playstate: Int = 0
    
    func getIndex(music: Music!) -> Int {
        if music == nil {
            return -1
        }
        for i in 0 ..< self.playinglist.count {
            if self.playinglist[i] == music {
                return i
            }
        }
        return -1
    }
    
    private override init() {
        
    }
    
    func setNowPlaying(music: Music) {
        nowplaying = music
        playedlist.append(music)
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
    
    func getPrevMusic() -> Music! {
        var music: Music!
        do {
            music = playedlist.removeLast()
        } while music == playedlist.last
        if let music = playedlist.last {
            return music
        }
        if playinglist.count < 1 {
            return nil
        }
        return playinglist[(nowindex - 1) % playinglist.count]
    }
    
    func getNextMusic() -> Music! {
        var music: Music!
        switch playstate {
        case 0:
            let i = nowindex + 1
            if playinglist.count > i {
                return playinglist[i]
            }
        case 1:
            return nowplaying
        case 2:
            return playinglist[(nowindex + 1) % playinglist.count]
        case 3:
            var flag = false
            do {
                let i = Int(rand()) % playinglist.count
                if playinglist.count > i && playinglist[i] != nowplaying {
                    flag = true
                    return playinglist[i]
                }
            } while !flag
        default:
            music = playinglist[(nowindex + 1) % playinglist.count]
        }
        return music
    }
    
}
