$ ->
    $('.save').on 'click', ->
        config = {}
        $('input').each (idx, el) ->
            input = $(el)

            val = input.val()
            floatVal = parseFloat val, 10
            if floatVal.toString() == val
                val = floatVal

            config[input.attr 'class'] = val

        $.post '/config', {json: JSON.stringify config}, ->
            alert 'Saved!'
