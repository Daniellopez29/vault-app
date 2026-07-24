/// Client ID "web" del proyecto de Firebase (android/app/google-services.json,
/// client_type 3) -- se pasa como `serverClientId` a [GoogleSignIn] para que
/// el idToken que devuelve tenga a este client id como audience, que es el
/// que el backend valida en GOOGLE_OAUTH_CLIENT_IDS. No es secreto: viaja
/// embebido en el apk igual que el resto de google-services.json.
const googleServerClientId =
    '49495820436-oq98o62p3vjedpee1v1k6afqadnt2i2o.apps.googleusercontent.com';
