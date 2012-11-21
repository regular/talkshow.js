class DataSource

    constructor: (args, cb) ->
        {@grid, @level, @nodeId, @parent, @position, @delegate, @storage} = args
        
        @level ?= 1
        @cells = {}
        @children = {}

        @factory = new CellFactory
            labelTextChanged: (cell, text, cb) =>
                #console.log  "labelTextChanged", cell, text
                @save cell, "label", text, cb
        
            contentChanged: (cell, aspect, dataUri, cb) =>
                @save cell, aspect, dataUri, cb

            cellChanged: (cell, cb) =>
                @save cell, "cell", cb
        , args

        @initialize cb
            
    initialize: (cb) ->
        if @nodeId?
            async.parallel [
                (cb) => @storage.get "node_#{@nodeId}_cells", cb
                (cb) => @storage.get "node_#{@nodeId}_children", cb
            ], (err, results) =>
                if err? then return cb err
                [@cells, @children] = results
                @cells ?= {}
                @children ?= {}
                cb null, this
        else
            cb null, this
        

    setChild: (pos, id, cb) ->
        @children["#{pos.x}/#{pos.y}"] = id
        @ensureNodeId (err) =>
            if err? then return cb err
            @storage.save "node_#{@nodeId}_children", @children, cb

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
            @storage.save "node_#{@nodeId}_cells", @cells, cb
    
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

            @storage.get "cell_#{id}", (err, obj) =>
                if err? then return cb err
                obj = {} if obj is null
        
                obj[aspect] = data
                @storage.save "cell_#{id}", obj, cb
            
    colorForCell: (x, y) ->
        index = x+y*4 % 6 + 1
        color = index.toString(2)
        color = "000".substr(0,3-color.length) + color
        color = color.replace(/1/g, "255,").replace(/0/g, "112,")
        color += ".3"; # alpha
        color = "rgba(#{color})"
        return color
    
    cellData: (x,y, cb) ->
        ensureLabel = (o, level, nodeId) ->
            if not ("label" of o)
                o.label = "level#{level}(##{nodeId}): #{x}/#{y}"
        
        obj = {}
        key = "#{x}/#{y}"
        if key of @cells
            id = @cells[key]
            @storage.get "cell_#{id}", (err, obj) =>
                if err? then return cb err
                obj ?= {}
                obj.id = id
                ensureLabel obj, @level, @nodeId
                cb null, obj
        else
            ensureLabel obj, @level, @nodeId
            cb null, obj
        
    enterCell: (x, y, cb) ->
        console.log "entering cell #{x}/#{y}"
        childNodeId = null
        
        if @children
            key = "#{x}/#{y}"
            if key of @children
                childNodeId = @children[key]

        console.log "nodeId", childNodeId
        
        @cellData x,y, (err, data) =>
            if err? then return cb err
            
            if childNodeId is null
                if data.sound
                    audioPlayer = new AudioPlayer(data.sound)
                    return cb null, {content: 'sound'}
                else if data.photo
                    imagePlayer = new ImagePlayer(data.photo)
                    return cb null, {content: 'photo'}
        
            if @delegate?
                @delegate.enteredCell this, {x:x,y:y}, @level + 1, childNodeId, data, cb
            else
                cb null
    
    cellForPosition: (x, y, cb) ->
        @cellData x,y, (err, data) =>
            if err? then return cb err
            
            color = @colorForCell x,y
            
            cell = @factory.makeCell data, color
            
            if "id" of data
                cell.attr "id", data.id
        
            cell.click () =>
                @enterCell x,y, =>
                
            cb null, cell

window.DataSource = DataSource