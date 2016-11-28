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

    property var materialsInformation2: main.materialsInformation2
    property var name
    property var type
    property var temp
    property var firstLayersTemp
    property var bedTemp
    property var firstLayersBedTemp
    property var feedR

//    "name": "Material1",
//       "type": "Material1",
//       "temperature": 231,
//       "firstLayersTemperature": 137,
//       "bedTemperature": 82,
//       "firstLayersBedTemperature": 44,
//       "feedRate": 134,

    function getNameMaterial(){
        if(materialsInformation2.name)
        {
            return materialsInformation2.name
        }
        else
        {
            return "Not defined"
        }
    }

    function getTypeMaterial(){
        if(materialsInformation2.type)
        {
            return materialsInformation2.type
        }
        else
        {
            return "Not defined"
        }
    }

    function getMaterialInfo(){
        if(materialsInformation2){
            if(materialsInformation2.name){
                name = materialsInformation2.name

            }
            else{
                return "Not name defined"
            }
        }
        else{
            return "Not defined"
        }
    }

    Text{
        id:textText
        x: 0
        y: 0
        width: 296
        height: 30
        text: "Id: "+materialsInformation2.id+ "\nName: "+materialsInformation2.name+ "\nType: " +materialsInformation2.type+ "\nTemperature: " +materialsInformation2.temperature
        anchors.verticalCenterOffset: -113
        anchors.horizontalCenterOffset: -84
        anchors.centerIn: parent
        font.pixelSize: 22
        color: '#ff0000'
    }

    Rectangle {
        id: rectangleGoBack
        x: 8
        y: 199
        width: 101
        height: 65
        color: "#ff8833"

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
                rectangleDetail.parent.pop()
            }
        }
    }

    Rectangle {
        id: rectangleDelete
        x: 371
        y: 199
        width: 101
        height: 65
        color: "#ff8833"

        TextEdit {
            id: textEdit3
            x: 16
            y: 23
            width: 80
            height: 20
            text: qsTr("Delete")
            font.pixelSize: 19
        }

        MouseArea{
            id: goBack3
            anchors.fill: parent
            onClicked: {
                rectangleDetail.parent.push(Qt.resolvedUrl("confirmationDelete.qml"))
            }
        }
    }

}
