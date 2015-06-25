//
//  ViewController.swift
//  muse
//
//  Created by 咲衣憧 on 15/6/23.
//  Copyright (c) 2015年 Kingfree. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    
    @IBOutlet weak var tagTableView: NSTableView!
    
    @IBOutlet weak var playlistTableView: NSTableView!
    
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
        
        var openDialog: NSOpenPanel = NSOpenPanel()
        var fileTypeArray: [String] = "mp3,ape,flac".componentsSeparatedByString(",")
        
        openDialog.prompt = "Open"
        openDialog.worksWhenModal = true
        openDialog.allowsMultipleSelection = false
        openDialog.canChooseDirectories = false
        openDialog.resolvesAliases = true
        openDialog.title = "打开音乐"
        openDialog.allowedFileTypes = fileTypeArray
        
        if openDialog.runModal() == NSFileHandlingPanelOKButton {
            var path = openDialog.URL
            println(path)
            
            let pl = PlayList.sharedInstance
            pl.setNowPlaying(path!)
            tagTableView.reloadData()
            playlistTableView.reloadData()
        }
        
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        let pl = PlayList.sharedInstance
        if tableView == tagTableView {
            if let music = pl.nowplaying {
                return music.metadataArray.count
            }
        } else if tableView == playlistTableView {
            return pl.playinglist.count
        }
        return 0
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        println(tableView)
        let cell = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as! NSTableCellView
        let textField = cell.textField
        let pl = PlayList.sharedInstance
        if tableView == tagTableView {
            if let music = pl.nowplaying {
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
            println(pl.playinglist.count)
            println(row)
            if pl.playinglist.count >= row {
                let music = pl.playinglist[row]
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
                        let durationText = NSString(format: "%i:%02i",
                            music.duration.value / 60,
                            music.duration.value % 60)
                        textField?.stringValue = durationText as String
                    default:
                        break
                    }
                }
            }
        }
        return cell
    }
}
