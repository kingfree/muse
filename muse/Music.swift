//
//  Music.swift
//  muse
//
//  Created by 咲衣憧 on 15/6/23.
//  Copyright (c) 2015年 Kingfree. All rights reserved.
//

import Cocoa
import AVFoundation


/*
http://id3.org/id3v2.4.0-frames

4.19  AENC Audio encryption
4.14  APIC Attached picture
4.30  ASPI Audio seek point index

4.10  COMM Comments
4.24  COMR Commercial frame

4.25  ENCR Encryption method registration
4.12  EQU2 Equalisation (2)
4.5   ETCO Event timing codes

4.15  GEOB General encapsulated object
4.26  GRID Group identification registration

4.20  LINK Linked information

4.4   MCDI Music CD identifier
4.6   MLLT MPEG location lookup table

4.23  OWNE Ownership frame

4.27  PRIV Private frame
4.16  PCNT Play counter
4.17  POPM Popularimeter
4.21  POSS Position synchronisation frame

4.18  RBUF Recommended buffer size
4.11  RVA2 Relative volume adjustment (2)
4.13  RVRB Reverb

4.29  SEEK Seek frame
4.28  SIGN Signature frame
4.9   SYLT Synchronised lyric/text
4.7   SYTC Synchronised tempo codes

4.2.1 TALB Album/Movie/Show title
4.2.3 TBPM BPM (beats per minute)
4.2.2 TCOM Composer
4.2.3 TCON Content type
4.2.4 TCOP Copyright message
4.2.5 TDEN Encoding time
4.2.5 TDLY Playlist delay
4.2.5 TDOR Original release time
4.2.5 TDRC Recording time
4.2.5 TDRL Release time
4.2.5 TDTG Tagging time
4.2.2 TENC Encoded by
4.2.2 TEXT Lyricist/Text writer
4.2.3 TFLT File type
4.2.2 TIPL Involved people list
4.2.1 TIT1 Content group description
4.2.1 TIT2 Title/songname/content description
4.2.1 TIT3 Subtitle/Description refinement
4.2.3 TKEY Initial key
4.2.3 TLAN Language(s)
4.2.3 TLEN Length
4.2.2 TMCL Musician credits list
4.2.3 TMED Media type
4.2.3 TMOO Mood
4.2.1 TOAL Original album/movie/show title
4.2.5 TOFN Original filename
4.2.2 TOLY Original lyricist(s)/text writer(s)
4.2.2 TOPE Original artist(s)/performer(s)
4.2.4 TOWN File owner/licensee
4.2.2 TPE1 Lead performer(s)/Soloist(s)
4.2.2 TPE2 Band/orchestra/accompaniment
4.2.2 TPE3 Conductor/performer refinement
4.2.2 TPE4 Interpreted, remixed, or otherwise modified by
4.2.1 TPOS Part of a set
4.2.4 TPRO Produced notice
4.2.4 TPUB Publisher
4.2.1 TRCK Track number/Position in set
4.2.4 TRSN Internet radio station name
4.2.4 TRSO Internet radio station owner
4.2.5 TSOA Album sort order
4.2.5 TSOP Performer sort order
4.2.5 TSOT Title sort order
4.2.1 TSRC ISRC (international standard recording code)
4.2.5 TSSE Software/Hardware and settings used for encoding
4.2.1 TSST Set subtitle
4.2.2 TXXX User defined text information frame

4.1   UFID Unique file identifier
4.22  USER Terms of use
4.8   USLT Unsynchronised lyric/text transcription

4.3.1 WCOM Commercial information
4.3.1 WCOP Copyright/Legal information
4.3.1 WOAF Official audio file webpage
4.3.1 WOAR Official artist/performer webpage
4.3.1 WOAS Official audio source webpage
4.3.1 WORS Official Internet radio station homepage
4.3.1 WPAY Payment
4.3.1 WPUB Publishers official webpage
4.3.2 WXXX User defined URL link frame
*/

let id3frames: [String: String] = [
    "id3/TPE1": "歌手",
    "id3/TPE2": "歌手",
    "id3/TIT2": "标题",
    "id3/TALB": "专辑",
    "id3/COMM": "注释",
    "id3/TCON": "流派",
    "id3/TDRC": "年代",
    "id3/TYER": "年代",
    "id3/TDAT": "日期",
    "id3/TRCK": "音轨",
    "id3/TXXX": "其他"
]

func transforidentifier(tagname: String) -> String {
    var transname: String = tagname
    if id3frames.indexForKey(tagname) != nil {
        transname = id3frames[tagname]!
    }
    return transname
}

class Music: NSObject {
    var url: NSURL!
    
    var title: String = ""
    var artist: String = ""
    var album: String = ""
    var track: String = ""
    var duration: CMTime!
    
    var durationString: String {
        get {
            if (self.duration != nil) {
                let duration = Int(round(CMTimeGetSeconds(self.duration)))
                return NSString(format: "%i:%02i", duration / 60, duration % 60) as String
            } else {
                return "-0:00"
            }
        }
    }
    
    func match(str: String) -> Bool{
        if title =~ str || artist =~ str || album =~ str || track =~ str {
            return true
        }
        return false
    }
    
    var metadata: [String : String] = [:]
    
    init?(path: NSURL) {
        super.init()
        url = path
        if let audio = AVURLAsset(URL: path, options: nil) {
            duration = audio.duration
            for item in audio.metadata as! [AVMetadataItem] {
                if let key = item.identifier {
                    if let value = item.stringValue {
                        metadata.updateValue(value, forKey: transforidentifier(key))
                    }
                }
            }
        } else {
            return nil
        }
        setProps()
    }
    
    init(data: NSDictionary) {
        super.init()
        self.data = data
    }
    
    func setProps() {
        if let str = metadata["标题"] {
            title = str
        }
        if let str = metadata["歌手"] {
            artist = str
        }
        if let str = metadata["专辑"] {
            album = str
        }
        if let str = metadata["音轨"] {
            track = str
        }
    }
    
    var metadataArray: [(key: String, value: String)] {
        get {
            var map = metadata
            var meta: [(key: String, value: String)] = []
            let order: [String] = ["标题", "歌手", "专辑", "音轨", "年代", "日期", "流派", "注释"]
            for one in order {
                if let value = map[one] {
                    meta.append((key: one, value: value))
                    map.removeValueForKey(one)
                }
            }
            for (key, value) in map {
                meta.append((key: key, value: value))
            }
            return meta
        }
    }
    
    var data: NSDictionary {
        get {
            let data = ["url": url.path!, "metadata": metadata, "duration": CMTimeCopyAsDictionary(duration, nil)]
            return data
        }
        set {
            let data = newValue
            url = NSURL(fileURLWithPath: data["url"] as! String)
            metadata = (data["metadata"] as? [String : String])!
            duration = CMTimeMakeFromDictionary(data["duration"] as! CFDictionary)
            setProps()
            // 考虑：文件不存在了，但仍要在播放列表里存在
            // 这时，需要在播放的时候延迟加载该文件
        }
    }

}
