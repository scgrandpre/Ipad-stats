module.exports = (app) ->
    {die_on_error} = require './util'
    {types} = require './rest'


    app.get '/', (req, res) ->
        res.render 'login'

    app.get '/library/:user_id', (req, res) ->
        {user_id} = req.params
        types.user.get user_id, die_on_error res, (user) ->
            user.library ?= {}
            user.library.images ?= []
            user.library.code ?= []
            res.render 'library', {user}


