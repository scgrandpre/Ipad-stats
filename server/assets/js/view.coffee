$ ->
    {deck} = config

    CARDS_PER_PAGE = 1.3
    IPHONE_WIDTH = 640
    IPHONE_HEIGHT = 960

    console.log deck
    $deck = $ '.deck'

    make_element =
        TextElement: ({text}) -> $ """<div class="text-element"><div class="text">#{text}</div></div>"""
        ImageElement: ({url}) -> $ ''

    image_url = (url) ->
        "http://frankresizr-902207972.us-east-1.elb.amazonaws.com/#{btoa url}-10000x10000-b.jpg"

    render_cards = (width, height, scale_factor) ->
        for card in deck.cards
            $card = $ """<div class="card"></div>"""
            $card.css {height, width, 'margin-bottom': height/100}

            card_has_background = false
            $deck.append $card
            for element in card.elements
                $card.append make_element[element.type]?(element)
                console.log element

                if element.type == "TextElement"
                    {red, green, blue, alpha} = element.color

                    charCount = element.text.length
                    if charCount > 200
                        fontSize = 16.0
                    else if charCount > 120
                        fontSize = 22.0
                    else if charCount > 80
                        fontSize = 28.0;
                    else if charCount > 40
                        fontSize = 34.0
                    else
                        fontSize = 42.0

                    font_size = "#{fontSize * width / IPHONE_WIDTH * 2.5}px"
                    $card.css
                        'background-color': "rgba(#{Math.floor red * 255}, #{Math.floor green * 255}, #{Math.floor blue * 255}, #{alpha})"

                    $card.find('.text').css
                        'color': if red + green + blue < 2.7 then "rgb(255, 255, 255)" else "rgb(0, 0, 0)"
                        'font-size': font_size
                        'line-height': font_size
                        'text-align': if charCount < 40 then 'center' else 'left'
                        'padding': "#{20 * width/IPHONE_WIDTH}px"

                else if element.type == "ImageElement"
                    img = new Image();
                    img.onload = do (element, $card, img) -> ->
                        {scale, center, url} = element
                        scale *= 2
                        $card.css
                            'background-image': "url(#{image_url url})"
                            'background-size': "#{img.width * scale * scale_factor}px #{img.height * scale * scale_factor}px"
                            'background-repeat': 'no-repeat'
                            'background-position': "#{width/2 - center.X * scale * scale_factor}px #{height/2 - center.Y * scale * scale_factor}px"

                        $card.find('.text').css
                            'color': "rgb(255, 255, 255)"

                    img.src = image_url element.url
                    console.log image_url element.url


    resize = ->
        $window = $(window)
        height = $window.height()
        width = IPHONE_WIDTH/IPHONE_HEIGHT * height
        height *= .75

        $('.card').remove()
        scale_factor = width/IPHONE_WIDTH

        $deck.width width
        render_cards width, height, scale_factor


    $(window).on 'resize', resize
    resize()


