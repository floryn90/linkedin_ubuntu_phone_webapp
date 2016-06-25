import QtQuick 2.4
import QtQuick.Window 2.2
import Ubuntu.Web 0.2
import Ubuntu.Components 1.2
import com.canonical.Oxide 1.9 as Oxide
import "UCSComponents"
import Ubuntu.Content 1.1
import "."
import "../config.js" as Conf

Window {
    id: window
    visibility: Window.AutomaticVisibility
    property string myUrl: Conf.webappUrl
    property string myPattern: Conf.webappUrlPattern

    property string myUA: "Mozilla/5.0 (Linux; Android 4.4; Nexus 5) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chromium/35.0.1870.2 Mobile Safari/537.36"
    width: units.gu(150)
    height: units.gu(100)

    MainView {
        objectName: "mainView"

        applicationName: "linkedin.floryn90"

        anchorToKeyboard: true
        automaticOrientation: true

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        Page {
            id: page
            anchors {
                fill: parent
                bottom: parent.bottom
            }
            width: parent.width
            height: parent.height

            WebContext {
                id: webcontext
                userAgent: myUA

            }
            WebView {
                id: webview
                anchors {
                    fill: parent
                    bottom: parent.bottom
                }
                width: parent.width
                height: parent.height

                context: webcontext
                url: myUrl
                preferences.localStorageEnabled: true
                preferences.allowFileAccessFromFileUrls: true
                preferences.allowUniversalAccessFromFileUrls: true
                preferences.appCacheEnabled: true
                preferences.javascriptCanAccessClipboard: true
                filePicker: filePickerLoader.item

                onFullscreenRequested: webview.fullscreen = fullscreen

                function navigationRequestedDelegate(request) {
                    var url = request.url.toString();
                    var pattern = myPattern.split(',');
                    var isvalid = false;

                    for (var i=0; i<pattern.length; i++) {
                        var tmpsearch = pattern[i].replace(/\*/g,'(.*)')
                        var search = tmpsearch.replace(/^https\?:\/\//g, '(http|https):\/\/');
                        if (url.match(search)) {
                           isvalid = true;
                           break
                        }
                    }
                    if(isvalid == false) {
                        console.warn("Opening remote: " + url);
                        Qt.openUrlExternally(url)
                        request.action = Oxide.NavigationRequest.ActionReject
                    }
                }
                Component.onCompleted: {
                    preferences.localStorageEnabled = true
                    if (Qt.application.arguments[1].toString().indexOf("https://www.linkedin.com/m") > -1) {
                        console.warn("got argument: " + Qt.application.arguments[1])
                        url = Qt.application.arguments[1]
                    }
                    console.warn("url is: " + url)
                }
                onGeolocationPermissionRequested: { request.accept() }
                Loader {
                    id: filePickerLoader
                    source: "ContentPickerDialog.qml"
                    asynchronous: true
                }
            }
            ThinProgressBar {
                webview: webview
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
            }
            RadialBottomEdge {
                id: nav
                visible: true
                actions: [
                    RadialAction {
                        id: reload
                        iconName: "reload"
                        onTriggered: {
                            webview.reload()
                        }
                        text: qsTr("Reload")
                    },
                    RadialAction {
                        id: forward
                        enabled: webview.canGoForward
                        iconName: "go-next"
                        onTriggered: {
                            webview.goForward()
                        }
                       text: qsTr("Forward")
                     },
                    RadialAction {
                        id: back
                        enabled: webview.canGoBack
                        iconName: "go-previous"
                        onTriggered: {
                            webview.goBack()
                        }
                        text: qsTr("Back")
                    }
                ]
            }
        }
        Connections {
            target: Qt.inputMethod
            onVisibleChanged: {
                nav.visible = !nav.visible
                webview.focus = !nav.visible
            }
        }
        Connections {
            target: webview
            onFullscreenChanged: {
                nav.visible = !webview.fullscreen
                if (webview.fullscreen == true) {
                    window.visibility = 5
                } else {
                    window.visibility = 4
                }
            }
        }
        Connections {
            target: UriHandler
            onOpened: {
                webview.url = uris[0]
                console.warn("uri-handler request")
            }
        }
    }
}
