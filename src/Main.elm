module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Events exposing (onKeyDown)
import Debug
import Dict exposing (Dict)
import Dict.Extra
import Html exposing (Html, button, dd, div, dl, dt, h2, h3, img, p, span, text)
import Html.Attributes exposing (class, src, style)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, at, field, int, list, map3, string)
import Time


claerInterval =
    20


urlOfSwitchesSpreadsheetJson =
    "https://spreadsheets.google.com/feeds/cells/1G0grm4xDFYO-9X4sWX7A8I2V7ag2H9fG2zTa2dnkgow/od6/public/values?alt=json"


urlOfStocksSpreadsheetJson =
    "https://spreadsheets.google.com/feeds/cells/11aofIJxgDEI8NQXJBGAcBaFGkG5W-U5dhRkxPalG8uM/od6/public/values?alt=json"


urlOfTopImage =
    "https://www.dropbox.com/s/w9z5j7yh3h4rtzr/tester_top.png?raw=1"


urlOfNoImage =
    "https://www.dropbox.com/s/tipissf3lgqtom6/no_image.png?raw=1"


urlOfNeji =
    "https://www.dropbox.com/s/ynqfdvv2a1bikft/neji.jpg?raw=1"


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
    , history : List String
    , help : Maybe Help
    , keyMappings : List KeyMapping
    , stockDescriptions : List StockDescription
    }


type Status
    = Initial
    | Loading
    | Tester


type Help
    = SwitchPins


init : () -> ( Model, Cmd Msg )
init _ =
    ( { count = 0
      , key = ""
      , modifier = ""
      , status = Loading
      , hitCount = 0
      , history = []
      , help = Nothing
      , keyMappings = []
      , stockDescriptions = []
      }
    , reloadSheetCmd
    )


reloadSheetCmd : Cmd Msg
reloadSheetCmd =
    Cmd.batch
        [ Http.get
            { url = urlOfSwitchesSpreadsheetJson
            , expect = Http.expectJson GotSwitchResponse sheetJsonDecoder
            }
        , Http.get
            { url = urlOfStocksSpreadsheetJson
            , expect = Http.expectJson GotStockResponse sheetJsonDecoder
            }
        ]



-- UPDATE


type Msg
    = Tick Time.Posix
    | Input Key
    | GotSwitchResponse (Result Http.Error (List Cell))
    | GotStockResponse (Result Http.Error (List Cell))
    | ShowHelp Help
    | HideHelp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSwitchResponse result ->
            case result of
                Ok cells ->
                    if List.isEmpty model.stockDescriptions then
                        ( { model | status = Loading, keyMappings = toKeyMappings cells }, Cmd.none )

                    else
                        ( { model | status = Tester, keyMappings = toKeyMappings cells }, Cmd.none )

                -- ( { model | modifier = Debug.toString (toKeyMappings cells) }, Cmd.none )
                Err _ ->
                    ( { model | modifier = "error" }, Cmd.none )

        GotStockResponse result ->
            case result of
                Ok cells ->
                    if List.isEmpty model.keyMappings then
                        ( { model | status = Loading, stockDescriptions = toStockDescriptions cells }, Cmd.none )

                    else
                        ( { model | status = Tester, stockDescriptions = toStockDescriptions cells }, Cmd.none )

                Err _ ->
                    ( { model | modifier = "error" }, Cmd.none )

        Tick _ ->
            if model.count >= claerInterval then
                ( { model | count = 0, key = "", modifier = "", history = [], help = Nothing }, reloadSheetCmd )

            else
                ( { model | count = model.count + 1 }, Cmd.none )

        Input (Character c) ->
            if model.key == String.fromChar c then
                ( { model | count = 0, hitCount = model.hitCount + 1, help = Nothing }, Cmd.none )

            else
                ( { model | count = 0, key = String.fromChar c, hitCount = 1, history = String.fromChar c :: model.history, help = Nothing }, Cmd.none )

        Input (Control s) ->
            ( { model | modifier = s }, Cmd.none )

        ShowHelp help ->
            ( { model | help = Just help }, Cmd.none )

        HideHelp ->
            ( { model | help = Nothing }, Cmd.none )



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
        [ if isNeji model.history then
            viewNeji

          else
            viewSwitchOrDefault model
        , viewDebugInfo model
        , viewHelp model.help
        ]


viewSwitchOrDefault : Model -> Html Msg
viewSwitchOrDefault model =
    case switchOf model of
        Nothing ->
            viewDefault

        Just ( keyMapping, stockDescription ) ->
            viewSwitch keyMapping stockDescription


viewSwitch : KeyMapping -> StockDescription -> Html Msg
viewSwitch m s =
    div []
        [ div [ class "summary" ]
            [ viewSwitchImage m
            , div [ class "summary-info" ]
                [ p [ class "switch-comment" ] [ text m.comment ]
                , p [ class "switch-name" ] [ text m.switch ]
                , div [ class "right" ]
                    [ span [ class "switch-price", style "font-size" "100%" ] [ text s.stockDescription ]
                    ]
                , div [ class "right" ]
                    [ span [ style "font-size" "60%" ] [ text "価格 " ]
                    , span [ class "switch-price" ] [ text m.price ]
                    , span [ style "font-size" "60%" ] [ text " 円" ]
                    ]
                , p [ class "switch-type" ]
                    [ text (m.switchType ++ "軸 / " ++ m.weight ++ "g") ]
                , p [ class "switch-type" ]
                    [ text ("ピン数: " ++ m.pin)
                    , viewHelpButton SwitchPins
                    ]
                ]
            , div [ class "switch-detail" ]
                [ viewSwitchAttr m ]
            ]
        ]


viewHelpButton : Help -> Html Msg
viewHelpButton help =
    img [ src "question.svg", class "help-icon", onClick (ShowHelp help) ] []


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


viewNeji : Html Msg
viewNeji =
    div [ class "center" ]
        [ img
            [ src urlOfNeji
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
        , div [] [ text (String.join "" model.history) ]
        ]


switchOf : Model -> Maybe ( KeyMapping, StockDescription )
switchOf model =
    case model.status of
        Tester ->
            List.head (List.filter (\k -> k.key == model.key) model.keyMappings)
                |> Maybe.andThen
                    (\m ->
                        List.head (List.filter (\s -> s.name == m.switch) model.stockDescriptions)
                            |> Maybe.map (\s -> ( m, s ))
                    )

        _ ->
            Nothing


isNeji : List String -> Bool
isNeji history =
    let
        last4 =
            List.take 4 history
                |> List.reverse
                |> String.join ""
                |> String.toLower
    in
    last4 == "neji"


viewHelp : Maybe Help -> Html Msg
viewHelp help =
    case help of
        Nothing ->
            text ""

        Just someHelp ->
            div []
                [ div [ class "modal" ] [ helpContentsOf someHelp ]
                , div [ class "overlay", onClick HideHelp ] []
                ]


helpContentsOf : Help -> Html Msg
helpContentsOf help =
    case help of
        SwitchPins ->
            div []
                [ img
                    [ class "help-image"
                    , src "https://yushakobo.jp/wp-content/uploads/2019/08/3pin5pin_.jpg"
                    ]
                    []
                ]



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



-- SpreadSheet JSON DECODER


sheetJsonDecoder : Decoder (List Cell)
sheetJsonDecoder =
    at [ "feed", "entry" ] (list entryDecoder)


entryDecoder : Decoder Cell
entryDecoder =
    map3 Cell
        (at [ "gs$cell", "row" ] string)
        (at [ "gs$cell", "col" ] string)
        (at [ "gs$cell", "$t" ] string)


type alias Cell =
    { row : String, col : String, value : String }



-- Switch JSON DECODER


type alias KeyMapping =
    { key : String
    , switch : String
    , image : String
    , switchType : String
    , price : String
    , weight : String
    , comment : String
    , pin : String
    , stock : String
    , attr : Dict String String
    , row : Int
    }


defaultKeyMapping =
    { key = ""
    , switch = ""
    , image = ""
    , switchType = ""
    , price = ""
    , weight = ""
    , comment = ""
    , pin = ""
    , stock = ""
    , attr = Dict.empty
    , row = 0
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

                                "10" ->
                                    rowToRecord_ rest { record | pin = col.value }

                                "11" ->
                                    rowToRecord_ rest { record | stock = col.value }

                                _ ->
                                    rowToRecord_ rest { record | attr = Dict.insert (Dict.get col.col headers |> Maybe.withDefault "") col.value record.attr }

                        [] ->
                            record
            in
            rowToRecord_ cols defaultKeyMapping
    in
    List.map rowToRecord rows
        |> List.filter (\r -> not (String.isEmpty r.switch))



-- Stock JSON DECODER


type alias StockDescription =
    { name : String
    , stockDescription : String
    }


defaultStockDescription =
    { name = ""
    , stockDescription = ""
    }


toStockDescriptions : List Cell -> List StockDescription
toStockDescriptions cells =
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

        rowToRecord : List Cell -> StockDescription
        rowToRecord cols =
            let
                rowToRecord_ cols_ record =
                    case cols_ of
                        col :: rest ->
                            case col.col of
                                "1" ->
                                    rowToRecord_ rest { record | name = col.value }

                                "2" ->
                                    rowToRecord_ rest record

                                "3" ->
                                    rowToRecord_ rest record

                                "4" ->
                                    rowToRecord_ rest { record | stockDescription = col.value }

                                _ ->
                                    rowToRecord_ rest record

                        [] ->
                            record
            in
            rowToRecord_ cols defaultStockDescription
    in
    List.map rowToRecord rows
        |> List.filter (\r -> not (String.isEmpty r.name))
