import QtQuick 2.3

Item {
    property string tagType: ""
    property var tagArguments: [] //The supplied key/value pairs will be added to the array using tagArguments[key]=value, if a value is passed using an equals sign after the tag name, it will be added using tagArguments[""]=value
    //Only one of the following two is used at a time
    property string text: ""
    property var childElements: []
}
