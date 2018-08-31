import HaishinKit
import VideoToolbox
import ReplayKit
import Logboard

open class SampleHandler: RPBroadcastSampleHandler {
    var broadcaster: RTMPBroadcaster = RTMPBroadcaster()
    
    var spliter: SoundSpliter?
    
    override init() {
        super.init()
        spliter = SoundSpliter()
        spliter?.delegate = self
    }
    
    override open func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
//        let logger = Logboard.with(HaishinKitIdentifier)
//        let socket = SocketAppender()
//        socket.connect("192.168.0.110", port: 3000)
//        logger.level = .debug
//        logger.appender = socket
 
        print("broadcastStarted")
        super.broadcastStarted(withSetupInfo: setupInfo)
//        guard
//            let endpointURL: String = setupInfo?["endpointURL"] as? String,
//            let streamName: String = setupInfo?["streamName"] as? String else {
//                return
//        }
        let key = String.random()
        RoomHandler.shared.createRoom(title: "test",key: key)
        broadcaster.streamName = key
        broadcaster.connect(Config.rtmpPushUrl, arguments: nil)
    }
    
    override open func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
            if let description: CMVideoFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
                let dimensions: CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(description)
                broadcaster.stream.videoSettings = [
                    "width": dimensions.width,
                    "height": dimensions.height ,
                    "profileLevel": kVTProfileLevel_H264_Baseline_AutoLevel
                ]
            }
            broadcaster.appendSampleBuffer(sampleBuffer, withType: .video)
        case .audioApp:
            spliter?.appendSampleBuffer(sampleBuffer)
            break
        case .audioMic:
            broadcaster.appendSampleBuffer(sampleBuffer, withType: .audio)
            break
        }
    }
}

extension SampleHandler: SoundSpliterDelegate {
    // MARK: SoundSpliterDelegate
    public func outputSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        broadcaster.appendSampleBuffer(sampleBuffer, withType: .audio)
    }
}

