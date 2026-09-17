import QtQuick

Segment {
    BarButton {
        property bool fullDate: false
        text: Qt.formatDateTime(Services.now, fullDate ? "HH:mm dd MMMM yyyy" : "HH:mm")
        onClicked: fullDate = !fullDate
    }
}
