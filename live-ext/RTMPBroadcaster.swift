import HaishinKit
import UIKit
import AVFoundation
import Photos
import VideoToolbox

public class RTMPBroadcaster: RTMPConnection {
    public var streamName: String?
    
    public lazy var stream: RTMPStream = {
        let rtmpStream = RTMPStream(connection: self)
        rtmpStream.captureSettings = [
            "fps": 30, // FPS
            "sessionPreset": AVCaptureSessionPreset1280x720, // input video width/height
            "continuousAutofocus": false, // use camera autofocus mode
            "continuousExposure": false, //  use camera exposure mode
        ]
        rtmpStream.audioSettings = [
            "muted": false, // mute audio
            "bitrate": 32 * 1024,
            "sampleRate": 44_100,
        ]
        rtmpStream.videoSettings = [
            "width": 640, // video output width
            "height": 360, // video output height
            "bitrate": 160 * 1024, // video output bitrate
            // "dataRateLimits": [160 * 1024 / 8, 1], optional kVTCompressionPropertyKey_DataRateLimits property
            "profileLevel": kVTProfileLevel_H264_Baseline_3_1, // H264 Profile require "import VideoToolbox"
            "maxKeyFrameIntervalDuration": 2, // key frame / sec
        ]
        // "0" means the same of input
        rtmpStream.recorderSettings = [
            AVMediaTypeAudio: [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 0,
                AVNumberOfChannelsKey: 0,
                // AVEncoderBitRateKey: 128000,
            ],
            AVMediaTypeVideo: [
                AVVideoCodecKey: AVVideoCodecH264,
                AVVideoHeightKey: 0,
                AVVideoWidthKey: 0,
                /*
                 AVVideoCompressionPropertiesKey: [
                 AVVideoMaxKeyFrameIntervalDurationKey: 2,
                 AVVideoProfileLevelKey: AVVideoProfileLevelH264Baseline30,
                 AVVideoAverageBitRateKey: 512000
                 ]
                 */
            ],
        ]
        return rtmpStream
    }()
    
    private lazy var spliter: SoundSpliter = {
        var spliter: SoundSpliter = SoundSpliter()
        spliter.delegate = self
        return spliter
    }()
    private var connecting: Bool = false
    private let lockQueue = DispatchQueue(label: "com.haishinkit.HaishinKit.RTMPBroadcaster.lock")
    
    public override init() {
        super.init()
        addEventListener(Event.RTMP_STATUS, selector: #selector(rtmpStatusEvent), observer: self)
    }
    
    deinit {
        removeEventListener(Event.RTMP_STATUS, selector: #selector(rtmpStatusEvent), observer: self)
    }
    
    override public func connect(_ command: String, arguments: Any?...) {
        lockQueue.sync {
            if connecting {
                return
            }
            connecting = true
            spliter.clear()
            super.connect(command, arguments: arguments)
        }
    }
    
    func appendSampleBuffer(_ sampleBuffer: CMSampleBuffer, withType: CMSampleBufferType, options: [NSObject: AnyObject]? = nil) {
        stream.appendSampleBuffer(sampleBuffer, withType: withType)
    }
    
    override public func close() {
        lockQueue.sync {
            self.connecting = false
            super.close()
        }
    }
    
    @objc func rtmpStatusEvent(_ status: Notification) {
        let e: Event = Event.from(status)
        guard
            let data: ASObject = e.data as? ASObject,
            let code: String = data["code"] as? String,
            let streamName: String = streamName else {
                return
        }
        switch code {
        case RTMPConnection.Code.connectSuccess.rawValue:
            stream.publish(streamName)
        default:
            break
        }
    }
}

extension RTMPBroadcaster: SoundSpliterDelegate {
    public func outputSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        stream.appendSampleBuffer(sampleBuffer, withType: .audio)
    }
}

