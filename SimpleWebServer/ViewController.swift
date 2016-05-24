//
//  ViewController.swift
//  SimpleWebServer
//
//  Created by TmRocha89 on 23/05/16.
//  Copyright © 2016 TmRocha89. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var btnStartStop: NSButton!
    
    @IBOutlet weak var textFieldPath: NSTextField!
    @IBOutlet weak var textPort: NSTextField!
    
    var webserverTask:NSTask?
    
    @IBOutlet weak var textFieldOutput: NSTextField!
    var isRunning:Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func btnFind(sender: AnyObject) {
        let openPanel:NSOpenPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = false
        let option = openPanel.runModal()
        
        if(option == NSModalResponseOK){
            self.textFieldPath.stringValue = (openPanel.URL?.absoluteString)!
        }
        
        print("find button")
    }

    
    @IBAction func startStopServer(sender: AnyObject) {
        if(isRunning){
            isRunning = false
            webserverTask!.terminate()
        } else {
            print("webserver button \(textFieldPath.stringValue).\(String(textPort.intValue)).. ")
            let range = Range(start: 0,end: 6)
            let dirPath = textFieldPath.stringValue.substringFromIndex("file://".endIndex)
            startServerScript([ dirPath, String(textPort.intValue)])
        }
    }

    
    
    func startServerScript(arguments:[String])->Void{
        
        let taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        
        
            dispatch_async(taskQueue) {
                
                guard let path = NSBundle.mainBundle().pathForResource("SimpleWebServer",ofType:"command") else {
                    print("Unable to locate BuildScript.command")
                    return
                }
                
                self.webserverTask = NSTask()
                self.webserverTask!.launchPath = path
                self.webserverTask!.arguments = arguments
                

                
                self.captureOutput(self.webserverTask!)
                self.captureErrorOutput(self.webserverTask!)
                
                self.webserverTask?.terminationHandler = {
                    task in
                    print("FIMMMMMM")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.isRunning = false
                        self.updateUI()
                    })
                }
                    self.isRunning = true
                    self.updateUI()
               
                
                self.webserverTask!.launch()
                
                self.webserverTask!.waitUntilExit()
        }
        
       
        
    }
    
    var outputPipe:NSPipe?
    var errorPipe:NSPipe?
    
    func captureOutput(task:NSTask){
        outputPipe = NSPipe()
        task.standardOutput = outputPipe
        
        outputPipe?.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: outputPipe!.fileHandleForReading, queue: nil, usingBlock: {
            notification in
            let output = self.outputPipe?.fileHandleForReading.availableData
            let outputString = String(data: output!, encoding: NSUTF8StringEncoding) ?? ""
            
            dispatch_async(dispatch_get_main_queue(), {
                let previousOutput = self.textFieldOutput!.stringValue ?? ""
                let nextOutput = previousOutput + "\n" + outputString
                self.textFieldOutput.stringValue = nextOutput
                
                //let range = NSRange(location:nextOutput.characters.count,length:0)
                //self.outputText.scrollRangeToVisible(range)
                
            })
        })
    }
    
    func captureErrorOutput(task:NSTask){
        errorPipe = NSPipe()
        task.standardError = errorPipe
        
        errorPipe?.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: errorPipe!.fileHandleForReading, queue: nil, usingBlock: {
            notification in
            let output = self.errorPipe?.fileHandleForReading.availableData
            let outputString = String(data: output!, encoding: NSUTF8StringEncoding) ?? ""
            
            dispatch_async(dispatch_get_main_queue(), {
                let previousOutput = self.textFieldOutput!.stringValue ?? ""
                let nextOutput = previousOutput + "\n" + outputString
                self.textFieldOutput.stringValue = nextOutput
                
            })
        })
    }
    
    
    
    func updateUI(){
        if (isRunning){
            self.btnStartStop.title = "Stop WebServer"
        }else{
            self.btnStartStop.title = "Start WebServer"
        }
    }
    
}

