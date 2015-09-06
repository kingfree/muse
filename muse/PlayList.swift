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
    var playstate: Int = 3
    
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
    
    func setNowPlaying(music: Music!) {
        if music != nil {
            nowplaying = music
            playedlist.append(music)
        }
    }
    
    func addMusic(music: Music!) {
        if music != nil {
            playlist.append(music)
            playinglist.append(music)
        }
    }
    
    func searchMusic(keyword: String) -> [Music] {
        if keyword.isEmpty {
            playinglist = playlist
            return playlist
        }
        playinglist = []
        let match = keyword.componentsSeparatedByString(" ").map { String($0) }.joinWithSeparator(".*" )
        for music in playlist {
            if music.match(match) {
                playinglist.append(music)
            }
        }
        return playinglist
    }
    
    func getPrevMusic() -> Music! {
        var music: Music!
        repeat {
            if playedlist.count > 0 {
                music = playedlist.removeLast()
            } else {
                break
            }
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
            repeat {
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
    
    func removeMusic(indexes: NSIndexSet) -> Bool {
        var s = 0
        var t = 0
        var removelist : [Music] = []
        for i in indexes {
            removelist.append(playinglist[i])
        }
        for item in removelist {
            if let index = playlist.indexOf(item) {
                playlist.removeAtIndex(index)
                s++
            }
            if let index = playinglist.indexOf(item) {
                playinglist.removeAtIndex(index)
                t++
            }
        }
        return s == t
    }
    
    var jsonData: NSData {
        get {
            var list = [NSDictionary]()
            for music in playlist {
                list.append(music.data)
            }
            let data = ["count": playlist.count, "playlist": list]
            return try! NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions())
        }
        set {
            if let data = (try? NSJSONSerialization.JSONObjectWithData(newValue, options: NSJSONReadingOptions())) as? NSDictionary {
                playlist = []
                let count = data["count"] as? Int
                let list = (data["playlist"] as? [NSDictionary])!
                for item in list {
                    let music = Music(data: item)
                    addMusic(music)
                }
            }
        }
    }
    
}
