import QtQuick 2.3

Item {
    property string tagType: ""
    property var tagArguments: [] //The supplied key/value pairs will be added to the array using: tagArguments[key]=value
    //Only one of the following two is used at a time
    property string text: ""
    property var childElements: []
}
