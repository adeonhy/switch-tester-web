module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Events exposing (onKeyDown)
import Debug
import Dict exposing (Dict)
import Dict.Extra
import Html exposing (Html, dd, div, dl, dt, h2, h3, img, p, span, text)
import Html.Attributes exposing (class, src, style)
import Http
import Json.Decode exposing (Decoder, at, field, int, list, map3, string)
import Time


claerInterval =
    20


urlOfSwitchesSpreadsheetJson =
    "https://spreadsheets.google.com/feeds/cells/1G0grm4xDFYO-9X4sWX7A8I2V7ag2H9fG2zTa2dnkgow/od6/public/values?alt=json"


urlOfTopImage =
    "https://www.dropbox.com/s/w9z5j7yh3h4rtzr/tester_top.png?raw=1"


urlOfNoImage =
    "https://www.dropbox.com/s/tipissf3lgqtom6/no_image.png?raw=1"


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
    , hitCount : Int
    }


type Status
    = Initial
    | Loading
    | Tester (List KeyMapping)


init : () -> ( Model, Cmd Msg )
init _ =
    ( { count = 0, key = "", modifier = "", status = Loading, hitCount = 0 }
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
            if model.key == String.fromChar c then
                ( { model | count = 0, hitCount = model.hitCount + 1 }, Cmd.none )

            else
                ( { model | count = 0, key = String.fromChar c, hitCount = 1 }, Cmd.none )

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
    div [ class "container" ]
        [ viewSwitchOrDefault model
        , viewDebugInfo model
        ]


viewSwitchOrDefault : Model -> Html Msg
viewSwitchOrDefault model =
    case switchOf model of
        Nothing ->
            viewDefault

        Just mapping ->
            viewSwitch mapping


viewSwitch : KeyMapping -> Html Msg
viewSwitch m =
    div []
        [ div [ class "summary" ]
            [ viewSwitchImage m
            , div [ class "summary-info" ]
                [ p [ class "switch-comment" ] [ text m.comment ]
                , p [ class "switch-name" ] [ text m.switch ]
                , div [ class "right" ]
                    [ span [ style "font-size" "60%" ] [ text "価格 " ]
                    , span [ class "switch-price" ] [ text m.price ]
                    , span [ style "font-size" "60%" ] [ text " 円" ]
                    ]
                , p [ class "switch-type" ] [ text (m.switchType ++ "軸 / " ++ m.weight ++ "g") ]
                ]
            , div [ class "switch-detail" ]
                [ viewSwitchAttr m ]
            ]
        ]


viewSwitchImage : KeyMapping -> Html Msg
viewSwitchImage m =
    div [ class "summary-image" ]
        [ img
            [ src
                (if String.isEmpty m.image then
                    urlOfNoImage

                 else
                    m.image
                )
            , class "switch-image"
            ]
            []
        ]


viewSwitchAttr : KeyMapping -> Html Msg
viewSwitchAttr m =
    dl []
        (List.concatMap
            (\( k, v ) ->
                [ dt [] [ text k ]
                , dd [] [ text v ]
                ]
            )
            (filterSortAttr m.attr)
        )


filterSortAttr : Dict String String -> List ( String, String )
filterSortAttr a =
    Dict.toList a
        |> List.filter (\( k, _ ) -> Dict.member k orderOfAttr)
        |> List.sortBy (\( k, _ ) -> Maybe.withDefault 999 (Dict.get k orderOfAttr))


orderOfAttr : Dict String Int
orderOfAttr =
    Dict.fromList
        [ ( "コメント", 1 )
        , ( "タイプ", 2 )
        , ( "ストローク（mm）", 3 )
        , ( "接点までの距離（mm）", 4 )
        , ( "Actuation Force (gf)", 5 )
        , ( "Tactile Force (gf)", 6 )
        , ( "Bottom Out (gf)", 7 )
        ]


viewDefault : Html Msg
viewDefault =
    div [ class "center" ]
        [ img
            [ src urlOfTopImage
            , class "default-image"
            ]
            []
        ]


viewDebugInfo : Model -> Html Msg
viewDebugInfo model =
    div [ class "debug" ]
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
    , image : String
    , switchType : String
    , price : String
    , weight : String
    , comment : String
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

        rowToRecord : List Cell -> KeyMapping
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

                                "5" ->
                                    rowToRecord_ rest { record | image = col.value }

                                "6" ->
                                    rowToRecord_ rest { record | switchType = col.value }

                                "7" ->
                                    rowToRecord_ rest { record | price = col.value }

                                "8" ->
                                    rowToRecord_ rest { record | weight = col.value }

                                "9" ->
                                    rowToRecord_ rest { record | comment = col.value }

                                _ ->
                                    rowToRecord_ rest { record | attr = Dict.insert (Dict.get col.col headers |> Maybe.withDefault "") col.value record.attr }

                        [] ->
                            record
            in
            rowToRecord_ cols (KeyMapping "" "" "" "" "" "" "" Dict.empty 0)
    in
    List.map rowToRecord rows
        |> List.filter (\r -> not (String.isEmpty r.switch))