import QtQuick

BarButton {
    property real availableWidth: 390
    readonly property var player: Services.player
    visible: player !== null && availableWidth > 30
    maximumWidth: Math.max(0, availableWidth)
    icon: player && !player.isPlaying ? "" : ""
    text: player ? [player.trackArtist, player.trackTitle].filter(s => s.length > 0).join(" - ") : ""
    foreground: player && player.isPlaying ? Settings.foreground : Settings.muted
    onClicked: if (player && player.canTogglePlaying) player.togglePlaying()
    onScrolled: direction => {
        if (!player) return;
        if (direction > 0 && player.canGoPrevious) player.previous();
        if (direction < 0 && player.canGoNext) player.next();
    }
}
