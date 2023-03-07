//
//  Created by Sean Li on 2023/1/25.
//

import SwiftUI

public struct SwiftUIAudioPlayerView: View {
  @EnvironmentObject
  var audioPlayer: SwiftUIAudioPlayer
  
  let barColor: Color
  let progressColor: Color
  let showFileName: Bool
  
  public init(barColor: Color = .accentColor,
              progressColor: Color = .accentColor,
              showFileName: Bool = false)
  {
    self.barColor = barColor
    self.progressColor = progressColor
    self.showFileName = showFileName
  }
  
  public var body: some View {
    VStack {
      if showFileName {
        Text(audioPlayer.audioFileName ?? "")
          .bold()
          .multilineTextAlignment(.center)
          .font(.title)
          .minimumScaleFactor(0.75)
          .padding()
      }
      
      HStack {
        Text(audioPlayer.formattedProgress)
          .font(.caption.monospacedDigit())
        
        /// this is a dynamic length progress bar
        GeometryReader { gr in
          Capsule()
            .stroke(barColor, lineWidth: 2)
            .background(
              Capsule()
                .foregroundColor(progressColor)
                .frame(width: gr.size.width * audioPlayer.progress, height: 8),
              alignment: .leading)
        }
        .frame( height: 8)
        
        Text(audioPlayer.formattedDuration)
          .font(.caption.monospacedDigit())
      }
      .padding()
      .frame(height: 50, alignment: .center)
      .accessibilityElement(children: .ignore)
      .accessibility(identifier: "audio player")
      .accessibilityLabel(audioPlayer.isPlaying ? Text("Playing at ") : Text("Duration"))
      .accessibilityValue(Text("\(audioPlayer.formattedProgress)"))
      
      /// the control buttons
      HStack(alignment: .center, spacing: 20) {
        Spacer()
        Button(action: {
          /// back 15 sec
          audioPlayer.rewind()
        }) {
          Image(systemName: "gobackward.15")
            .font(.title)
            .imageScale(.medium)
        }
        
        /// main playing button
        Button(action: {
          if audioPlayer.isPlaying {
            audioPlayer.stop()
            audioPlayer.isPlaying = false
          } else if !audioPlayer.isPlaying {
            audioPlayer.play()
          }
        }) {
          Image(systemName: audioPlayer.isPlaying ?
                "pause.circle.fill" : "play.circle.fill")
          .font(.title)
          .imageScale(.large)
        }
        
        Button(action: {
          audioPlayer.forward()
        }) {
          Image(systemName: "goforward.15")
            .font(.title)
            .imageScale(.medium)
        }
        Spacer()
      }
    }
  }
}

struct SwiftUIAudioPlayerView_Previews: PreviewProvider {
  static var previews: some View {
    SwiftUIAudioPlayerView()
      .environmentObject(SwiftUIAudioPlayer(url: URL(fileURLWithPath: "")))
  }
}
