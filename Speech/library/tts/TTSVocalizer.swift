//
// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license.
//
// Microsoft Cognitive Services (formerly Project Oxford): https://www.microsoft.com/cognitive-services
//
// Microsoft Cognitive Services (formerly Project Oxford) GitHub:
// https://github.com/Microsoft/Cognitive-Speech-TTS
//
// Copyright (c) Microsoft Corporation
// All rights reserved.
//
// MIT License:
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import AVFoundation

@objc

class TTSVocalizer: NSObject, AVAudioPlayerDelegate {
    
    static let sharedInstance = TTSVocalizer()
    
    private let synthesizer = TTSSynthesizer()
    
    private var player: AVAudioPlayer?
    
    public var muteSetting: Bool {
        didSet {
            if self.player != nil {
                if self.muteSetting == true {
                    self.player!.volume = 0.0
                }
                else {
                    self.player!.volume = 1.0
                }
            }
        }
    }
    
    private override init() {
        self.muteSetting = false
    }

    func vocalize(_ text: String) {
        self.synthesizer.synthesize(text: text) { [weak self] (data: Data) in
            do {
                self?.stopPlayer()
                let player = try AVAudioPlayer(data: data)
                if self?.muteSetting == true {
                    player.volume = 0.0
                }
                else {
                    player.volume = 1.0
                }
                try AVAudioSession.sharedInstance().setActive(false)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                player.delegate = self
                self?.player = player
                self?.player?.prepareToPlay()
                self?.player?.play()
            }
            catch {
            }
        }
    }
    
    func stopPlayer() {
        if self.player != nil {
            self.player?.stop()
            self.player = nil;
        }
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
    }
}
