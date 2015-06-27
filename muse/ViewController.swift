//
//  ViewController.swift
//  muse
//
//  Created by 咲衣憧 on 15/6/23.
//  Copyright (c) 2015年 Kingfree. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var tagTableView: NSTableView!
    
    @IBOutlet weak var playlistTableView: NSTableView!
    
    var nowselected: Music! {
        get {
            return PlayList.sharedInstance.nowselected
        }
        set {
            PlayList.sharedInstance.nowselected = newValue
        }
    }
    
    var nowplaying: Music! {
        get {
            return PlayList.sharedInstance.nowplaying
        }
        set {
            PlayList.sharedInstance.nowplaying = newValue
        }
    }
    
    var playinglist: [Music] {
        get {
            return PlayList.sharedInstance.playinglist
        }
        set {
            PlayList.sharedInstance.playinglist = newValue
        }
    }
    
    var playlist: [Music] {
        get {
            return PlayList.sharedInstance.playlist
        }
        set {
            PlayList.sharedInstance.playlist = newValue
        }
    }
    
    @IBOutlet var playlistController: NSArrayController!
    
    override func viewWillAppear() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playlistTableView.target = self
        playlistTableView.doubleAction = "doubleClickItem:"
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func openFile(sender: AnyObject) {
        
        var panel: NSOpenPanel = NSOpenPanel()
        var fileTypeArray: [String] = "mp3,ape,flac".componentsSeparatedByString(",")
        
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.resolvesAliases = true
        panel.title = "打开音乐"
        panel.allowedFileTypes = fileTypeArray
        
        panel.beginWithCompletionHandler { (result : Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                let pl = PlayList.sharedInstance
                var files = panel.URLs as! [NSURL]
                for file in files {
                    pl.setNowPlaying(file)
                    pl.addMusic(pl.nowplaying)
                    self.tagTableView.reloadData()
                    self.playlistTableView.reloadData()
                }
                self.nowselected = self.playinglist[0]
            }
        }
    }
    
    var musicPlayer: AVAudioPlayer!
    
    @IBOutlet weak var playPauseButtom: NSButton!
    
    @IBAction func playPauseMusic(sender: AnyObject) {
        let pl = PlayList.sharedInstance
        if musicPlayer != nil {
            if musicPlayer.playing {
                doPlayMusic()
            } else {
                doPauseMusic()
            }
        } else if let music = pl.nowplaying {
            setPlayingMusic(music)
            doPlayMusic()
        } else if let music = nowplaying {
            setPlayingMusic(music)
            doPlayMusic()
        }
    }
    
    func doPlayMusic() {
        playPauseButtom.title = "暂停"
        musicPlayer.play()
        print("正在播放： ")
        println(nowplaying.title)
    }
    
    func doPauseMusic() {
        playPauseButtom.title = "播放"
        musicPlayer.pause()
    }
    
    @IBAction func changePrevMusic(sender: AnyObject) {
        let isPlay = musicPlayer.playing
        setPlayingMusic(PlayList.sharedInstance.getPrevMusic())
        if isPlay {
            doPlayMusic()
        }
    }
    
    @IBAction func changeNextMusic(sender: AnyObject) {
        let isPlay = musicPlayer.playing
        setPlayingMusic(PlayList.sharedInstance.getNextMusic())
        if isPlay {
            doPlayMusic()
        }
    }
    
    func setPlayingMusic(music: Music) {
        nowplaying = music
        var error: NSError?
        musicPlayer = AVAudioPlayer(contentsOfURL: music.url, error: &error)
        if error != nil {
            println(error)
            return
        }
        musicPlayer.delegate = self
        setVolumeFromSlider()
        musicPlayer.prepareToPlay()
        println(music.title)
    }
    
    func setVolumeFromSlider() {
        if let player = musicPlayer {
            player.volume = Float(volumeSlider.doubleValue / volumeSlider.maxValue)
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        if player == musicPlayer {
            setPlayingMusic(PlayList.sharedInstance.getNextMusic())
            doPlayMusic()
        }
    }
    
    @IBOutlet weak var volumeSlider: NSSlider!
    
    @IBAction func volumeChange(sender: AnyObject) {
        setVolumeFromSlider()
    }
    
    @IBOutlet weak var searchField: NSSearchField!
    
    @IBAction func searchMusicIn(sender: AnyObject) {
        let str = sender.stringValue
        PlayList.sharedInstance.searchMusic(str)
        playlistTableView.reloadData()
    }
    
    @IBAction func selectMusic(sender: AnyObject) {
        let i = playlistTableView.clickedRow
        if i >= 0 && i < playinglist.count {
            nowselected = playinglist[i]
        }
        if musicPlayer == nil {
            setPlayingMusic(nowselected)
        }
        self.tagTableView.reloadData()
    }
    
    func doubleClickItem(sender: AnyObject) {
        let i = playlistTableView.clickedRow
        if i >= 0 && i < playinglist.count {
            nowselected = playinglist[i]
        }
        setPlayingMusic(nowselected)
        doPlayMusic()
        self.tagTableView.reloadData()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        if tableView == tagTableView {
            if nowselected != nil {
                return nowselected.metadataArray.count
            }
        } else if tableView == playlistTableView {
            return playinglist.count
        }
        return 0
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        let cell = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as! NSTableCellView
        let textField = cell.textField
        if tableView == tagTableView {
            let music = nowselected
            if music.metadataArray.count > row {
                let item: (key: String, value: String) = music.metadataArray[row]
                if let col: String = tableColumn!.identifier {
                    if col == "key" {
                        textField?.stringValue = item.key
                    } else if col == "value" {
                        textField?.stringValue = item.value
                    }
                }
            }
        } else if tableView == playlistTableView {
            if playinglist.count > row {
                let music = playinglist[row]
                if let col: String = tableColumn!.identifier {
                    switch col {
                    case "title":
                        textField?.stringValue = music.title
                    case "artist":
                        textField?.stringValue = music.artist
                    case "album":
                        textField?.stringValue = music.album
                    case "track":
                        textField?.stringValue = music.track
                    case "duration":
                        textField?.stringValue = music.durationString
                    default:
                        break
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: NSTableView!, sortDescriptorsDidChange oldDescriptors: [AnyObject]!) {
        if tableView == playlistTableView {
            if let marks = tableView.sortDescriptors as? [NSSortDescriptor] {
                if let mark = marks[0].key() {
                    let asc = marks[0].ascending
                    switch (mark, asc) {
                    case ("title", true):
                        playinglist.sort({ (a, b) -> Bool in
                            return a.title < b.title
                        });
                    case ("title", false):
                        playinglist.sort({ (a, b) -> Bool in
                            return a.title > b.title
                        });
                    case ("artist", true):
                        playinglist.sort({ (a, b) -> Bool in
                            return a.artist < b.artist
                        });
                    case ("artist", false):
                        playinglist.sort({ (a, b) -> Bool in
                            return a.artist > b.artist
                        });
                    case ("album", true):
                        playinglist.sort({ (a, b) -> Bool in
                            return a.album < b.album
                        });
                    case ("album", false):
                        playinglist.sort({ (a, b) -> Bool in
                            return a.album > b.album
                        });
                    case ("track", true):
                        playinglist.sort({ (a, b) -> Bool in
                            return a.track < b.track
                        });
                    case ("track", false):
                        playinglist.sort({ (a, b) -> Bool in
                            return a.track > b.track
                        });
                    case ("duration", true):
                        playinglist.sort({ (a, b) -> Bool in
                            return CMTimeCompare(a.duration, b.duration) < 0
                        });
                    case ("duration", false):
                        playinglist.sort({ (a, b) -> Bool in
                            return CMTimeCompare(a.duration, b.duration) > 0
                        });
                    default:
                        break
                    }
                    tableView.reloadData()
                }
            }
        }
    }
}
