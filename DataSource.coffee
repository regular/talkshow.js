class DataSource

    constructor: (options, cb) ->
        {@grid, @level, @nodeId, @parent, @position, @delegate} = options
        
        @level ?= 1
        @cells = {}
        @children = {}
    
        if @nodeId?
            @cells = JSON.parse(localStorage.getItem "node_#{@nodeId}_cells") ? {}
            @children = JSON.parse(localStorage.getItem "node_#{@nodeId}_children") ? {}
            
        cellDelegate =
            labelTextChanged: (cell, text) =>
                console.log  "labelTextChanged", cell, text
                @save(cell, "label", text)
            
            contentChanged: (cell, aspect, dataUri) =>
                @save(cell, aspect, dataUri);

            cellChanged: (cell) =>
                @save(cell, "cell")

        @factory = new CellFactory cellDelegate

    setChild: (pos, id) ->
        @children["#{pos.x}/#{pos.y}"] = id
        @ensureNodeId()
        localStorage.setItem("node_#{@nodeId}_children", JSON.stringify @children )

    ensureNodeId: () ->
        if not @nodeId?
            @nodeId = window.uniqueId()
            if @parent?
                @parent.setChild @position, @nodeId
            else
                console.log "root nodeId is #{@nodeId}" 
                localStorage.setItem "root", @nodeId
    
    save: (cell, aspect, data) ->
        if aspect is "id"
            row = cell.closest("tr")
            x = cell.index()
            y = row.index()
            id = cell.attr("id")
            @cells["#{x}/#{y}"] = id
            console.log "cell #{x}/#{y} changed id: #{id}"
            @ensureNodeId()
            localStorage.setItem "node_#{@nodeId}_cells", JSON.stringify @cells
        else
            id = cell.attr "id"
            if not id?
                id = window.uniqueId()
                cell.attr "id", id
                @save cell, "id"

            console.log "saving #{id} #{aspect}"
            obj = localStorage.getItem "cell_#{id}"
            if obj is null
                obj = {}
            else
                obj = JSON.parse(obj)
            
            obj[aspect] = data
            console.dir obj 
            obj = JSON.stringify obj
            localStorage.setItem "cell_#{id}", obj
    
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