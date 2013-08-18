module.exports = (app) ->
    async = require 'async'

    # For now just a marker that a task is in the background,
    # reserves the right to
    background = (fn) ->
        process.nextTick fn

    log_error = (err) -> console.error err

    apns = require 'apn'
    apns_connection = new apns.Connection
        gateway: 'gateway.sandbox.push.apple.com'
        errorCallback: (err, notification) ->
            console.error err
            console.error notification

    feedback = new apns.Feedback
        interval: 20
        feedback: (err...) ->
            console.log err...

    apns_connection.on 'socketError', (err) ->
        console.error err
    apns_connection.on 'error', (err) ->
        console.error err

    send_notification = (device, alert) ->
        device = new apns.Device device.id
        note = new apns.Notification()
        note.alert = alert
        note.device = device
        apns_connection.sendNotification note

    send_user_notification = (user, alert) ->
        for device in user.devices
            send_notification device, alert


    {redis, get_json} = require './persist'
    {die_on_error, fail_on_error, arg_map} = require './util'
    {add_type, PREFIX: REST_PREFIX} = require './rest'

    game_type = add_type app, 'game'
    play_type = add_type app, 'play',
        after_add: (play, callback) ->
            io.sockets.emit 'add-play', play
            redis.rpush "#{REST_PREFIX}:games:#{play.game}:plays", play.id, callback

        before_del: (play, callback) ->
            redis.lrem "#{REST_PREFIX}:games:#{play.game}:plays", 1, play.id, callback

    io = require('socket.io').listen 8338

    io.sockets.on 'connection', (socket) ->
        socket.on 'message', (data) ->
            console.log data
