import "formide.js" as Formide
import QtQuick 2.3
import QtQuick.Window 2.2
import Qt.WebSockets 1.0
import QtQuick.Controls 1.2

Rectangle {

    id: home
    visible: true
    width: 480
    height: 272

    StackView {
        id: stackTop
        initialItem: view
        width:480
        height:272
        Component {
            id: view
            Rectangle{
                id: buttonMaterials
                x: 0
                y: 0
                width: 200
                height: 100
                color: "black"
                MouseArea{
                    id: maGetMaterials
                    anchors.fill: parent
                    onClicked: {
                        console.log("C O N S O L E -> o n C l i c k e d")
                        getMaterials()
                        stackTop.push(Qt.resolvedUrl("getMaterials.qml"))
                    }
                }
                Text {
                    id: textHome
                    x: 50
                    y: 33
                    width: 150
                    height: 14
                    text: qsTr("Get Materials")
                    anchors.verticalCenterOffset: 0
                    anchors.horizontalCenterOffset: 0
                    anchors.centerIn: parent
                    font.pixelSize: 22
                    color: '#ffffff'
                }
            }

        }

    }
}
