module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Events exposing (onKeyDown)
import Debug
import Dict exposing (Dict)
import Dict.Extra
import Html exposing (Html, dd, div, dl, dt, h2, img, p, text)
import Html.Attributes exposing (src, style)
import Http
import Json.Decode exposing (Decoder, at, field, int, list, map3, string)
import Time


claerInterval =
    5


urlOfSwitchesSpreadsheetJson =
    "https://spreadsheets.google.com/feeds/cells/1G0grm4xDFYO-9X4sWX7A8I2V7ag2H9fG2zTa2dnkgow/od6/public/values?alt=json"


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
    , status : Status
    }


type Status
    = Initial
    | Loading
    | Tester (List KeyMapping)


init : () -> ( Model, Cmd Msg )
init _ =
    ( { count = 0, key = "", modifier = "", status = Loading }
    , Http.get
        { url = urlOfSwitchesSpreadsheetJson
        , expect = Http.expectJson GotResponse switchJsonDecoder
        }
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | Input Key
    | GotResponse (Result Http.Error (List Cell))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotResponse result ->
            case result of
                Ok cells ->
                    ( { model | status = Tester (toKeyMappings cells) }, Cmd.none )

                -- ( { model | modifier = Debug.toString (toKeyMappings cells) }, Cmd.none )
                Err _ ->
                    ( { model | modifier = "error" }, Cmd.none )

        Tick _ ->
            if model.count >= claerInterval then
                ( { model | count = 0, key = "", modifier = "" }, Cmd.none )

            else
                ( { model | count = model.count + 1 }, Cmd.none )

        Input (Character c) ->
            ( { model | count = 0, key = String.fromChar c }, Cmd.none )

        Input (Control s) ->
            ( { model | modifier = s }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every 1000 Tick
        , onKeyDown (Json.Decode.map Input keyDecoder)
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div [ style "text-align" "center" ]
        [ viewSwitch (switchOf model)
        , viewDebugInfo model
        ]


viewSwitch : Maybe KeyMapping -> Html Msg
viewSwitch mapping =
    case mapping of
        Nothing ->
            viewDefault

        Just m ->
            dl []
                (List.append
                    [ h2 [] [ text ("押したスイッチ: " ++ m.switch) ] ]
                    (viewSwitchAttr m)
                )


viewSwitchAttr : KeyMapping -> List (Html Msg)
viewSwitchAttr m =
    Dict.toList m.attr
        |> List.map
            (\( k, v ) ->
                [ p [] [ text (k ++ ": " ++ v) ]
                ]
            )
        |> List.concat


viewDefault : Html Msg
viewDefault =
    div []
        [ img
            [ src "../assets/computer_blindtouch.png"
            , style "width" "25%"
            , style "height" "25%"
            ]
            []
        , p []
            [ text "スイッチを押してね！" ]
        ]


viewDebugInfo : Model -> Html Msg
viewDebugInfo model =
    div [ style "color" "white" ]
        [ div [] [ text (String.fromInt model.count) ]
        , div [] [ text model.key ]
        , div [] [ text model.modifier ]
        ]


switchOf : Model -> Maybe KeyMapping
switchOf model =
    case model.status of
        Tester mappings ->
            List.head (List.filter (\k -> k.key == model.key) mappings)

        _ ->
            Nothing



-- KEY DECODER


type Key
    = Character Char
    | Control String


keyDecoder : Json.Decode.Decoder Key
keyDecoder =
    Json.Decode.map toKey (Json.Decode.field "key" Json.Decode.string)


toKey : String -> Key
toKey string =
    case String.uncons string of
        Just ( char, "" ) ->
            Character char

        _ ->
            Control string



-- Switch JSON DECODER


switchJsonDecoder : Decoder (List Cell)
switchJsonDecoder =
    at [ "feed", "entry" ] (list entryDecoder)


entryDecoder : Decoder Cell
entryDecoder =
    map3 Cell
        (at [ "gs$cell", "row" ] string)
        (at [ "gs$cell", "col" ] string)
        (at [ "gs$cell", "$t" ] string)


type alias Cell =
    { row : String, col : String, value : String }


type alias KeyMapping =
    { key : String
    , switch : String
    , attr : Dict String String
    , row : Int
    }


toKeyMappings : List Cell -> List KeyMapping
toKeyMappings cells =
    let
        grouped : Dict String (List Cell)
        grouped =
            Dict.Extra.groupBy .row cells

        headers =
            Dict.get "1" grouped
                |> Maybe.withDefault []
                |> List.map (\c -> ( c.col, c.value ))
                |> Dict.fromList

        rows : List (List Cell)
        rows =
            Dict.values grouped

        rowToRecord cols =
            let
                rowToRecord_ cols_ record =
                    case cols_ of
                        col :: rest ->
                            case col.col of
                                "1" ->
                                    rowToRecord_ rest record

                                "2" ->
                                    rowToRecord_ rest record

                                "3" ->
                                    rowToRecord_ rest { record | key = col.value }

                                "4" ->
                                    rowToRecord_ rest { record | switch = col.value }

                                _ ->
                                    rowToRecord_ rest { record | attr = Dict.insert (Dict.get col.col headers |> Maybe.withDefault "") col.value record.attr }

                        [] ->
                            record
            in
            rowToRecord_ cols (KeyMapping "" "" Dict.empty 0)
    in
    List.map rowToRecord rows
