module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Events exposing (onKeyDown)
import Debug
import Dict exposing (Dict)
import Dict.Extra
import Html exposing (Html, a, button, dd, div, dl, dt, h2, h3, img, p, span, text)
import Html.Attributes exposing (class, href, src, style)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, at, field, int, list, map3, string)
import Time


clearInterval =
    60


urlOfSwitchesSpreadsheetJson =
    "https://spreadsheets.google.com/feeds/cells/1A_mEUzMwjNt5UK6hjdayapnyjIsgKGGZ1gfeAW_7E6s/od6/public/values?alt=json"


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { switchCount : Int
    , switchCategory : Maybe String
    , switchName : Maybe String
    , clearCount : Int
    , switchAttrs : Dict String SwitchAttr
    , categories : Dict String (List String)
    }


initialModel =
    { switchCount = 0
    , switchCategory = Nothing
    , switchName = Nothing
    , clearCount = clearInterval
    , switchAttrs = Dict.empty
    , categories = Dict.empty
    }


resetModel : Model -> Model
resetModel model =
    { initialModel | switchAttrs = model.switchAttrs, categories = model.categories }


type alias SwitchAttr =
    { name : String, weight : Float, color : String }


weightOf : String -> Dict String SwitchAttr -> Float
weightOf switch attrs =
    Dict.get switch attrs
        |> Maybe.map .weight
        |> Maybe.withDefault 0


colorOf : String -> Dict String SwitchAttr -> String
colorOf switch attrs =
    Dict.get switch attrs
        |> Maybe.map .color
        |> Maybe.withDefault "#000000"


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel
    , Http.get
        { url = urlOfSwitchesSpreadsheetJson
        , expect = Http.expectJson GotResponse switchJsonDecoder
        }
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | SelectCategory String
    | SelectSwitch String
    | ResetCount
    | AddCount Int
    | Reset
    | GotResponse (Result Http.Error (List Cell))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick _ ->
            if model.clearCount >= clearInterval then
                ( resetModel model, Cmd.none )

            else
                ( { model | clearCount = model.clearCount + 1 }, Cmd.none )

        SelectCategory category ->
            ( { model | clearCount = 0, switchCategory = Just category }, Cmd.none )

        SelectSwitch switch ->
            ( { model | clearCount = 0, switchName = Just switch, switchCount = 0 }, Cmd.none )

        ResetCount ->
            ( { model | clearCount = 0, switchCount = 0 }, Cmd.none )

        AddCount count ->
            ( { model | clearCount = 0, switchCount = model.switchCount + count }, Cmd.none )

        Reset ->
            ( resetModel model, Cmd.none )

        GotResponse result ->
            case result of
                Ok cells ->
                    case buildSwitchData cells of
                        ( c, a ) ->
                            ( { model | switchAttrs = a, categories = c }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every 1000 Tick ]



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ if Dict.isEmpty model.switchAttrs then
            viewLoading

          else
            case model.switchName of
                Just switch ->
                    viewWeightCalculator
                        switch
                        (weightOf switch model.switchAttrs)
                        model.switchCount

                Nothing ->
                    case model.switchCategory of
                        Nothing ->
                            viewCategories model.categories

                        Just category ->
                            viewSwitches
                                (List.filterMap
                                    (\sw -> Dict.get sw model.switchAttrs)
                                    (Maybe.withDefault [] (Dict.get category model.categories))
                                )
        , button [ class "button", class "reset", onClick Reset ] [ text "はじめにもどる" ]

        -- , p [] [ text (Debug.toString model) ]
        ]


viewLoading =
    p [] [ text "Loading..." ]


viewWeightCalculator : String -> Float -> Int -> Html Msg
viewWeightCalculator switch weight count =
    div []
        [ h2 [] [ text switch ]
        , p [ class "switch-price" ] [ text (String.fromInt count ++ "個") ]
        , p []
            [ text (String.fromFloat weight ++ "g/個") ]
        , div []
            [ countButton 30
            , countButton 40
            , countButton 50
            , countButton 60
            , countButton 70
            , countButton 80
            , countButton 90
            ]
        , div []
            [ countButton 1
            , countButton 2
            , countButton 3
            , countButton 4
            , countButton 5
            , countButton 6
            , countButton 7
            , countButton 8
            , countButton 9
            ]
        , button [ class "button", class "reset", onClick ResetCount ] [ text "個数クリア" ]
        , p [ class "switch-price" ] [ text (String.fromFloat (toFloat count * weight) ++ "g") ]
        ]


viewCategories : Dict String (List String) -> Html Msg
viewCategories categories =
    div [ class "center" ]
        [ h2 [] [ text "スイッチの種類をえらんでね" ]
        , div []
            (List.map
                categoryButton
                (Dict.keys categories)
            )
        ]


viewSwitches : List SwitchAttr -> Html Msg
viewSwitches switches =
    div [ class "center" ]
        [ h2 []
            [ text "スイッチをえらんでね" ]
        , div
            []
            (List.map
                switchButton
                switches
            )
        ]


categoryButton : String -> Html Msg
categoryButton category =
    a [ href "#", class "button", onClick (SelectCategory category) ] [ text category ]


switchButton : SwitchAttr -> Html Msg
switchButton switch =
    a
        [ href "#"
        , class "button"
        , style "border-bottom-color" switch.color
        , style "border-bottom-width" "10px"
        , onClick (SelectSwitch switch.name)
        ]
        [ text switch.name ]


countButton : Int -> Html Msg
countButton count =
    a [ href "#", class "count-button", onClick (AddCount count) ] [ text (String.fromInt count) ]



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


buildSwitchData : List Cell -> ( Dict String (List String), Dict String SwitchAttr )
buildSwitchData cells =
    let
        grouped =
            Dict.Extra.groupBy .row cells

        rows =
            Dict.values grouped

        reducer cols acc =
            case List.map .value cols of
                [ category, switchName, weight, color ] ->
                    case acc of
                        ( categories, attrs ) ->
                            let
                                newAttrs =
                                    Dict.insert
                                        switchName
                                        (SwitchAttr
                                            switchName
                                            (Maybe.withDefault 0 (String.toFloat weight))
                                            color
                                        )
                                        attrs

                                newCategories =
                                    if Dict.member category categories then
                                        let
                                            oldSwitches =
                                                Maybe.withDefault [] (Dict.get category categories)

                                            newSwitches =
                                                switchName :: oldSwitches
                                        in
                                        Dict.insert category newSwitches categories

                                    else
                                        Dict.insert category [ switchName ] categories
                            in
                            ( newCategories, newAttrs )

                _ ->
                    ( Dict.empty, Dict.empty )
    in
    List.foldl reducer ( Dict.empty, Dict.empty ) rows
