module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Events exposing (onKeyDown)
import Html exposing (Html, button, div, text)
import Json.Decode as Decode
import Time


claerInterval =
    5


type alias KeySwitch =
    { brand : SwitchBrand
    , switchType : SwitchType
    , series : Maybe String
    , name : String
    , silent : Bool
    , price : Int
    }


type SwitchBrand
    = Gateron
    | Kailh
    | Outemu
    | Cherry


type SwitchType
    = Linear
    | Tactile
    | Clicky


switch : SwitchBrand -> SwitchType -> String -> String -> Bool -> Int -> KeySwitch
switch brand sType series name slient price =
    { brand = brand
    , switchType = sType
    , series = series
    , name = name
    , silent = silent
    , price = price
    }


keyMappings : { key : Char, switch : KeySwitch }
keyMappings =
    [ { key = 'a', switch = switch Gateron Linear Nothing "Red" false 48 }
    , { key = 'b', switch = switch Gateron Tactile Nothing "Brown" false 48 }
    , { key = 'c', switch = switch Gateron Clicky Nothing "Blue" false 48 }
    , { key = 'd', switch = switch Gateron Linear Nothing "Clear" false 48 }
    ]


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { count : Int
    , key : String
    , modifier : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { count = 0, key = "", modifier = "" }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | Input Key


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick _ ->
            if model.count >= claerInterval then
                ( { model | count = 0, key = "", modifier = "" }, Cmd.none )

            else
                ( { model | count = model.count + 1 }, Cmd.none )

        Input (Character c) ->
            ( { model | key = String.fromChar c }, Cmd.none )

        Input (Control s) ->
            ( { model | modifier = s }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every 1000 Tick
        , onKeyDown (Decode.map Input keyDecoder)
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] [ text (String.fromInt model.count) ]
        , div [] [ text model.key ]
        , div [] [ text model.modifier ]
        ]



-- KEY DECODER


type Key
    = Character Char
    | Control String


keyDecoder : Decode.Decoder Key
keyDecoder =
    Decode.map toKey (Decode.field "key" Decode.string)


toKey : String -> Key
toKey string =
    case String.uncons string of
        Just ( char, "" ) ->
            Character char

        _ ->
            Control string
