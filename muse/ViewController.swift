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
        var fileTypeArray: [String] = "mp3".componentsSeparatedByString(",")
        
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
            println(pl.nowplaying.metadata())
            self.tagTableView.reloadData()
        }
        
    }
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int
    {
        let pl = PlayList.sharedInstance
        if let music = pl.nowplaying {
            return music.metadata().count
        }
        return 0
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        let pl = PlayList.sharedInstance
        if let music = pl.nowplaying {
            let item: [String: String] = (music.metadata())[row]
            println(item)
            println(tableColumn)
            if let col: String = tableColumn!.identifier {
                println(col)
                if col == "标签" {
                    return item["标签"]!
                } else if col == "值" {
                    return item["值"]!
                }
            }
        }
        return "none"
    }
}
