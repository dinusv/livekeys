import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import workspace 1.0

Rectangle{
    id: root

    width: 180
    height: listView.contentHeight > maxHeight ? maxHeight : listView.contentHeight + 5

    property double maxHeight: 200
    property alias delegate: listView.delegate
    property alias model: listView.model

    color: style.backgroundColor
    opacity: style.opacity
    border.width: style.borderWidth
    border.color: style.borderColor

    property alias currentIndex: listView.currentIndex

    property QtObject defaultStyle: QtObject{
        property QtObject labelStyle: TextStyle{}
        property color backgroundColor: "#03070a"
        property color selectionBackgroundColor: "#091927"

        property double radius: 0
        property color borderColor: "#000"
        property double borderWidth: 0
        property double opacity: 0.95

        property Component scrollStyle: ScrollViewStyle {
            transientScrollBars: false
            handle: Item {
                implicitWidth: 10
                implicitHeight: 10
                Rectangle {
                    color: "#1f2227"
                    anchors.fill: parent
                }
            }
            scrollBarBackground: Item{
                implicitWidth: 10
                implicitHeight: 10
                Rectangle{
                    anchors.fill: parent
                    color: root.color
                }
            }
            decrementControl: null
            incrementControl: null
            frame: Item{}
            corner: Rectangle{color: root.color}
        }
    }

    property QtObject style: defaultStyle


    signal triggered(int index)
    signal cancelled()

    function selectIndex(index){
        listView.currentIndex = index
    }

    function highlightNext(){
        if ( listView.currentIndex + 1 <  listView.count ){
            listView.currentIndex++;
        } else {
            listView.currentIndex = 0;
        }
    }
    function highlightPrev(){
        if ( listView.currentIndex > 0 ){
            listView.currentIndex--;
        } else {
            listView.currentIndex = listView.count - 1;
        }
    }

    function highlightNextPage(){
        var noItems = Math.floor(listView.height / 25)
        if ( listView.currentIndex + noItems < listView.count ){
            listView.currentIndex += noItems;
        } else {
            listView.currentIndex = listView.count - 1;
        }
    }
    function highlightPrevPage(){
        var noItems = Math.floor(listView.height / 25)
        if ( listView.currentIndex - noItems >= 0 ){
            listView.currentIndex -= noItems;
        } else {
            listView.currentIndex = 0;
        }
    }

    focus: false

    Keys.onPressed: {
        if ( event.key === Qt.Key_PageUp ){
            highlightPrevPage()
            event.accepted = true
        } else if ( event.key === Qt.Key_PageDown ){
            highlightNextPage()
            event.accepted = true
        } else if ( event.key === Qt.Key_Down ){
            highlightNext()
            event.accepted = true
        } else if ( event.key === Qt.Key_Up ){
            highlightPrev()
            event.accepted = true
        } else if ( event.key === Qt.Key_Return || event.key === Qt.Key_Enter ){
            root.paletteSelected(listView.currentIndex)
            event.accepted = true
        } else if ( event.key === Qt.Key_Escape ){
            root.cancelled()
            event.accepted = true
        }
    }

    ScrollView{
        anchors.top : parent.top

        height : root.height
        width: root.width

        style: root.style.scrollStyle

        ListView{
            id : listView
            anchors.fill: parent
            anchors.rightMargin: 2
            anchors.bottomMargin: 5
            anchors.topMargin: 0
            visible: true
            opacity: root.opacity

            currentIndex: 0
            onCountChanged: currentIndex = 0

            boundsBehavior : Flickable.StopAtBounds
            highlightMoveDuration: 100
        }
    }
}
