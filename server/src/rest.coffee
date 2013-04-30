_ = require 'underscore'
async = require 'async'
{set_json, get_json, redis} = require './persist'
{arg_map, fail_on_error, die_on_error} = require './util'

PREFIX = "short"

types = {}
add_type = (app, type, {after_add, before_del, after_get} = {}) ->
    after_add ?= (model, callback) -> callback()
    before_del ?= (model, callback) -> callback()
    after_get ?= (model, callback) -> callback null, model

    add = (data, callback) ->
        write = ->
            set_json "#{PREFIX}:#{type}s:#{data.id}", data, fail_on_error callback, ->
                redis.rpush "#{PREFIX}:#{type}s", data.id, fail_on_error callback, ->
                    after_add data, fail_on_error callback, ->
                        callback null, data
        if data.id?
            write data
        else
            redis.incr "#{PREFIX}:#{type}_count", fail_on_error callback, (id) ->
                data.id = "#{id}"
                write data


    save = (data, callback) ->
        console.log 'Save!'
        if not data.id?
            console.log 'No id!'
            add data, callback
        else
            key = "#{PREFIX}:#{type}s:#{data.id}"
            redis.get key, fail_on_error callback, (previous) ->
                console.log previous
                if previous?
                    set_json key, data, callback
                else
                    console.log 'No previous!'
                    add data, callback

    del = (id, callback) ->
        get id, fail_on_error callback, (model) ->
            before_del model, fail_on_error callback, ->
                redis.del "#{PREFIX}:#{type}s:#{id}"
                redis.lrem "#{PREFIX}:#{type}s", 0, id, callback

    get = (id, callback) ->
        get_json "#{PREFIX}:#{type}s:#{id}", fail_on_error callback, (data) ->
            if data?
                console.log "#{PREFIX}:#{type}s:#{id}"
                after_get data, callback
            else
                callback "No such users #{id}"

    get_collection = (ids = [], callback) ->
        arg_map async.map, 'array', 'iterator', 'callback',
            array: ids
            iterator: get
            callback: callback

    get_all = (callback) ->
        get_range 0, -1, callback

    get_range = (start, end, callback) ->
        redis.lrange "#{PREFIX}:#{type}s", start, end, fail_on_error callback, (model_ids) ->
            get_collection model_ids, callback

    count = (callback) ->
        redis.llen "#{PREFIX}:#{type}s", callback


    load_child_list = (model, child, child_type, callback) ->
        redis.lrange "#{PREFIX}:#{type}s:#{model.id}:#{child}", 0, -1,
            fail_on_error callback, (child_ids) ->
                child_type.get_collection child_ids, fail_on_error callback, (children) ->
                    model[child] = children
                    callback null, model

     load_child_set = (model, child, child_type, callback) ->
        redis.smembers "#{PREFIX}:#{type}s:#{model.id}:#{child}",
            fail_on_error callback, (child_ids) ->
                child_type.get_collection child_ids, fail_on_error callback, (children) ->
                    model[child] = children
                    callback null, model


    app.post "/#{type}s", (req, res) ->
        add JSON.parse(req.body.json), die_on_error res, (model) ->
            res.send 200, JSON.stringify model

    app.get "/#{type}s.json", (req, res) ->
        get_all die_on_error res, (models) ->
            res.send 200, JSON.stringify models

    app.get "/#{type}s", (req, res) ->
        get_all die_on_error res, (models) ->
            res.send 200, JSON.stringify models

    app.get "/#{type}s/range/:start::end", (req, res) ->
        start = parseInt req.params.start
        end   = parseInt req.params.end
        get_range start, end, die_on_error res, (models) ->
            res.send 200, JSON.stringify models

    app.get "/#{type}s/count", (req, res) ->
        count die_on_error req, (count) ->
            res.send 200, "#{count}"

    app.get "/#{type}/:id", (req, res) ->
        {id} = req.params
        get id, die_on_error res, (models) ->
            res.send 200, JSON.stringify models

    app.delete "/#{type}/:id", (req, res) ->
        {id} = req.params
        del id, die_on_error res, (removed) ->
            res.send 200, removed

    app.post "/#{type}/:id", (req, res) ->
        model = JSON.parse req.body.json
        model.id = req.params.id
        console.log 'Saving with id...'
        save model, die_on_error res, (saved) ->
            res.send 200, saved

    type_dict = {add, save, del, get, get_collection, count, load_child_list, get_all, get_range,  load_child_set}
    types[type] = type_dict
    type_dict

module.exports = { add_type, types, PREFIX }
