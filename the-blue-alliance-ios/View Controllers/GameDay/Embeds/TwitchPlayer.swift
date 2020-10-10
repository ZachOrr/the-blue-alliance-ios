import Foundation
import TBAData
import UIKit
import WebKit

// Based on https://github.com/Chris-Perkins/TwitchPlayer
class TwitchPlayer: WKWebView, WebcastPlayer {

    required init(webcast: Webcast) {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true

        super.init(frame: .zero, configuration: configuration)
        loadHTMLString(TwitchPlayer.playerHtmlContent.replacingOccurrences(of: TwitchPlayer.initializationReplacementKey, with: webcast.channel),
                       baseURL: URL(string: "https://www.thebluealliance.com"))

        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static let initializationReplacementKey = "{0}"
    private static let playerHtmlContent = """
<html>
  <head>
    <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1.0, user-scalable=no" />
    <style>
      #twitch-embed {
        width:100%;
        height:100%;
      }
    </style>
  </head>
  <body margin="0" padding="0" style="margin: 0 0 0 0;">
    <div id="twitch-embed"></div>
    <script src="https://embed.twitch.tv/embed/v1.js"></script>
    <script type="text/javascript">
      console.log("Loading");
      const embed = new Twitch.Embed('twitch-embed', {
        width: "100%",
        height: "100%",
        playsinline: true,
        channel: "\(initializationReplacementKey)",
        layout: "video",
        theme: "dark"
      });
      embed.addEventListener(Twitch.Embed.VIDEO_READY, () => {
        console.log("Automatically playing...");
        const player = embed.getPlayer();
        player.play();
      });
    </script>
  </body>
</html>
"""

}
