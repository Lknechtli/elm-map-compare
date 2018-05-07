port module Main exposing (..)

import Html exposing (Html, text, div, h1, img, input, button, span)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick, onWithOptions)
import Json.Decode as Json
import Regex


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


type alias LoginPayload =
    { username : String
    , password : String
    }


type alias Model =
    { leftUrl : String
    , rightUrl : String
    , leftUrlIsValid : Bool
    , rightUrlIsValid : Bool
    , controlVisibility : Visibility
    , loginVisibility : Visibility
    , username : String
    , password : String
    }


init : ( Model, Cmd Msg )
init =
    ( { leftUrl = ""
      , rightUrl = ""
      , leftUrlIsValid = False
      , rightUrlIsValid = False
      , controlVisibility = Visible
      , loginVisibility = Hidden
      , username = ""
      , password = ""
      }
    , mapEvent { name = "mapInit", data = "" }
    )



---- UPDATE ----


type Msg
    = NoOp
    | UpdateLeftUrl String
    | UpdateRightUrl String
    | StartLogin
    | CancelLogin
    | UpdateUsername String
    | UpdatePassword String
    | SubmitLogin LoginPayload
    | ToggleTopbar


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
            ( { model | loginVisibility = Hidden }, Cmd.none )

        UpdateUsername username ->
            ( { model | username = username }, Cmd.none )

        UpdatePassword password ->
            ( { model | password = password }, Cmd.none )

        SubmitLogin loginPayload ->
            ( { model | username = "", password = "" }, Cmd.none )

        ToggleTopbar ->
            if (model.controlVisibility == Hidden) then
                ( { model | controlVisibility = Visible }, Cmd.none )
            else
                ( { model | controlVisibility = Hidden }, Cmd.none )



---- VIEW ----


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
        , span [ class "help-tag" ] [ text "?" ]
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

        -- input
        --    [ classList
        --        [ ( "input-control", True )
        --        , ( "form-invalid", not model.leftUrlIsValid )
        --        ]
        --    , type_ "text"
        --    , placeholder "Layer URL for left pane"
        --    , onInput UpdateLeftUrl
        --    , value model.leftUrl
        --    ]
        --    []
        -- , input
        --     [ classList
        --         [ ( "input-control", True )
        --         , ( "form-invalid", not model.rightUrlIsValid )
        --         ]
        --     , type_ "text"
        --     , placeholder "Layer URL for right pane"
        --     , onInput UpdateRightUrl
        --     , value model.rightUrl
        --     ]
        --     []
        , button
            [ class "login-button"
            , type_ "button"
            , onWithOptions
                "click"
                { stopPropagation = True, preventDefault = True }
                (Json.succeed StartLogin)
            ]
            [ text "Use Raster Foundry credentials" ]
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
            , value model.username
            , onInput UpdateUsername
            , placeholder "Username"
            ]
            []
        , input
            [ class "input-control"
            , type_ "password"
            , value model.username
            , onInput UpdatePassword
            , placeholder "Password"
            ]
            []
        , button
            [ class "login-button"
            , type_ "button"
            ]
            [ text "Log In" ]
        , button
            [ class "login-button"
            , type_ "button"
            , onWithOptions "click"
                { stopPropagation = True, preventDefault = True }
                (Json.succeed CancelLogin)
            ]
            [ text "Cancel" ]
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
