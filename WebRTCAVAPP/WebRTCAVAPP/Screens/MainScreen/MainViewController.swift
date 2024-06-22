//
//  MainViewController.swift
//  WebRTCAVAPP
//
//  Created by DEEP BHUPATKAR on 22/06/24.
//


import Foundation
import UIKit
import AVFoundation
import WebRTC

class MainViewController: UIViewController {

    private var signalClient: SignalingClient!
    private var webRTCClient: WebRTCClient!
    private lazy var videoViewController = VideoViewController(webRTCClient: self.webRTCClient)
    
    @IBOutlet private weak var speakerButton: UIButton!
    @IBOutlet private weak var signalingStatusLabel: UILabel!
    @IBOutlet private weak var localSdpStatusLabel: UILabel!
    @IBOutlet private weak var localCandidatesLabel: UILabel!
    @IBOutlet private weak var remoteSdpStatusLabel: UILabel!
    @IBOutlet private weak var remoteCandidatesLabel: UILabel!
    @IBOutlet private weak var muteButton: UIButton!
    @IBOutlet private weak var webRTCStatusLabel: UILabel!
    
    private var signalingConnected: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.signalingStatusLabel.text = self.signalingConnected ? "Connected" : "Not connected"
                self.signalingStatusLabel.textColor = self.signalingConnected ? .green : .red
            }
        }
    }
    
    private var hasLocalSdp: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.localSdpStatusLabel.text = self.hasLocalSdp ? "✅" : "❌"
            }
        }
    }
    
    private var localCandidateCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.localCandidatesLabel.text = "\(self.localCandidateCount)"
            }
        }
    }
    
    private var hasRemoteSdp: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.remoteSdpStatusLabel.text = self.hasRemoteSdp ? "✅" : "❌"
            }
        }
    }
    
    private var remoteCandidateCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.remoteCandidatesLabel.text = "\(self.remoteCandidateCount)"
            }
        }
    }
    
    private var speakerOn: Bool = false {
        didSet {
            self.speakerButton.setTitle("Speaker: \(self.speakerOn ? "On" : "Off")", for: .normal)
        }
    }
    
    private var mute: Bool = false {
        didSet {
            self.muteButton.setTitle("Mute: \(self.mute ? "on" : "off")", for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("MainViewController viewDidLoad")
        self.title = "WebRTC Demo"
        
        self.resetUI()

        self.webRTCClient.delegate = self
        self.signalClient.delegate = self
        self.signalClient.connect()
    }

    func configure(signalClient: SignalingClient, webRTCClient: WebRTCClient) {
        self.signalClient = signalClient
        self.webRTCClient = webRTCClient
    }

    private func resetUI() {
        self.signalingConnected = false
        self.hasLocalSdp = false
        self.hasRemoteSdp = false
        self.localCandidateCount = 0
        self.remoteCandidateCount = 0
        self.speakerOn = false
        self.webRTCStatusLabel.text = "New"
    }
    
    @IBAction private func offerButtonTapped(_ sender: UIButton) {
        self.webRTCClient.offer { sdp in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: sdp)
        }
    }
  
    
    @IBAction private func answerButtonTapped(_ sender: UIButton) {
        self.webRTCClient.answer { localSdp in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: localSdp)
        }
    }
    @IBAction func answerButtonTapped(_ sender: Any) {
    }
    
    @IBAction private func speakerButtonTapped(_ sender: UIButton) {
        if self.speakerOn {
            self.webRTCClient.speakerOff()
        } else {
            self.webRTCClient.speakerOn()
        }
        self.speakerOn.toggle()
    }
  
    @IBAction private func videoButtonTapped(_ sender: UIButton) {
        self.present(videoViewController, animated: true, completion: nil)
    }
   
    @IBAction private func muteButtonTapped(_ sender: UIButton) {
        self.mute.toggle()
        if self.mute {
            self.webRTCClient.muteAudio()
        } else {
            self.webRTCClient.unmuteAudio()
        }
    }
 
    
    @IBAction private func sendDataButtonTapped(_ sender: UIButton) {
       
        
        let alert = UIAlertController(title: "Send a message to the other peer",
                                      message: "This will be transferred over WebRTC data channel",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Message to send"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self, unowned alert] _ in
            guard let dataToSend = alert.textFields?.first?.text?.data(using: .utf8) else { return }
            self?.webRTCClient.sendData(dataToSend)
        })
        self.present(alert, animated: true, completion: nil)
    }
}

extension MainViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        self.signalingConnected = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        self.signalingConnected = false
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("Received remote sdp")
        self.webRTCClient.set(remoteSdp: sdp) { error in
            self.hasRemoteSdp = true
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        self.webRTCClient.set(remoteCandidate: candidate) { error in
            print("Received remote candidate")
            self.remoteCandidateCount += 1
        }
    }
}

extension MainViewController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("Discovered local candidate")
        self.localCandidateCount += 1
        self.signalClient.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        let textColor: UIColor
        switch state {
        case .connected, .completed:
            textColor = .green
        case .disconnected:
            textColor = .orange
        case .failed, .closed:
            textColor = .red
        case .new, .checking, .count:
            textColor = .black
        @unknown default:
            textColor = .black
        }
        DispatchQueue.main.async {
            self.webRTCStatusLabel.text = state.description.capitalized
            self.webRTCStatusLabel.textColor = textColor
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
