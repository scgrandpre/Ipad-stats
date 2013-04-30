$ ->
    canvas = $ 'canvas'
    context = canvas[0].getContext '2d'
    height = $(window).height()
    width = $(window).width()

    canvas.height height
    canvas.width width
    canvas[0].height = height
    canvas[0].width = width


    balls = [{radius: 50, position: {x: 100, y: 100}, velocity: {x: 5, y: 5}}]
    playing = false
    framecount = 0
    doframe = ->
        framecount++
        speed = 1
        animate = ->
            for ball in balls
                ball.position.x += ball.velocity.x * speed
                ball.position.y += ball.velocity.y * speed
                if ball.position.x - ball.radius < 0
                    ball.position.x = -(ball.position.x - ball.radius) + ball.radius
                    ball.velocity.x *= -1
                if (ball.position.x + ball.radius) > width
                    ball.position.x = (width - (ball.position.x + ball.radius - width)) - ball.radius
                    ball.velocity.x *= -1

                if ball.position.y - ball.radius < 0
                    ball.position.y = -(ball.position.y - ball.radius) + ball.radius
                    ball.velocity.y *= -1
                if (ball.position.y + ball.radius) > height
                    ball.position.y = (height - (ball.position.y + ball.radius - height)) - ball.radius
                    ball.velocity.y *= -1
        animate()

        draw = ->
            context.clearRect 0, 0, width, height
            for ball in balls
                context.beginPath();
                context.arc ball.position.x, ball.position.y, ball.radius, 0, Math.PI *2, true
                context.closePath();
                context.fillStyle = 'blue'
                context.fill();


        draw()

        if playing
            requestAnimationFrame doframe
    do doframe

    window.play = ->
        playing = true
        do doframe

    window.pause = ->
        playing = false

    distance2 = ({x: x0, y: y0}, {x: x1, y: y1}) ->
        (x0 - x1) * (x0 - x1) + (y0 - y1) * (y0 - y1)


    closestBallToPoint = (x, y) ->
        closestDistance = Infinity
        closest = null
        for ball in balls
            d = distance2 ball.position, {x, y}
            if d < closestDistance
                closestDistance = d
                closest = ball
        closest

    split = (ball) ->
        balls = _(balls).without ball
        newRad = ball.radius/2
        balls.push
            radius: newRad
            position:
                x: ball.position.x - newRad - 1
                y: ball.position.y
            velocity:
                x: -ball.velocity.x
                y: ball.velocity.y + (6 * Math.random()) - 3

        balls.push
            radius: newRad
            position:
                x: ball.position.x - newRad + 1
                y: ball.position.y
            velocity:
                x: ball.velocity.x
                y: ball.velocity.y + (6 * Math.random()) - 3



    do_click = (x, y) ->
        split closestBallToPoint x, y

    canvas.click (e) ->
        do_click e.pageX, e.pageY

