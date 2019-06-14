/****************************************************************************
**
** Copyright (C) 2014-2018 Dinu SV.
** (contact: mail@dinusv.com)
** This file is part of Live CV Application.
**
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
****************************************************************************/

import QtQuick 2.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.2
import QtQuick.Window 2.0
import base 1.0
import editor 1.0
import editor.private 1.0
import live 1.0

Item{
    id: root
    anchors.fill: parent
    objectName: "workspace"

    property Item runSpace : runSpace

    property QtObject panes : QtObject{
        property var open: []
        property Item activePane : null
        property Item activeItem : null
        property Item contentWrap : contentWrap

        property var factories : {
            return {
                "editor" : function(p, s){
                    var pane = editorFactory.createObject(p)
//                    pane.paneState = s
                    return pane
                },
                "projectFileSystem" : function(p, s){
                    var pane = projectFileSystemFactory.createObject(p)
//                    pane.paneState = s
                    return pane
                }
            }
        }

        function createPane(paneType, paneState, panePosition, paneSize){

            if ( paneType in root.panes.factories ){

                var paneFactory = root.panes.factories[paneType]
                var paneObject = paneFactory(null, paneState)
                if ( paneSize ){
                    paneObject.width = paneSize.width
                    paneObject.height = paneSize.height
                }

                mainHorizontalSplit.insert(panePosition[0], paneObject)
                return paneObject

            } else {
                throw new Error('Key not found: ' + paneType)
            }
        }

        function add(pane, paneWindow, position){
            open.push(pane)

            livecv.layers.workspace.addPane(pane, paneWindow, position)

            if ( !activeItem )
                activateItem(pane, pane)
        }

        function setActiveItem(item, pane){
            activeItem = item
            var p = pane ? pane : item
            while ( p !== null ){
                if ( p.objectName === 'editor' || p.objectName === 'project' || p.objectName === 'viewer' ){
                    activePane = p
                    return
                }
                p = p.parent
            }
        }

        function activateItem(item, pane){
            if ( activeItem && activeItem !== item ){
                activeItem.focus = false
            }

            activeItem = item
            activeItem.forceActiveFocus()
            var p = pane ? pane : item
            while ( p !== null ){
                if ( p.objectName === 'editor' || p.objectName === 'project' || p.objectName === 'viewer' ){
                    activePane = p
                    return
                }
                p = p.parent
            }
        }

        function focusPane(paneType){
            var ap = root.panes.activePane
            if ( ap.objectName === paneType ){
                return ap;
            }

            var openPanes = root.panes.open
            for ( var i = 0; i < openPanes.length; ++i ){
                if ( openPanes[i].objectName === paneType )
                    return openPanes[i]
            }

            return null;
        }
    }

    property QtObject projectEnvironment : ProjectEnvironment{
        panes: root.panes
        runSpace: root.runSpace
    }

    property bool documentsReloaded : false
    Connections{
        target: livecv.layers.window
        onIsActiveChanged : {
            if ( isActive ){
                project.navigationModel.requiresReindex()
                project.fileModel.rescanEntries()
                project.documentModel.rescanDocuments()
                if ( documentsReloaded && project.active ){
                    project.scheduleRun()
                    documentsReloaded = false
                }
                editor.forceActiveFocus()
            }
        }
    }

    Connections{
        target: livecv
        onLayerReady: {
            if ( layer.name === 'workspace' ){
                layer.commands.add(root, {
                    'minimize' : [livecv.layers.window.handle.minimize, "Minimize"],
                    'toggleFullScreen': [livecv.layers.window.handle.toggleFullScreen, "Toggle Fullscreen"],
                    'toggleMaximizedRuntime' : [contentWrap.toggleMaximizedRuntime, "Toggle Maximized Runtime"],
                    'toggleNavigation' : [contentWrap.toggleNavigation, "Toggle Navigation"],
                    'openLogInWindow' : [mainVerticalSplit.openLogInWindow, "Open Log In Window"],
                    'openLogInEditor' : [mainVerticalSplit.openLogInEditor, "Open Log In Editor"],
                    'toggleLog' : [mainVerticalSplit.toggleLog, "Toggle Log"],
                    'toggleLogPrefix' : [logView.toggleLogPrefix, "Toggle Log Prefix"],
                    'addHorizontalEditorView' : [mainVerticalSplit.addHorizontalEditor, "Add Horizontal Editor"],
                    'addHorizontalFragmentEditorView': [mainVerticalSplit.addHorizontalFragmentEditor, "Add Horizontal Fragment Editor"],
                    'removeHorizontalEditorView' : [mainVerticalSplit.removeHorizontalEditor, "Remove Horizontal Editor"],
                    'setLiveCodingMode': [modeContainer.setLiveCodingMode, "Set 'Live' Coding Mode"],
                    'setOnSaveCodingMode': [modeContainer.setOnSaveCodingMode, "Set 'On Save' Coding Mode"],
                    'setDisabledCodingMode': [modeContainer.setDisabledCodingMode, "Set 'Disabled' Coding Mode"],
                    'runProject': [project.run, "Run Project"]
                })
            }
        }
    }

    LogWindow{
        id : logWindow
        visible : false
        onVisibleChanged: if (!visible){
            logView.visible = false
        }
        Component.onCompleted: width = root.width
    }

    Top{
        id : header
        modeContainer: modeContainer
        anchors.top : parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        color: "#08141d"

        property var callback : function(){}

        property string action : ""

        onNewProject: root.projectEnvironment.newProject()
        onOpenFile : root.projectEnvironment.openFile()
        onOpenProject: root.projectEnvironment.openProject()
        onSaveFile : {
            var fe = root.panes.focusPane('editor')
            if ( fe )
                fe.saveAs()
        }
        onToggleLogWindow : mainVerticalSplit.toggleLog()
        onOpenCommandsMenu: {
            livecv.layers.workspace.commands.model.setFilter('')
            commandsMenu.visible = !commandsMenu.visible
        }

        onOpenSettings: {
            var fe = root.panes.focusPane('editor')
            if ( fe ){
                fe.document = project.openFile(livecv.settings.file('editor').path, ProjectDocument.Edit);
                livecv.settings.file('editor').documentOpened(editor.document)
            }
        }

        property License license : License{}
        onOpenLicense: {livecv.layers.window.overlayBox(license)}
    }

    CommandsMenu {
        id: commandsMenu
        anchors.top: header.bottom
        x: 395
    }

    ModeContainer {
        id: modeContainer
        modeWrapper: header
    }

    Component{
        id: editorFactory

        Editor{
            id: editorComponent
            height: parent ? parent.height : 0
            width: 400
            panes: root.panes
            onInternalActiveFocusChanged: if ( internalActiveFocus ) {
                root.panes.setActiveItem(editorComponent.textEdit, editorComponent)
            }

            Component.onCompleted: {
                if ( project.active ){
                    editorComponent.document = project.active
                }
                forceFocus()
            }
        }
    }

    Component{
        id: projectFileSystemFactory

        ProjectFileSystem{
            id: projectView
            width: 240
            panes: root.panes
        }
    }


    SplitView{
        id: mainVerticalSplit
        anchors.top : header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height : parent.height - header.height
        orientation: Qt.Vertical

        handleDelegate: Rectangle{
            implicitWidth: 1
            implicitHeight: 1
            color: "#191e23"
        }

        function addHorizontalEditor(){
            var editorObject = editorFactory.createObject(0)
            mainHorizontalSplit.insert(mainHorizontalSplit.panes.length - 1, editorObject)

            root.panes.add(editorObject)
            root.panes.setActiveItem(editorObject.textEdit, editorObject)
        }

        function addHorizontalFragmentEditor(){
            var fe = root.panes.focusPane('editor')
            if ( !fe || !fe.document ){
                addHorizontalEditor();
                return
            }

            var cursorBlock = fe.getCursorFragment()
            if ( cursorBlock.start === cursorBlock.end ){
                addHorizontalEditor()
                return
            }

            var editorObject = editorFactory.createObject(0)
            editorObject.fragmentStart = cursorBlock.start + 1
            editorObject.fragmentEnd = cursorBlock.end + 1

            mainHorizontalSplit.insert(mainHorizontalSplit.panes.length - 1, editorObject)

            root.panes.add(editorObject)
            root.panes.setActiveItem(editorObject.textEdit, editorObject)
        }

        function removeHorizontalEditor(){
            var fe = root.panes.focusPane('editor')
            if ( fe )
                mainHorizontalSplit.removeItem(fe)
        }

        function openLogInWindow(){
            var logItem = logView
            mainVerticalSplit.removeItem(logView)

            logItem.x = 0
            logItem.y = 0
            logItem.width = Qt.binding(function(){ return logWindow.contentWidth; })
            logItem.height = Qt.binding(function(){ return logWindow.contentHeight; })
            logItem.isInWindow = true

            logWindow.content = logItem
            logWindow.show()
        }

        function openLogInEditor(){
            var logItem = logWindow.content
            logWindow.content = null
            logWindow.close()

            logItem.isInWindow = false
            logItem.visible = true
            mainVerticalSplit.addItem(logItem)
            contentWrap.height = contentWrap.height - 200
        }

        function toggleLog(){
            if ( logView.isInWindow ){
                if ( logView.visible ){
                    logWindow.close()
                    logView.visible = false
                } else {
                    header.isLogWindowDirty = false
                    logView.visible = true
                    logWindow.show()
                }
            } else {
                if ( logView.visible ){
                    logView.visible = false
                    mainVerticalSplit.removeItem(logView)
                } else {
                    header.isLogWindowDirty = false
                    logView.visible = true
                    mainVerticalSplit.addItem(logView)
                    contentWrap.height = contentWrap.height - 200
                }
            }
        }

        Rectangle{
            id : contentWrap
            width: parent.width
            height: parent.height - 200

            property var palettes: []

            property var toggledItems: []
            function toggleMaximizedRuntime(){
                if ( toggledItems.length === 0 ){
                    toggledItems = [projectView.width, editor.width]
                    projectView.width = 0
                    editor.width = 0
                } else {
                    projectView.width = toggledItems[0]
                    editor.width = toggledItems[1]
                    toggledItems = []
                }
            }

            function toggleNavigation(){
                var ap = root.panes.activePane
                if ( ap.objectName === 'editor' ){
                    var navMenu = root.projectEnvironment.navigation
                    navMenu.parent = ap
                    navMenu.visible = !navMenu.visible
                }
            }

            SplitView{
                id: mainHorizontalSplit
                anchors.fill: parent
                orientation: Qt.Horizontal
                handleDelegate: Rectangle{
                    implicitWidth: 1
                    implicitHeight: 1
                    color: "#081019"
                }

                property var panes : [projectView, editor, viewer]
                property var paneSizes : [240, 400, -1]

                function insert(i, item){
                    item.height = mainHorizontalSplit.height

                    for ( var j = 0; j < panes.length; ++j ){
                        if ( paneSizes[j] !== -1 )
                            paneSizes[j] = panes[j].width
                    }

                    panes.splice(i, 0, item)
                    paneSizes.splice(i, 0, item.width)

                    for ( var j = i + 1; j < panes.length; ++j ){
                        mainHorizontalSplit.removeItem(panes[j])
                    }
                    for ( var j = i; j < panes.length; ++j ){
                        mainHorizontalSplit.addItem(panes[j])
                    }
                    for ( var j = 0; j < paneSizes.length; ++j ){
                        if ( paneSizes[j] !== -1 )
                            panes[j].width = paneSizes[j]
                    }
                }

                function removeAt(i){
                    mainHorizontalSplit.removeItem(panes[i])

                    panes.splice(i, 1)
                    paneSizes.splice(i, 1)
                }

                property var editors: [editor]

                ProjectFileSystem{
                    id: projectView
                    height: parent.height
                    width: 240
                    panes: root.panes
                    Component.onCompleted: {
                        root.panes.add(projectView, livecv.layers.window.window(), [1])
                    }
                }

                Editor{
                    id: editor
                    height: parent.height
                    width: 400
                    panes: root.panes
                    onInternalActiveFocusChanged: if ( internalFocus ) {
                        root.panes.setActiveItem(editor.textEdit, editor)
                    }

                    Component.onCompleted: {
                        root.panes.add(editor, livecv.layers.window.window(), [2])
                        root.panes.setActiveItem(editor.textEdit, editor)
                        if ( project.active ){
                            editor.document = project.active
                        }
                        forceFocus()
                    }
                }

                Rectangle{
                    id : viewer
                    height : parent.height
                    objectName: "viewer"

                    color : "#000509"

                    Item{
                        id: runSpace
                        anchors.fill: parent
                    }

                    Connections{
                        target: livecv.engine
                        onObjectReady : { error.text = '' }
                        onObjectCreationError : {
                            var errorMessage = error.wrapMessage(errors)
                            error.text = errorMessage.rich
                            console.error(errorMessage.log)
                        }
                    }

                    ErrorContainer{
                        id: error
                        anchors.bottom: parent.bottom
                        width : parent.width
                        color : editor.color
                        font.pointSize: editor.font.pointSize
                    }

                }
            }
        }
    }

    property LogContainer logView : LogContainer{
        id: logView
        visible: false
        isInWindow: false
        width: parent ? parent.width : 0
        height: 200

        onItemAdded: {
            if ( !visible  )
                header.isLogWindowDirty = true
        }
    }

}
