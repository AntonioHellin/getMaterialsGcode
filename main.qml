import "formide.js" as Formide
import QtQuick 2.3
import QtQuick.Window 2.2
import Qt.WebSockets 1.0
import QtQuick.Controls 1.2

Window {

    id: main
    visible: true
    width: 480
    height: 272

   /*************
    Variables
    ************/

    // Printer status
    property var printerStatus//:{ "extruders": [ { "id": 0, "temp": 198, "targetTemp": 198 },{ "id": 1, "temp": 198, "targetTemp": 0 } ], "bed": { "temp": 60, "targetTemp": 60 },"port": '/dev/tty.usbmodem12341',"status": 'printing',       "timeStarted": '2016-01-29.15:35:28',       "timeNow": '2016-01-29.16:01:03',       "baudrate": 250000,"ratio":60,       "queueItemId": 6,       "progress": 25,       "coordinates": { x: 97, y: 80, z: 3 },       "currentlyPrinting": 'INFILL',       "printSpeed": 40,       "materialAmount": 0 }
    // Needed for pages
    property var materials

    property var materialsInformation
    property var materialsInformation2

    property var printer
    property var sliceProfiles
    property var fileItems
    property var queueItems
    property var printJobs
    property var wifiList
    property var initialized:false
    property var loggedIn:false

    // Specific
    property var uniquePrinter
    property var uniquePrintJob
    property var printJobId
    property var currentPrintJob
    property var fileNameSelected
    property var modelFileSelected
    property var materialSelected
    property var qualitySelected
    property var printerSelected

    property var bedPreheated:false
    property var nozzlePreheated:false

    property var cancelling:false
    property var fanValue:255

    /*************
     PASSWORD
     ************/

    property var isLocked:false
    property var isConnectedToWifi:false
    property var singleNetwork
    property var currentClientVersion:""
    property var wifiAction:false
    property var registrationToken:""
    property var passcode
    property var ipAddress
    property var macAddress

    /*************
     Login Functions
     ************/

    property var savedAccessToken
    function login(){
        Formide.login('admin@local', 'admin',function(callback){
             if(callback==true)
             {
                 if(Formide.getAccessToken().length > 29)
                 {
                     //getIsConnectedToWifi()
                     loginTimer.repeat = false
                     loginTimer.stop()

                     loggedIn=true
                     sock.active = true

                 }
             }
        });
    }

    function getMaterials(){
        Formide.database().materials(function(err,response){
            if(err)
               console.log("ERR: "+err)
            if(response)
            {
                updateMaterials(JSON.parse(response))
            }
        })
    }

    function removeMaterials(id){
        Formide.database().removeMaterials(id,function(err,resp){
            if(err)
               console.log("ERR: ",JSON.stringify(err))
            if(resp)
            {
                getMaterials()
            }
        })

    }

    function updateMaterials(data) {
        materials=data
        console.log("updateMaterials")
        materialsInformation=data
    }

    // Fan Timer

    function sendFanSpeed(val)
    {
        fanValue=val
        fanTimer.restart()
    }

    /*************
     WEBSOCKET WEB SOCKET
     ************/

    WebSocket {
        active: false

        function socketLogin () {
            sock.sendTextMessage(JSON.stringify({
                channel: "authenticate",
                data: {
                    type: "user",
                    accessToken: Formide.getAccessToken()
                }
            }));
        }

        id: sock
        //url: "ws://10.1.0.61:8080"
        url: "ws://127.0.0.1:8080"


        onTextMessageReceived: {
            try {
                var data = JSON.parse(message);
                //console.log("received event: " + JSON.stringify(data.channel));

                if(data.channel === "slicer.finished")
                {
                    //console.log("data",JSON.stringify(data))
                    if(slicing===true)
                    {
                        if(slicerError.length>1)
                        {
                            slicerError="";
                            slicing=false;


                            // If HTTP call is wrong, we get information from notification
                            setPrintJobId(data.data.data.printJob)
                            sliceFinished()
                        }
                        else
                        {
                            slicing=false;
                            sliceFinished()
                        }
                    }
                }
                if(data.channel === "slicer.failed")
                {
                    if(slicing===true)
                    {
                        slicing=false;
                        slicerError=data.data.message
                        sliceFailed()
                    }
                }

                if(data.channel === "printer.stopped")
                {
                    console.log("PRINTER STOPPED")
                    cancelling=true;
                }

                if(data.channel === "printer.started")
                {
                    console.log("PRINTER STARTED")
                    getQueue()
                    clearScreenFast()
                }

                if(data.channel === "printer.status")
                {

                    if(data.data.status != "connecting")
                    {

                        if(printerStatus)
                        {

                            if(printerStatus.status == "online" && (data.data.status=="printing" || data.data.status=="heating"))
                            {
                                //console.log("Reseting ratio values");
                                leftRatioValue=100;
                                rightRatioValue=0;
                                Formide.printer(printerStatus.port).tune("G93 R100");


                            }

                            if ( (printerStatus.status=="printing" || printerStatus.status=="heating" || printerStatus.status=="paused") && data.data.status=="online" )
                            {
                                console.log("Clearing screen NEW")
                                clearScreenFast()
                                cancelling=false
                            }

                        }
                        printerStatus=data.data

                        if(!initialized && loggedIn)
                        {
                            // THIS CODE IS RUN WHEN WE ARE CONNECTED TO FORMIE CLIENT
                            initialized=true
                            getEverything()
                            splash.visible=false

                            getCurrentClientVersion()
                        }
                    }

                    if(data.data.status=="printing")
                    {
                        if(currentPrintJob!==data.data.queueItemId)
                        {
                            currentPrintJob = data.data.queueItemId;
                            getQueue()
                        }
                    }
                }
                if(data.channel === "printer.connected")
                {
                    statusBall.color="yellow"
                }
                if(data.channel === "printer.disconnected")
                {
                    statusBall.color="grey"
                }

                if (data.data.notification) {
                   notifications.notify(data.data.level, data.data.message);

                }
            }
            catch (e) {
               //console.log(e);
            }
        }
        onStatusChanged: {
            if (sock.status == WebSocket.Error) {
               console.log(qsTr("Client error: %1").arg(sock.errorString));
            } else if (sock.status == WebSocket.Closed) {
               console.log(qsTr("Client socket closed."));
               splashTimer.interval = 0
            } else if (sock.status == WebSocket.Open) {
                socketLogin();
            }
            else {
               console.log("websocket status: "+ sock.status);
            }
        }
    }

    /*************
     QML Elements
     ************/

    Component.onCompleted:{
        console.log("Starting formide-builder-ui v1.4.3")
        login()
        macAddress = mySystem.msg("fiw wlan0 mac");
    }

    /*************
     Timers
     ************/

    Timer{
        id:splashTimer

        interval: 30000
        repeat: false
        running: true

        onTriggered:
        {
            splash.visible=false
        }
    }

    Timer {
        id: wifiTimer
        interval: 15000
        repeat: true
        running: true
        onTriggered:
        {

            if(wifiAction)
            {
              getIsConnectedToWifi()
            }
            else
            {
                if(printerStatus)
                    if(printerStatus.status=="online")
                        getIsConnectedToWifi()
            }
        }
    }

    // All info, every 5 min
    Timer {
        id: statusTimer
        interval: 60000
        repeat: true
        running: true
        onTriggered:
        {
            //getEverything()
        }
    }

    // Login timer
    Timer {
        id: loginTimer
        interval: 30000
        repeat: true
        running: true

        onTriggered:
        {

           console.log("Connecting")
            if(Formide.getAccessToken().length < 30)
                login()
            else
            {
                loginTimer.repeat = false
                loginTimer.running = false
                loginTimer.stop()
            }
        }
    }

    // The next timer, printingTimer, is not used for now. But it will be used soon.

    // Clear Timer
    Timer{
        id:clearTimer
        running:false
        repeat:false
        interval:5000
        onTriggered: {
            pagestack.clear()
            pagestack.push(Qt.resolvedUrl("Home.qml"))
        }
    }

    // Speed Timer
    Timer{
        id:speedTimer
        running:false
        repeat:false
        interval:900
        onTriggered: {
            //console.log("M220 S"+speedValue)

            Formide.printer(printerStatus.port).tune("M220 S"+speedValue)
        }
    }

    Timer{
        id:fanTimer
        running:false
        repeat:false
        interval:1000
        onTriggered: {
            if(fanValue==0)

                Formide.printer(printerStatus.port).tune("M107")

            else
                Formide.printer(printerStatus.port).tune("M106 S"+fanValue)
        }
    }

    Rectangle{

        width:parent.width
        height:parent.height
        rotation:0


        StackView{

            delegate: StackViewDelegate {
                    function transitionFinished(properties)
                    {
                        properties.exitItem.opacity = 1
                    }

                    pushTransition: StackViewTransition {
                        PropertyAnimation {
                            target: enterItem
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 0
                        }
                        PropertyAnimation {
                            target: exitItem
                            property: "opacity"
                            from: 1
                            to: 0
                            duration: 0
                        }
                    }
                }

            id:pagestack
            anchors.fill: parent
            focus: true

            // Link properties and functions
            property var printerStatus:main.printerStatus
            property var materials:main.materials
            property var printer:main.printer
            property var sliceProfiles:main.sliceProfiles
            property var fileItems:main.fileItems
            property var queueItems:main.queueItems
            property var printJobs:main.printJobs
            property var currentPrintJob: main.currentPrintJob
            property var wifiList:main.wifiList
            property var bedPreheated:main.bedPreheated
            property var nozzlePreheated:main.nozzlePreheated
            property var printJobId:main.printJobId
            property var fileNameSelected:main.fileNameSelected
            property var modelFileSelected:main.modelFileSelected
            property var materialSelected:main.materialSelected
            property var qualitySelected:main.materialSelected
            property var uniquePrinter:main.uniquePrinter
            property var uniquePrintJob:main.uniquePrintJob
            property var amountValue:main.amountValue
            property var leftRatioValue:main.leftRatioValue
            property var rightRatioValue:main.rightRatioValue
            property var speedValue:main.speedValue
            property var isLocked:main.isLocked
            property var isConnectedToWifi:main.isConnectedToWifi
            property var ipAddress:main.ipAddress
            property var driveFiles:main.driveFiles
            property var driveListing:main.driveListing
            property var drivePath: main.drivePath
            property var driveUnit: main.driveUnit

            function updateDriveFilesFromPath(){main.updateDriveFilesFromPath()}
            function updateDrivePath(drivePath){main.updateDrivePath(drivePath)}
            function updateDriveListing(i){main.updateDriveListing(i)}
            function updateDriveUnit(driveUnit){main.updateDriveUnit(driveUnit)}
            function scanDrives(){main.scanDrives()}
            function copyFileFromDrive(){main.copyFileFromDrive()}
            function setPrintJobId(data){ main.setPrintJobId(data) }
            function loadFirst(){main.loadFirst()}
            function loadSecond(){main.loadSecond()}
            function unloadFirst(){main.unloadFirst()}
            function replacePosition(){main.replacePosition()}
            function unloadSecond(){main.unloadSecond()}
            function lessAmount(){main.lessAmount()}

            function moreAmount(){main.moreAmount() }

            function moreLeftRatio(){main.moreLeftRatio()}

            function moreRightRatio(){main.moreRightRatio()}

            function switchRatio(){main.switchRatio()}

            function lessSpeed(){main.lessSpeed()}

            function moreSpeed(){main.moreSpeed()}

            function setPassCode(code){main.setPassCode(code)}

            function checkPassCode(code){return main.checkPassCode(code)}

            function toggleNozzle(value) {  main.toggleNozzle(value)  }

            function toggleBed(value) { main.toggleBed(value) }

            function selectSTL(model){ main.selectSTL(model) }

            function printGCode(gcode){ main.printGCode(gcode) }

            function printGCodeFast() { main.printGCodeFast()}

            function clearScreenFast(){ main.clearScreenFast()}

            function sendSliceRequest(uniquePrinter,modelFileSelected,materialSelected,qualitySelected){

                main.sendSliceRequest(uniquePrinter,modelFileSelected,materialSelected,qualitySelected)
            }

            function wifiSettings(){ main.wifiSettings()}

            function getWifiList(){main.getWifiList()}

            function connectToWifi(password) {main.connectToWifi(password)}

            function resetWifi(){main.resetWifi()}

            function popPassword(ssid) { main.popPassword(ssid) }

            function removeFile(id){main.removeFile(id)}

            function removePrintJob(id){main.removePrintJob(id)}

            function getFiles(){main.getFiles()}

            function getPrintJobs(){main.getPrintJobs()}

            function printQueueItem(id){main.printQueueItem(id)}

            function removeQueueItem(id){main.removeQueueItem(id)}

            function printCustomGcode(id, gcode){main.printCustomGcode(id)}

            function updateFileList(){main.updateFileList()}

            function removeMaterials(id){main.removeMaterials(id)}

            initialItem: Qt.resolvedUrl("Home.qml")
        }

        //Splash

        Rectangle{

            id:splash
            visible:true
            anchors.fill: parent

            Text {
                id: textSplash
                x: 101
                y: 80
                width: 278
                height: 46
                text: qsTr("Connecting ...")
                font.pixelSize: 40
            }
        }
    }
}
