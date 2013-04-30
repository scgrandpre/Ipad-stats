$ ->
    draw = (ctx, fn) ->
        {height, width} = ctx.canvas
        for x in [0...width]
            t = x/width
            ctx.fillStyle = fn(t)
            ctx.fillRect x, 0, x, height
    canvas = $('.colorpicker').find('canvas')

    hsl = (hue, saturation, lightness) ->
        {hue: hue/360, saturation: saturation/100, lightness: lightness/100}

    format_hsl = ({hue, saturation, lightness}) ->
        hue = (hue* 360 + 360) % 360
        x = "hsl(#{Math.round hue}, #{Math.round saturation * 100}%, #{Math.round lightness * 100}%)"
        console.log x
        x

    point = (weight, color) -> color #{weight, color}

    points = [
        point 1, hsl 0,  100, 100
        point 1, hsl -3, 79, 52
        point 1, hsl 53,  76, 72
        point 1, hsl 152, 63, 43
        point 1, hsl 186, 38, 64
        point 1, hsl 206, 75, 42
        point 1, hsl 360, 0 , 50
        point 1, hsl 360, 0 , 0
    ]

    tween = (t, start, end) ->
        x = t * (end - start) + start
        x

    tween_hsl = (t, start, end) ->
        hue:        tween t, start.hue       , end.hue
        saturation: tween t, start.saturation, end.saturation
        lightness:  tween t, start.lightness , end.lightness

    distance = (p0, p1) -> (p0 - p1) * (p0 - p1)

    color_function = (t) ->
        scaled_t = t * (points.length - 1)
        region  = Math.floor scaled_t
        partial = scaled_t - region

        if false && (distance 0, partial - .5) < .0005
            format_hsl hsl 0, 0, 0
        else
            color = tween_hsl(partial, points[region], points[region + 1] ? points[region])
            purity = (distance (color.hue * 360 % 120), 60)/(120 * 120)
            dist =  (distance ((partial + .5) % 1) , .5)
            console.log purity, dist
            purity *= dist
            if purity < .020
                format_hsl color
            else
                console.log "IN!"
                purity -= .02
                color.saturation /= (1 + purity * purity * 20)
                format_hsl color



    draw canvas[0].getContext('2d'), color_function

    canvas.on 'mousemove', ({pageX: x}) ->
        t = Math.min 1, Math.max 0, (x - canvas.offset().left)/canvas.width()
        $('body').css background: color_function t


