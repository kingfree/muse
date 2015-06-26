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
    
    var onemusic: Music?
    var nowselect: Music! {
        get {
            if onemusic == nil {
                return PlayList.sharedInstance.nowplaying
            }
            return onemusic
        }
        set {
            onemusic = newValue
        }
    }
    
    var musiclist: [Music]?
    var playlist: [Music] {
        get {
            if musiclist != nil {
                return self.musiclist!
            }
            return PlayList.sharedInstance.playinglist
        }
        set {
            musiclist = newValue
        }
    }
    
    @IBOutlet var playlistController: NSArrayController!
    
    override func viewWillAppear() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
            }
        }
    }
    
    var musicPlayer: AVAudioPlayer!
    
    @IBOutlet weak var playPauseButtom: NSButton!
    
    @IBAction func playPauseMusic(sender: AnyObject) {
        let pl = PlayList.sharedInstance
        println(playPauseButtom.title)
        if musicPlayer != nil {
            if musicPlayer.rate == 0.0 {
                playPauseButtom.title = "暂停"
                musicPlayer.play()
            } else {
                println(musicPlayer.currentTime)
                playPauseButtom.title = "播放"
                musicPlayer.pause()
            }
        } else if let music = pl.nowplaying {
            setPlayingMusic(music)
            println(music.title)
            musicPlayer.play()
            playPauseButtom.title = "暂停"
        } else if let music = nowselect {
            setPlayingMusic(music)
            println(music.title)
            musicPlayer.play()
            playPauseButtom.title = "暂停"
        }
    }
    
    @IBAction func changePrevMusic(sender: AnyObject) {
        let rate = musicPlayer.rate
        setPlayingMusic(PlayList.sharedInstance.getPrevMusic())
        musicPlayer.rate = rate
    }
    
    @IBAction func changeNextMusic(sender: AnyObject) {
        let rate = musicPlayer.rate
        setPlayingMusic(PlayList.sharedInstance.getNextMusic())
        musicPlayer.rate = rate
    }
    
    func setPlayingMusic(music: Music) {
        let pl = PlayList.sharedInstance
        pl.nowplaying = music
        self.nowselect = music
        musicPlayer = AVAudioPlayer(contentsOfURL: music.url, error: nil)
        musicPlayer.delegate = self
        musicPlayer.prepareToPlay()
        println(music.title)
    }
    
    func audioPlayerDidFinishPlaying(sender player: AVAudioPlayer!,
        successfully flag: Bool) {
            if player == musicPlayer {
                setPlayingMusic(PlayList.sharedInstance.getNextMusic())
            }
    }
    
    @IBOutlet weak var volumeSlider: NSSlider!
    
    @IBAction func volumeChange(sender: AnyObject) {
        if let player = musicPlayer {
            player.volume = Float(volumeSlider.doubleValue / volumeSlider.maxValue)
        }
    }
    
    @IBOutlet weak var searchField: NSSearchField!
    
    @IBAction func searchMusicIn(sender: AnyObject) {
        let str = sender.stringValue
        musiclist = PlayList.sharedInstance.searchMusic(str)
        playlistTableView.reloadData()
    }
    
    
    @IBAction func selectMusic(sender: AnyObject) {
        for i in playlistTableView.selectedRowIndexes {
            if i >= 0 && i < playlist.count {
                nowselect = playlist[i]
            }
        }
        self.tagTableView.reloadData()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        if tableView == tagTableView {
            if let music = nowselect {
                return music.metadataArray.count
            }
        } else if tableView == playlistTableView {
            return playlist.count
        }
        return 0
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        let cell = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as! NSTableCellView
        let textField = cell.textField
        if tableView == tagTableView {
            if let music = nowselect {
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
            if playlist.count >= row {
                let music = playlist[row]
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
                        playlist.sort({ (a, b) -> Bool in
                            return a.title < b.title
                        });
                    case ("title", false):
                        playlist.sort({ (a, b) -> Bool in
                            return a.title > b.title
                        });
                    case ("artist", true):
                        playlist.sort({ (a, b) -> Bool in
                            return a.artist < b.artist
                        });
                    case ("artist", false):
                        playlist.sort({ (a, b) -> Bool in
                            return a.artist > b.artist
                        });
                    case ("album", true):
                        playlist.sort({ (a, b) -> Bool in
                            return a.album < b.album
                        });
                    case ("album", false):
                        playlist.sort({ (a, b) -> Bool in
                            return a.album > b.album
                        });
                    case ("track", true):
                        playlist.sort({ (a, b) -> Bool in
                            return a.track < b.track
                        });
                    case ("track", false):
                        playlist.sort({ (a, b) -> Bool in
                            return a.track > b.track
                        });
                    case ("duration", true):
                        playlist.sort({ (a, b) -> Bool in
                            return CMTimeCompare(a.duration, b.duration) < 0
                        });
                    case ("duration", false):
                        playlist.sort({ (a, b) -> Bool in
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
