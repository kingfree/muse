//
//  AppDelegate.swift
//  muse
//
//  Created by 咲衣憧 on 15/6/23.
//  Copyright (c) 2015年 Kingfree. All rights reserved.
//

import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func openFileDialog(sender: NSMenuItem) {
        
        var openDialog: NSOpenPanel = NSOpenPanel()
        var fileTypeArray: [String] = "mp3".componentsSeparatedByString(",")
        
        openDialog.prompt = "Open"
        openDialog.worksWhenModal = true
        openDialog.allowsMultipleSelection = false
        openDialog.canChooseDirectories = false
        openDialog.resolvesAliases = true
        openDialog.title = "打开音乐"
        openDialog.allowedFileTypes = fileTypeArray
        
        let void = openDialog.runModal()
        var path = openDialog.URL
        println(path)
        
        let music = AVURLAsset(URL: path, options: nil)
        println(music.metadata)
    }
}

