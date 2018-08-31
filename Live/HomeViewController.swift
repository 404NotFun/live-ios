//
//  HomeViewController.swift
//  Live
//
//  Created by leo on 16/7/11.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//
import ReplayKit
import UIKit
import SVProgressHUD

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let controller = RPBroadcastController()
    
    var rooms: [Room] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    
    @IBAction func newButtonPressed(_ sender: AnyObject) {
        createRoom()
    }
    
    @IBAction func refreshButtonPressed(_ sender: AnyObject) {
        refresh()
    }
    
    @IBAction func sharedButtonPressed(_ sender: AnyObject) {
        broadcast()
    }
    
    func broadcast() {
        if controller.isBroadcasting {
            stopBroadcast()
        }
        else {
            startBroadcast()
        }
    }
    
    func refresh() {
        SVProgressHUD.show()
        let request = URLRequest(url: URL(string: "\(Config.serverUrl)/rooms")!)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { resp, data, err in
            guard err == nil else {
                SVProgressHUD.showError(withStatus: "Error")
                return
            }
            SVProgressHUD.dismiss()
            let rooms = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [[String: AnyObject]]
            self.rooms = rooms.map {
                Room(dict: $0)
            }
            self.tableView.reloadData()
        })
    }
    
    func createRoom() {
        let vc = R.storyboard.main.broadcast()!
        present(vc, animated: true, completion: nil)
    }
    
    func joinRoom(_ room: Room) {
        let vc = R.storyboard.main.audience()!
        vc.room = room
        present(vc, animated: true, completion: nil)
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let room = rooms[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = "Room: \(room.title != "" ? room.title : room.key)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = rooms[(indexPath as NSIndexPath).row]
        joinRoom(room)
    }
    
}

extension HomeViewController: RPBroadcastActivityViewControllerDelegate {
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController, didFinishWith broadcastController: RPBroadcastController?, error: Error?) {
        guard error == nil else {
            print(error?.localizedDescription)
            broadcastActivityViewController.dismiss(animated: true, completion: nil)
            return
        }
        RPScreenRecorder.shared().isCameraEnabled = true
        RPScreenRecorder.shared().isMicrophoneEnabled = true
        //2
        broadcastActivityViewController.dismiss(animated: true) {
            //3
            broadcastController?.startBroadcast { error in
                //4
                //TODO: Broadcast might take a few seconds to load up. I recommend that you add an activity indicator or something similar to show the user that it is loading.
                //5
                if error == nil {
                    print("Broadcast started successfully!")
                    self.broadcastStarted()
                }else {
                    print(error?.localizedDescription)
                }
            }
        }
    }
    
    func startBroadcast() {
        RPBroadcastActivityViewController.load { broadcastAVC, error in
            guard error == nil else {
                print("Cannot load Broadcast Activity View Controller.")
                return
            }
            
            if let broadcastAVC = broadcastAVC {
                broadcastAVC.delegate = self
                self.present(broadcastAVC, animated: true, completion: nil)
            }
        }
    }
    
    func stopBroadcast() {
        controller.finishBroadcast { error in
            if error == nil {
                print("Broadcast ended")
                self.broadcastEnded()
            }
        }
    }
    
    func broadcastStarted() {
        // Called to update the UI when a broadcast starts.
//        broadcastButton.setTitle("Stop Broadcast", for: .normal)
//        statusLabel.text = "You are live!" // Any app that does not notify the user that they are live will be rejected in app review.
//        statusLabel.textColor = UIColor.red
//        micSwitch.isHidden = false
//        micLabel.isHidden = false
    }
    
    func broadcastEnded() {
        // Called to update the UI when a broadcast ends.
//        broadcastButton.setTitle("Start Broadcast", for: .normal)
//        statusLabel.text = "You are not live"
//        statusLabel.textColor = UIColor.black
//        micSwitch.isHidden = true
//        micLabel.isHidden = true
    }
}
