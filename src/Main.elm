port module Main exposing (..)

import Html exposing (Html, text, div, h1, img, input, button, span)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick, onWithOptions)
import Json.Decode as Json
import Regex
import String exposing (isEmpty)


--- PORTS ---


type alias Event =
    { name : String
    , data : String
    }


port mapEvent : Event -> Cmd msg



---- MODEL ----


type Visibility
    = Hidden
    | Visible


type alias Model =
    { leftUrl : String
    , rightUrl : String
    , leftUrlIsValid : Bool
    , rightUrlIsValid : Bool
    , controlVisibility : Visibility
    , loginVisibility : Visibility
    , modalText : String
    , apiToken : String
    }


init : ( Model, Cmd Msg )
init =
    ( { leftUrl = ""
      , rightUrl = ""
      , leftUrlIsValid = False
      , rightUrlIsValid = False
      , controlVisibility = Visible
      , loginVisibility = Hidden
      , modalText = ""
      , apiToken = ""
      }
    , mapEvent { name = "mapInit", data = "" }
    )



---- UPDATE ----


type Msg
    = NoOp
    | UpdateLeftUrl String
    | UpdateRightUrl String
    | StartLogin
    | FinishLogin
    | CancelLogin
    | UpdateToken String
    | ToggleTopbar
    | ToggleHelpModal


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateLeftUrl url ->
            if (Regex.contains (Regex.regex "(?=.*{z})(?=.*{x})(?=.*{y})") url) then
                ( { model | leftUrl = url, leftUrlIsValid = True }
                , mapEvent { name = "UpdateLeftUrl", data = url }
                )
            else
                ( { model | leftUrl = url, leftUrlIsValid = False }, Cmd.none )

        UpdateRightUrl url ->
            if (Regex.contains (Regex.regex "(?=.*{z})(?=.*{x})(?=.*{y})") url) then
                ( { model | rightUrl = url, rightUrlIsValid = True }
                , mapEvent { name = "UpdateRightUrl", data = url }
                )
            else
                ( { model | rightUrl = url, rightUrlIsValid = False }, Cmd.none )

        StartLogin ->
            ( { model | loginVisibility = Visible }, Cmd.none )

        CancelLogin ->
            ( { model | apiToken = "", loginVisibility = Hidden }, Cmd.none )

        FinishLogin ->
            ( { model | loginVisibility = Hidden }, Cmd.none )

        UpdateToken token ->
            ( { model | apiToken = token }, Cmd.none )

        ToggleTopbar ->
            if (model.controlVisibility == Hidden) then
                ( { model | controlVisibility = Visible }, Cmd.none )
            else
                ( { model | controlVisibility = Hidden }, Cmd.none )

        ToggleHelpModal ->
            if (isEmpty model.modalText) then
                ( { model | modalText = "Layer urls must be of form \"https://tileserver.com/layer/{z}/{x}/{y}.png\"" }, Cmd.none )
            else
                ( { model | modalText = "" }, Cmd.none )



---- VIEW ----


modal : String -> Html Msg
modal displayText =
    div [ class "modal-container" ]
        [ div [ class "modal-header" ]
            [ div [ class "modal-text" ] [ text "Help" ]
            , button [ class "close-button" ] [ text "X" ]
            ]
        , div [ class "modal-body" ]
            [ text displayText ]
        ]


urlInput : String -> String -> Bool -> (String -> Msg) -> Html Msg
urlInput valueText placeholderText isValid inputMsg =
    div
        [ classList [ ( "url-input", True ) ]
        ]
        [ input
            [ classList
                [ ( "input-control", True )
                , ( "form-invalid", not isValid )
                ]
            , type_ "text"
            , placeholder placeholderText
            , onInput inputMsg
            , value valueText
            ]
            []
        , button [ class "help-button" ]
            [ text "?"
            ]
        ]


navbar : Model -> Html Msg
navbar model =
    div
        [ classList
            [ ( "layer-controls", True )
            , ( "controls-hidden", model.controlVisibility == Hidden )
            ]
        ]
        [ urlInput model.leftUrl "Layer URL for left pane" model.leftUrlIsValid UpdateLeftUrl
        , urlInput model.rightUrl "Layer URL for Right pane" model.rightUrlIsValid UpdateRightUrl
        , button
            [ class "login-button"
            , type_ "button"
            , onWithOptions
                "click"
                { stopPropagation = True, preventDefault = True }
                (Json.succeed StartLogin)
            ]
            [ 
                text (if (isEmpty model.apiToken) then "Set Raster Foundry Token" else "Change Token")
            ]
        , button
            [ classList
                [ ( "collapse-button", model.controlVisibility == Visible )
                , ( "expand-button", model.controlVisibility == Hidden )
                ]
            , onWithOptions
                "click"
                { stopPropagation = True, preventDefault = True }
                (Json.succeed ToggleTopbar)
            ]
            [ text
                (if model.controlVisibility == Hidden then
                    "Show urls"
                 else
                    "Hide urls"
                )
            ]
        ]


login : Model -> Html Msg
login model =
    div [ class "login-form" ]
        [ input
            [ class "input-control"
            , type_ "text"
            , value model.apiToken
            , onInput UpdateToken
            , placeholder "Rasterfoundry API Token"
            ]
            []
        , button
            [ class "login-button"
            , type_ "button"
            , onWithOptions "click" {
                stopPropagation = True, preventDefault = True
            }
            (Json.succeed FinishLogin)
            ]
            [ text "Save Token" ]
        , button
            [ class "login-button"
            , type_ "button"
            , onWithOptions "click"
                { stopPropagation = True, preventDefault = True }
                (Json.succeed CancelLogin)
            ]
            [ text "Clear Token" ]
        ]


mapcontainer : Model -> Html Msg
mapcontainer model =
    div [ class "map-container" ]
        [ div [ id "before", class "map" ] []
        , div [ id "after", class "map" ] []
        ]


root : Model -> Html Msg
root model =
    div
        [ class "app-content"
        ]
        [ if (model.loginVisibility == Hidden) then
            navbar model
          else
            login model
        , mapcontainer model
        , if (not (isEmpty model.modalText)) then
            modal model.modalText
          else
            text ""
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = root
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
