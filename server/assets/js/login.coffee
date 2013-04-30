window.facebookInitialized = ->
    login = ({userID}) ->
        window.location.href = "/library/#{userID}"

    FB.getLoginStatus ({status, authResponse}) ->
        if status == 'connected'
            login authResponse
        else
            FB.login ({authResponse}) ->
                if authResponse
                    login authResponse
                else
                    alert 'Login Failed. Refresh to try again'
