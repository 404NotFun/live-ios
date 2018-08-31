import ReplayKit

class BroadcastViewController: UIViewController {
    @IBOutlet var startButton: UIButton!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet var endpointURLField: UITextField!
    
    @IBOutlet var streamNameField: UITextField!
    
    @IBAction func startBtnTapped(_ sender: Any) {
        NSLog("%s", "Started")
        self.userDidFinishSetup()
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        NSLog("%s", "Canceled")
        self.userDidCancelSetup()
    }
    
    
    func userDidFinishSetup() {
        
        let broadcastURL: URL = URL(string: endpointURLField.text!)!
        
        let streamName: String = streamNameField.text!
        let endpointURL: String = endpointURLField.text!
        let setupInfo: [String: NSCoding & NSObjectProtocol] =  [
            "endpointURL": endpointURL as NSString,
            "streamName": streamName as NSString
        ]
        
        let broadcastConfiguration: RPBroadcastConfiguration = RPBroadcastConfiguration()
        broadcastConfiguration.clipDuration = 2
        broadcastConfiguration.videoCompressionProperties = [
            AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel as NSSecureCoding & NSObjectProtocol
        ]
        
        self.extensionContext?.completeRequest(
            withBroadcast: broadcastURL,
            broadcastConfiguration: broadcastConfiguration,
            setupInfo: setupInfo
        )
    }
    
    func userDidCancelSetup() {
        let error = NSError(domain: "com.haishinkit.HaishinKit", code: -1, userInfo: nil)
        self.extensionContext?.cancelRequest(withError: error)
    }
}

