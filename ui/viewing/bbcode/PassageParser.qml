import QtQuick 2.3

Item {
    id: passageParser

    readonly property variant tagsWithChildren: [ "quote", "code", "img", "spoiler", "hide" ] //lower-case

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
            //The Tapatalk plugin seems to pass most arguments in a standardized form:
            // * [quote uid=123 name="author" post=12345678]
            //Additionally, the following can be found:
            // * [img="description"]
            //Not all arguments have to be supplied by all forums though.
            //Difficulty here: The following can occur: [quote name=""the" viper" post=12345678] (note the double qoutes and the blank)
            var equalsPos = content.indexOf("=", pos + 1)
            var spacePos = content.indexOf(" ", pos + 1)
            var argumentsStartPos = (spacePos === -1) ? Math.min(equalsPos, bracketClosePos) : ((equalsPos === -1) ? Math.min(spacePos, bracketClosePos) : Math.min(spacePos, equalsPos, bracketClosePos))
            var hasArguments = (argumentsStartPos !== -1) && (argumentsStartPos < bracketClosePos)
            var hasArgumentNames = hasArguments && (argumentsStartPos === spacePos)

            //Get the tag, separated from the arguments
            var tag = content.substring(pos + 1, hasArguments ? argumentsStartPos : bracketClosePos).toLowerCase()

            //Get the arguments of the current tag.
            var arguments = []
            if (hasArguments) {
                if (hasArgumentNames) {
                    //Split the arguments string to get the different key/value pairs.
                    var argumentsString = content.substring(argumentsStartPos + 1, bracketClosePos)
                    var argumentsSplitted = argumentsString.split(" ")

                    //Iterate over the splitted arguments and add the found key/value pairs to the arguments array.
                    //If a string value starts with a quotation mark, it needs to end with a quotation mark as well.
                    //Everything will be added to the previous value until that trailing quotation mark can be found.
                    //If a trailing quotation mark is already present but the next string is no key/value pair, it
                    //is assumed that the quotation mark is actually part of the value and the new string is appended.
                    //Remaining (unfixable) weakness: Fails if the name contains something that could be parsed as
                    //an argument with a trailing quotation mark before it, e.g. 'Say "hello" title="me"'.

                    var currentKey = ""
                    var leadingQuotationMark = false
                    var trailingQuotationMark = false
                    for (var i = 0; i < argumentsSplitted.length; i++) {
                        //Split "key=value" pairs.
                        //Do not use the split() method here because that would split the string twice if the value contains an equals char.
                        var keyEqualsPos = argumentsSplitted[i].indexOf("=")

                        if (currentKey !== "" && (keyEqualsPos <= 0 || (leadingQuotationMark && !trailingQuotationMark))) {
                            //First part of the argument has already been parsed and
                            // (a) there has been no trailing but a leading quotation mark yet OR
                            // (b) the next value cannot be identified as a new "key=value" pair.
                            arguments[currentKey] += " " + argumentsSplitted[i]
                        } else if (keyEqualsPos > 0) {
                            //A new "key=value" pair could be found.

                            currentKey = argumentsSplitted[i].substring(0, keyEqualsPos)
                            arguments[currentKey] = argumentsSplitted[i].substring(keyEqualsPos + 1)

                            leadingQuotationMark = (arguments[currentKey].charAt(0) === "\"")
                        } else {
                            //A parsing error occured.

                            console.log("Failed to parse part \"" + argumentsSplitted[i] + "\" of arguments string \"" + argumentsString + "\"")

                            currentKey = ""
                            leadingQuotationMark = false
                            trailingQuotationMark = false

                            continue
                        }

                        trailingQuotationMark = leadingQuotationMark && (arguments[currentKey].charAt(arguments[currentKey].length - 1) === "\"")
                    }

                    for (var key in arguments) {
                        //Remove leading and trailing quotation marks from strings.
                        if (arguments[key].charAt(0) === "\"") {
                            arguments[key] = arguments[key].substring(1)
                        }
                        if (arguments[key].charAt(arguments[key].length - 1) === "\"") {
                            arguments[key] = arguments[key].substring(0, arguments[key].length - 1)
                        }
                    }
                } else {
                    //Add the whole string after the equals sign as one argument but remove leading and trailing quotation marks from it.
                    var argument = content.substring(argumentsStartPos + 1, bracketClosePos);
                    if (argument.charAt(0) === "\"") {
                        argument = argument.substring(1)
                    }
                    if (argument.charAt(argument.length - 1) === "\"") {
                        argument = argument.substring(0, argument.length - 1)
                    }
                    arguments[""] = argument
                }
            }

            if (arrayContains(tagsWithChildren, tag)) { //else: don't parse (also fails when bracketClosePos === -1 due to the substring method when tag is initialized)
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
