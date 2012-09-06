class DataSource

    constructor: (options) ->
        {@grid, @level, @nodeId, @parent, @position, @delegate, @storage} = options
        
        @level ?= 1
        @cells = {}
        @children = {}
    
        if @nodeId?
            @cells = JSON.parse(localStorage.getItem "node_#{@nodeId}_cells") ? {}
            @children = JSON.parse(localStorage.getItem "node_#{@nodeId}_children") ? {}
        
        cellDelegate =
            labelTextChanged: (cell, text, cb) =>
                console.log  "labelTextChanged", cell, text
                @save cell, "label", text, cb
            
            contentChanged: (cell, aspect, dataUri, cb) =>
                @save cell, aspect, dataUri, cb

            cellChanged: (cell, cb) =>
                @save cell, "cell", cb

        @factory = new CellFactory cellDelegate

    setChild: (pos, id, cb) ->
        @children["#{pos.x}/#{pos.y}"] = id
        @ensureNodeId (err) =>
            if err? then return cb err
            localStorage.setItem("node_#{@nodeId}_children", JSON.stringify @children )
            cb null

    ensureNodeId: (cb) ->
        if not @nodeId?
            window.uniqueId (err, id) =>
                if err then return cb err
                @nodeId = id
                if @parent?
                    @parent.setChild @position, id, cb
                else
                    console.log "root nodeId is #{@nodeId}" 
                    @storage.save "root", {value: @nodeId}, cb
        else
            cb null
    
    setCellId: (cell, id, cb) ->
        row = cell.closest("tr")
        x = cell.index()
        y = row.index()
        cell.attr("id", id)
        @cells["#{x}/#{y}"] = id
        console.log "cell #{x}/#{y} changed id: #{id}"
        @ensureNodeId (err) =>
            if not @nodeId? then alert "No nodeId after ensureNodeId"
            if err? then return cb err
            localStorage.setItem "node_#{@nodeId}_cells", JSON.stringify @cells
            cb null
    
    ensureCellId: (cell, cb) ->
        console.log "ensureCellId"
        id = cell.attr "id"
        if id? then return cb null
        console.log "calling uniqueId"

        window.uniqueId (err, id) =>
            console.log "uniqueId returned #{err}, #{id}"

            if err? then return cb err
            @setCellId cell, id, cb
        
    save: (cell, aspect, data, cb) ->
        
        @ensureCellId cell, (err) =>
            if err? then return cb err
            id = cell.attr 'id'
            console.log "saving #{aspect} of cell #{id}"
            obj = localStorage.getItem "cell_#{id}"
            if obj is null
                obj = {}
            else
                obj = JSON.parse(obj)
        
            obj[aspect] = data
            console.dir obj 
            obj = JSON.stringify obj
            localStorage.setItem "cell_#{id}", obj
            cb null
            
    colorForCell: (x, y) ->
        index = x+y*4 % 6 + 1
        color = index.toString(2)
        color = "000".substr(0,3-color.length) + color
        color = color.replace(/1/g, "255,").replace(/0/g, "112,")
        color += ".3"; # alpha
        color = "rgba(#{color})"
        return color
    
    cellData: (x,y) ->
        ret = {}
        key = "#{x}/#{y}"
        if key of @cells
            id = @cells[key]
            obj = JSON.parse localStorage.getItem "cell_#{id}"
            ret = obj if obj?
            ret.id = id
        
        if not ("label" of ret)
            ret.label = "level#{@level}(##{@nodeId}): #{x}/#{y}"

        return ret
    
    labelForCell: (x, y) ->
        obj = cellData x,y 
        return obj.label
    
    enterCell: (x, y) ->
        console.log "entering cell #{x}/#{y}"
        childNodeId = null
        
        if @children
            key = "#{x}/#{y}"
            if key of @children
                childNodeId = @children[key]

        console.log "nodeId", childNodeId
        
        if childNodeId is null
            data = @cellData x,y
            if data.sound
                audioPlayer = new AudioPlayer(data.sound)
                return

            if data.photo
                imagePlayer = new ImagePlayer(data.photo)
                return
            
        
        @delegate?.enteredCell this, {x:x,y:y}, @level + 1, childNodeId
    
    cellForPosition: (x, y) ->
        #label = labelForCell x,y
        data = @cellData x,y
        color = @colorForCell x,y
            
        cell = @factory.makeCell data, color
            
        if "id" of data
            cell.attr "id", data.id
        
        cell.click () =>
            @enterCell x,y
        
        return cell

window.DataSource = DataSource