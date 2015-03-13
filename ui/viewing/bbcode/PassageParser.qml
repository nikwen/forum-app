import QtQuick 2.3

Item {
    id: passageParser

    readonly property variant tagsWithChildren: [ "quote", "img", "spoiler", "hide" ] //lower-case

    Component {
        id: passage
        Passage {}
    }

    function parse(tagType, tagArguments, content) { //Post content which should be parsed
        var oldPos = 0
        var pos = -1

        //Create a root item which will contain all subsequent passages or, if none can be found, the unformatted text.
        var root = passage.createObject(passageParser, { "tagType": tagType, "tagArguments": tagArguments }) //No other parent here in order to simplify the fuction signature

        //Search for possible tags in the post by finding opening brackets.
        while ((pos = content.indexOf("[", pos + 1)) !== -1) {
            var bracketClosePos = content.indexOf("]", pos + 1)

            //Check if the tag has arguments.
            //The Tapatalk plugin seems to pass all arguments in a standardized form:
            // * [quote uid=123 name="author" post=12345678]
            //Not all arguments have to be supplied by all forums though.
            var spacePos = content.indexOf(" ", pos + 1)
            var argumentsStartPos = (spacePos !== -1) ? spacePos + 1 : -1
            var hasArguments = (argumentsStartPos !== -1) && (argumentsStartPos < bracketClosePos)

            //Get the tag, separated from the arguments
            var tag = content.substring(pos + 1, hasArguments ? spacePos : bracketClosePos).toLowerCase()

            //Get the arguments of the current tag.
            var arguments = []
            if (hasArguments) {
                //Split the arguments string to get the different key/value pairs.
                var argumentsString = content.substring(argumentsStartPos, bracketClosePos)
                var argumentsSplitted = argumentsString.split(" ") //TODO-r: Issue when the user name contains a blank
                for (var i = 0; i < argumentsSplitted.length; i++) {
                    if (argumentsSplitted[i] === "") {
                        continue
                    }

                    //Split "key=value" pairs.
                    //Do not use split() method here because that would also split the string if the value contains an equals char.
                    var keyEqualsPos = argumentsSplitted[i].indexOf("=")
                    if (keyEqualsPos < 0) {
                        console.log("Error when parsing key/value pair:", argumentsSplitted[i])
                        continue
                    }
                    var key = argumentsSplitted[i].substring(0, keyEqualsPos)
                    var value = argumentsSplitted[i].substring(keyEqualsPos + 1)

                    //Remove leading and trailing quotation marks from strings.
                    while (value.charAt(0) === "\"") {
                        value = value.substring(1)
                    }
                    while (value.charAt(value.length - 1) === "\"") {
                        value = value.substring(0, value.length - 1)
                    }

                    arguments[key] = value
                }
            }

            if (arrayContains(tagsWithChildren, tag)) { //else: don't parse
                var endPos = pos
                var moreStartTags = 1

                //Get the text between the brackets by looking for the respective closing bracket.
                //Skip similar passages in between by counting how many more tags have been opened in the meantime.
                while (moreStartTags > 0) {
                    //Get next position of the tag in the post
                    endPos = content.toLowerCase().indexOf(tag, endPos + tag.length)

                    if (endPos === -1) { //Cannot find more instances of that tag
                        break
                    }

                    //Get the tag (starting with the closing bracket before endPos and the opening one after endPos)
                    //If the word appeared in the text withouth brackets next to it, it will be ignored later as the part between the brackets isn't recognized as a tag
                    var currentTag = content.substring(content.lastIndexOf("[", endPos), content.indexOf("]", endPos) + 1).toLowerCase()

                    //Check if the tag is a closing or an opening tag and increase or decrease moreStartTags accordingly
                    if (currentTag === "[" + tag + "]") {
                        moreStartTags++
                    } else if (currentTag === "[/" + tag + "]") {
                        moreStartTags--
                    }
                    //else: Ignore the tag, maybe the word just appeared in the text (likely to happen for "quote")
                }

                //If the tag has been closed properly, push a new passage.
                //Otherwise ignore the tag and continue to look for tags after the tag.
                if (moreStartTags === 0) {
                    //Push not formatted text before the tag as an independent passage.
                    var notFormattedText = htmlTrim(content.substring(oldPos, pos))
                    if (notFormattedText !== "") {
                        root.childElements.push(parse("", [], notFormattedText))
                    }

                    //Push the new formatted passage.
                    root.childElements.push(parse(tag, arguments, htmlTrim(content.substring(bracketClosePos + 1, endPos - 2))))
                    oldPos = endPos + tag.length + 1
                    pos = oldPos
                } else { //Exited while-loop via break
                    oldPos = pos
                    pos = pos + tag.length
                }
            }
        }

        //If no tags were found, set the text property of root to the post content.
        //Otherwise push the text after the last tag as an unformatted passage.
        if (root.childElements.length === 0) {
            root.text = htmlTrim(content)
        } else {
            var restText = htmlTrim(content.substring(oldPos, content.length))
            if (restText !== "") {
                root.childElements.push(parse("", [], restText))
            }
        }
        return root
    }

    function arrayContains(array, value) {
        for (var i = 0; i < array.length; i++) {
            if (array[i] === value) {
                return true
            }
        }
        return false
    }

    //In addition to what the normal trim() method does, this will also remove html
    //line breaks (<br />) at the beginning and at the end of the given string.
    function htmlTrim(string) {
        while (true) {
            var trimmedString = string.trim()
            var breakIndex = string.indexOf("<br />")
            var breakLastIndex = string.lastIndexOf("<br />")
            if (trimmedString !== string) {
                string = trimmedString
            } else if (breakIndex === 0) {
                string = string.substring(6)
            } else if (breakLastIndex === string.length - 6) {
                string = string.substring(0, breakLastIndex)
            } else { //if nothing changes anymore
                return string
            }
        }
    }

}
