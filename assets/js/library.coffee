$ ->
    {user} = config
    filepicker.setKey('AFCPOvoguSQ6AvRlcJUnFz')
    $add_file = $ '.add-file'

    save_user = ->
        $.post "/user/#{user.id}", {json: JSON.stringify user}, ->

    register_handlers = (type, node) ->
        console.log type
        node.on 'click', ->
            index = node.parent().children().index node
            console.log index, user.library[type][index]?.url, node.find('img').attr 'src'
            user.library[type][index..index] = []
            node.remove()
            save_user()
    $('.image').each (idx, el) -> register_handlers 'images', $ el
    $('.code').each (idx, el) -> register_handlers 'code', $ el

    filepicker.makeDropPane $add_file[0],
        mimetypes: ['image/*', 'text/html']
        multiple: true
        onSuccess: (fpfiles) ->
            console.log fpfiles
            for {url, mimetype} in fpfiles
                if mimetype == 'text/html'
                    user.library.code.push {url}
                else
                    user.library.images.push {url}
                save_user()
                $img = $ """<div class="image"><img src="#{url}"><div class='remove'><div class="remove-label">Remove</div></div></div>"""
                $('.images').append $img
                register_handlers $img
