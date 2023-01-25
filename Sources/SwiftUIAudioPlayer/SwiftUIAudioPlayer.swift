import SwiftUI
import AVFoundation

public class SwiftUIAudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
  /// A Boolean representing whether this sound is currently playing.
  @Published public var isPlaying = false
  
  /// These are used in our view
  @Published public var progress: CGFloat = 0.0
  @Published public var duration: Double = 0.0
  @Published public var formattedDuration: String = ""
  @Published public var formattedProgress: String = "00:00"
  @Published public private(set) var error: Error?
  
  /// The internal audio player being managed by this object.
  private var audioPlayer: AVAudioPlayer?
  private(set) var audioFileUrl: URL?
  private(set) var audioFileName: String?
  
  /// How loud to play this sound relative to other sounds in your app,
  /// specified in the range 0 (no volume) to 1 (maximum volume).
  public var volume: Double {
    didSet {
      audioPlayer?.volume = Float(volume)
    }
  }
  
  /// If the sound is played on a loop. Specifying false here
  /// (the default) will play the sound only once.
  public var repeatSound: Bool
  
  /// Creates a new instance by looking for a particular sound filename in a bundle of your choosing.of `.reset`.
  /// - Parameters:
  ///   - fileName: The name of the sound file you want to load.
  ///   - bundle: The bundle containing the sound file. Defaults to the main bundle.
  ///   - volume: How loud to play this sound relative to other sounds in your app,
  ///     specified in the range 0 (no volume) to 1 (maximum volume).
  ///   - repeatSound: if false  (the default) will play the sound only once.
  public convenience init?(fileName: String, bundle: Bundle = .main, volume: Double = 1.0, repeatSound: Bool = false) {
    guard let url = bundle.url(forResource: fileName, withExtension: nil) else {
      return nil
    }
    self.init(url: url, volume: volume, repeatSound: repeatSound)
  }
  
  public init(url: URL, volume: Double = 1.0, repeatSound: Bool = false) {
    self.volume = volume
    self.repeatSound = repeatSound
    self.audioFileUrl = url
    self.audioFileName = (url.lastPathComponent as NSString).deletingPathExtension
    
    super.init()
    
    guard let player = try? AVAudioPlayer(contentsOf: url) else {
      self.error = "Failed to load audio from \(url)."
      return
    }
    self.audioPlayer = player
    self.audioPlayer?.prepareToPlay()
    
    /// a formatter to get the duration and progress to the view
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = [ .pad ]
    
    //I need both! The formattedDuration is the string to display and duration is used when forwarding
    formattedDuration = formatter.string(from: TimeInterval(self.audioPlayer?.duration ?? 0.0))!
    duration = self.audioPlayer?.duration ?? 0.0
    
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
      if let player = self.audioPlayer {
        if !player.isPlaying {
          self.isPlaying = false
        }
        self.progress = CGFloat(player.currentTime / player.duration)
        self.formattedProgress = formatter.string(from: TimeInterval(player.currentTime))!
      }
    }
    audioPlayer?.delegate = self
  }
  
  deinit {
    audioPlayer?.stop()
  }

  /// this will play from where the sound last left off.
  public func play() {
    isPlaying = true
    audioPlayer?.play()
  }
  
  /// Stops the audio from playing.
  public func stop() {
    isPlaying = false
    audioPlayer?.stop()
  }
  
  /// Forward the current sound of 15 sec.
  public func forward() {
    if let player = self.audioPlayer {
      let increase = player.currentTime + 15
      if increase < self.duration {
        player.currentTime = increase
      } else {
        // give the user the chance to hear the end if he wishes
        player.currentTime = duration
      }
    }
  }
    
  /// Rewind the current sound of 15 sec.
  public func rewind() {
    if let player = self.audioPlayer {
      let decrease = player.currentTime - 15.0
      if decrease < 0.0 {
        player.currentTime = 0
      } else {
        player.currentTime -= 15
      }
    }
  }
  
  /// This is the delegate method of `AVAudioPlayerDelegate` - we get notified when the audio ends and we reset the button
  public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    if repeatSound  {
      play()
    } else {
      isPlaying = false
    }
  }

}
