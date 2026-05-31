import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    width: 800
    height: 520
    color: "#1e1e2e" // Catppuccin Mocha Base

    Column {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "Instalando Atomic Linux..."
            color: "#cdd6f4"
            font.pixelSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Póngase cómodo mientras configuramos su nuevo entorno Hyprland."
            color: "#a6adc8"
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
