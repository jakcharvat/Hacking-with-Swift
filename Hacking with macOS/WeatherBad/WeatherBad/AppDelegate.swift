//
//  AppDelegate.swift
//  WeatherBad
//
//  Created by Jakub Charvat on 02/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    var displayMode = 0
    var weather: OpenWeatherMapResponse?
    var updateDisplayTimer: Timer?
    var fetchWeatherTimer: Timer?
    
    let weatherService = OpenWeatherMap()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let defaultSettings = [ "statusBarOption": "-1" ]
        UserDefaults.standard.register(defaults: defaultSettings)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadSettings), name: .init("SettingsChanged"), object: nil)
        
        statusItem.button?.title = "Fetching…"
        statusItem.menu = NSMenu()
        addSettingsMenuItem()
        addQuitMenuItem()
        loadSettings()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    
    @objc private func showSettings(_ sender: NSMenuItem) {
        let storyboard = NSStoryboard(name: "Main", bundle: .main)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else { return }
        
        updateDisplayTimer?.invalidate()
        
        let popoverView = NSPopover()
        popoverView.contentViewController = vc
        popoverView.behavior = .transient
        popoverView.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY)
    }
    
    @objc private func quit(_ sender: NSMenuItem) {
        NSApp.terminate(self)
    }
    
    @objc private func loadSettings() {
        displayMode = UserDefaults.standard.integer(forKey: "statusBarOption")
        configureUpdateDisplayTimer()
        
        fetchWeatherTimer?.invalidate()
        fetchWeatherTimer = Timer.scheduledTimer(withTimeInterval: 60 * 5, repeats: true, block: fetchWeather(timer:))
        fetchWeatherTimer?.tolerance = 60
        
        fetchWeather()
    }
}


//MARK: - Fetching Data
extension AppDelegate {
    @objc private func fetchWeather(timer: Timer? = nil) {
        weatherService.fetch { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                switch result {
                case .success(let weather):
                    self.weather = weather
                    self.updateDisplay()
                    self.refreshSubmenuItems()
                    
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    
    private func handleError(_ error: Error) {
        
        statusItem.menu?.removeAllItems()
        
        if let error = error as? OpenWeatherMapError, error == OpenWeatherMapError.locationDidFail {
            addHelpMenuItem()
        }
        
        addSettingsMenuItem()
        addQuitMenuItem()
        
        if let error = error as? OpenWeatherMapError {
            statusItem.button?.title = error.rawValue
            print(error)
            return
        }
        
        if error is DecodingError {
            statusItem.button?.title = "Bad Data"
            print(error)
            return
        }
        
        print(error)
        
    }
}


//MARK: - Updating Display
extension AppDelegate {
    private func updateDisplay() {
        guard let weather = weather else { return }
        var text = "Error"
        
        switch displayMode {
        case 0:
            if let summary = weather.summary {
                text = summary
            }
        case 1:
            text = weather.temperature
        case 2:
            text = "Rain: \(weather.precipitation)"
        case 3:
            text = "Clouds: \(weather.cloudCover)"
        default:
            break
        }
        
        statusItem.button?.title = text
    }
    
    
    private func refreshSubmenuItems() {
        guard let weather = weather else { return }
        statusItem.menu?.removeAllItems()
        
        addTitleItem()
        
        for hour in weather.hours {
            let title = "\(hour.time): \(hour.description) (\(hour.temperature))"
            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            
            statusItem.menu?.addItem(menuItem)
        }
        
        
        statusItem.menu?.addItem(.separator())
        
        addSettingsMenuItem()
        addQuitMenuItem()
        
        statusItem.menu?.addItem(.separator())
        
        addLastUpdateItem()
    }
    
    
    private func changeDisplayMode(timer: Timer? = nil) {
        displayMode += 1
        
        if displayMode > 3 {
            displayMode = 0
        }
        
        updateDisplay()
    }
    
    
    func configureUpdateDisplayTimer() {
        guard let statusBarMode = UserDefaults.standard.string(forKey: "statusBarOption") else { return }
        
        if statusBarMode == "-1" {
            displayMode = 0
            updateDisplayTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: changeDisplayMode(timer:))
            updateDisplayTimer?.tolerance = 5
        } else {
            updateDisplayTimer?.invalidate()
        }
    }
}


//MARK: - Menu Items
extension AppDelegate {
    private func addSettingsMenuItem() {
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(showSettings(_:)), keyEquivalent: "")
        statusItem.menu?.addItem(settingsItem)
    }
    
    private func addQuitMenuItem() {
        let quitItem = NSMenuItem(title: "Quit WeatherBad", action: #selector(quit(_:)), keyEquivalent: "q")
        statusItem.menu?.addItem(quitItem)
    }
    
    private func addTitleItem() {
        let attrs: [NSAttributedString.Key : Any] = [
            .font: NSFont.boldSystemFont(ofSize: 14)
        ]
        let attrString = NSAttributedString(string: "Forecast for the next 12 hours:", attributes: attrs)
        
        let labelItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        labelItem.attributedTitle = attrString
        
        statusItem.menu?.addItem(labelItem)
    }
    
    private func addLastUpdateItem() {
        guard let weather = weather else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        
        let updateTimeItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        updateTimeItem.attributedTitle = NSAttributedString(string: "Last update: \(weather.updateTime)", attributes: [
            .paragraphStyle: paragraphStyle
        ])
        
        statusItem.menu?.addItem(updateTimeItem)
    }
    
    private func addHelpMenuItem() {
        let helpItem = NSMenuItem(title: "What does this mean?", action: #selector(showHelpPopup(_:)), keyEquivalent: "")
        
        statusItem.menu?.addItem(helpItem)
        statusItem.menu?.addItem(.separator())
    }
}


//MARK: - Help Menu
extension AppDelegate {
    @objc private func showHelpPopup(_ sender: NSMenuItem) {
        let storyboard = NSStoryboard(name: "Main", bundle: .main)
        guard let vc = storyboard.instantiateController(withIdentifier: "HelpVC") as? NSViewController else { return }
        guard let button = statusItem.button else { return }
        
        let popover = NSPopover()
        popover.contentViewController = vc
        popover.behavior = .transient
        popover.show(relativeTo: button.frame, of: button, preferredEdge: .maxY)
    }
}
