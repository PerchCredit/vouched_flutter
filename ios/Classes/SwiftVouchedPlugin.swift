import Flutter
import UIKit
import Vouched
import AVKit

func getValue(key:String)-> String? {
    let v = Bundle.main.infoDictionary?[key] as? String
    if v == "" {
        return nil
    }
    return v
}

public class SwiftVouchedPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let viewFactory = CardViewFactory(messenger: registrar.messenger())
        registrar.register(viewFactory, withId: "vouchedScannerCardView")
    }
    
}

public class CardViewFactory: NSObject, FlutterPlatformViewFactory {
    
    // MARK: - Variables
    
    let messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return CardDisplayView(messenger: messenger, frame: frame, viewId: viewId, args: args)
    }
}


public class CardDisplayView: NSObject, FlutterPlatformView, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Variables
    
    var captureSession = AVCaptureSession()
    let cardDetect = CardDetect(options: CardDetectOptionsBuilder().withEnableDistanceCheck(true).build())
    let session = VouchedSession(apiKey: getValue(key:"API_KEY"))
    let cameraView: UIView
    var channel: FlutterMethodChannel
    
    init(messenger: FlutterBinaryMessenger, frame: CGRect, viewId: Int64, args: Any?) {
        let screenSize: CGSize = UIScreen.main.bounds.size
        self.cameraView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.channel = FlutterMethodChannel(name: "vouched_plugin", binaryMessenger: messenger)
        
        super.init()
        self.channel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            if (call.method == "startAuth") {
                let args = call.arguments as? [String: Any]
                let height =  args?["height"] as? Double
                let width = args?["width"] as? Double
                self.setupCamera(height ?? 0.0, width ?? 0.0)
            }
        })
    }
    
    public func view() -> UIView {
        return cameraView
    }
    
    func setupCamera(_ height: Double, _ width: Double) {
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Unable to access back camera!")
            return
        }
        
        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch {
            return
        }
        
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        
        let queue = DispatchQueue(label: "cameraQueue")
        output.setSampleBufferDelegate(self, queue: queue)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: kCVPixelFormatType_32BGRA]
        
        startCapture(input: input, output: output, height: height, width: width)
    }
    
    func startCapture(input: AVCaptureDeviceInput, output: AVCaptureVideoDataOutput, height: Double, width: Double) {
        captureSession = AVCaptureSession()
        captureSession.addInput(input)
        captureSession.addOutput(output)
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspect
        previewLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        cameraView.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let detectedCard = self.cardDetect.detect(imageBuffer!)
        if let detectedCard = detectedCard {
            switch detectedCard.step {
            case .preDetected:
                self.channel.invokeMethod("showInstruction", arguments: getInstructionString(detectedCard.instruction))
                print(detectedCard.instruction)
                break
            case .detected:
                print(detectedCard.instruction)
                self.channel.invokeMethod("showInstruction", arguments: getInstructionString(detectedCard.instruction))
                break
            case .postable:
                self.channel.invokeMethod("showIndicator", arguments: true)
                captureSession.stopRunning()
                do {
                    let job: Job?
                    job = try session.postFrontId(detectedCard: detectedCard)
                    let retryableErrors = VouchedUtils.extractRetryableIdErrors(job)
                    if !retryableErrors.isEmpty {
                        self.channel.invokeMethod("errorReceived", arguments: nil)
                        return;
                    }
                    else {
                        let id = job?.id ?? ""
                        let firstName = job?.result.firstName ?? ""
                        let lastName = job?.result.lastName ?? ""
                        let issueDate = job?.result.issueDate ?? ""
                        let expiryDate = job?.result.expireDate ?? ""
                        let state = job?.result.state ?? ""
                        let country = job?.result.country ?? ""
                        self.channel.invokeMethod("dataReceived", arguments: ["id": id, "firstName": firstName, "lastName": lastName, "issueDate": issueDate, "expiryDate": expiryDate, "state": state, "country": country])
                    }
                } catch {
                    self.channel.invokeMethod("errorReceived", arguments: ["error": error.localizedDescription])
                    captureSession.startRunning()
                }
            default:
                break
            }
        }
    }
    
    func getInstructionString(_ instruction: Instruction) -> String {
        var instructionString: String
        switch instruction {
        case .moveCloser:
            instructionString = "Move Closer"
        case .moveAway:
            instructionString = "Move Away"
        case .holdSteady:
            instructionString = "Hold Steady"
        case .onlyOne:
            instructionString = "Multiple IDs"
        default:
            instructionString = "Show ID"
        }
        return instructionString
    }
}
