import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick 2.0 as QtQuickModuleImportedInJS
import QtQuick.XmlListModel 2.0

import "formide.js" as Formide

Rectangle {
    id: rectangleDetail
    x: 0
    y: 0
    width: 480
    height: 272

    property var materialsInformation: main.materialsInformation

    function getNameMaterial()
    {
        if(materialsInformation.name)
        {
            return materialsInformation.name
        }
        else
        {
            return "Not defined"
        }
    }

    Text{
        id:textText
        x: 0
        y: 0
        width: 296
        height: 30
        text: getNameMaterial()
        anchors.verticalCenterOffset: -113
        anchors.horizontalCenterOffset: -84
        anchors.centerIn: parent
        font.pixelSize: 22
        color: '#ff0000'
    }

    Rectangle {
        id: rectangle1234
        x: 8
        y: 199
        width: 101
        height: 65
        color: "#ff0000"

        TextEdit {
            id: textEdit2
            x: 16
            y: 23
            width: 80
            height: 20
            text: qsTr("Back")
            font.pixelSize: 19
        }

        MouseArea{
            id: goBack2
            anchors.fill: parent
            onClicked: {
                //rectangleDetail.parent.pop()
                rectangleDetail.parent.pop(Qt.resolvedUrl("Home.qml"))
            }
        }
    }

}
