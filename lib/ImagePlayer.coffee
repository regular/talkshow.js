ModalDialog = require './ModalDialog'

class ImagePlayer extends ModalDialog

    constructor: (dataURI, cb) ->
        super '.imagePlayer .dialog', cb
        @img = $('.imagePlayer img')[0]
        $(@img).attr "src", dataURI
                    
module.exports = ImagePlayer
    