import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick 2.0 as QtQuickModuleImportedInJS
import QtQuick.XmlListModel 2.0

import "formide.js" as Formide

Rectangle {
    id: rectangleGetDetailMaterials
    x: 0
    y: 0
    width: 480
    height: 272

    property var materialsInformation: main.materialsInformation
    property var materialsInformation2: main.materialsInformation2

    function getModelNumber()
    {
        if(materialsInformation)
        {
            return materialsInformation.length
        }
        else
        {
            return 0
        }
    }

    function getNameMaterials(position)
    {
        if(materialsInformation)
        {
            if(materialsInformation.length > position)
            {
                if(materialsInformation[position].name){
                    return materialsInformation[position].name
                }
                else{
                    return "Name not available"
                }
            }
            else
            {
                return "Position does not exist"
            }
        }
        else
        {
            return "Not defined"
        }
    }

    function getEverything(position)
    {
        if(materialsInformation)
        {
            if(materialsInformation.length > position)
            {
                if(materialsInformation[position]){
                    return materialsInformation[position]
                }
                else{
                    return "Error materiasInformation[position]"
                }
            }
            else
            {
                return "Error materialsInformation.length > position"
            }
        }
        else
        {
            return "Not defined"
        }
    }

    Component{
        id: delegateComponent
        Rectangle{
            width: 464
            height: 50
            color: "#ff8833"
            border.width: 2
            border.color: "#ff0000"
            Row{
                spacing: 5
                anchors.centerIn: parent
                Rectangle{
                    width: 150
                    height: 30
                    color: "#ffffff"
                    border.width: 2
                    border.color: "black"

                    Text{ anchors.centerIn: parent; text: getNameMaterials(index); width: 140; font.pixelSize: 14}

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            materialsInformation2 = getEverything(index)
                            console.log(JSON.stringify(materialsInformation2))
                            main.materialsInformation2 = materialsInformation2
                            //console.log(JSON.stringify(main.materialsInformation))
                            //console.log(getEverything(index))
                            //console.log(getNameMaterials(index))
                            rectangleGetDetailMaterials.parent.push(Qt.resolvedUrl("detailMaterial.qml"))

                        }
                    }
                }
            }
        }
    }

    ListView{
        id: visor
        width: 464
        height: 185
        anchors.verticalCenterOffset: -35
        anchors.horizontalCenterOffset: 0
        anchors.centerIn: parent
        model: getModelNumber()
        delegate: delegateComponent
        spacing: 10
    }

    Rectangle {
        id: rectangle1
        x: 8
        y: 199
        width: 101
        height: 65
        color: "orange"

        TextEdit {
            id: text2
            x: 16
            y: 23
            width: 80
            height: 20
            text: qsTr("Back")
            font.pixelSize: 19
        }

        MouseArea{
            id: goBack
            anchors.fill: parent
            onClicked: {
                rectangleGetDetailMaterials.parent.pop()
            }
        }
    }
}
