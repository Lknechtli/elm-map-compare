port module Main exposing (..)

import Html exposing (Html, text, div, h1, img, input, button)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick, onWithOptions)
import Json.Decode as Json


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
    , controlVisibility : Visibility
    , loginVisibility : Visibility
    , username : String
    , password : String
    }


init : ( Model, Cmd Msg )
init =
    ( { leftUrl = ""
      , rightUrl = ""
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
            ( { model | leftUrl = url }, mapEvent { name = "UpdateLeftUrl", data = url } )

        UpdateRightUrl url ->
            ( { model | rightUrl = url }, mapEvent { name = "UpdateRightUrl", data = url } )

        StartLogin ->
            ( { model | loginVisibility = Visible }, Cmd.none )

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


navbar : Model -> Html Msg
navbar model =
    div
        [ classList
            [ ( "layer-controls", True )
            , ( "controls-hidden", model.controlVisibility == Hidden )
            ]
        ]
        [ input
            [ class "url-control"
            , type_ "text"
            , placeholder "Layer URL for left pane"
            , onInput UpdateLeftUrl
            , value model.leftUrl
            ]
            []
        , input
            [ class "url-control"
            , type_ "text"
            , placeholder "Layer URL for right pane"
            , onInput UpdateRightUrl
            , value model.rightUrl
            ]
            []
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
                    "vvv"
                 else
                    "^^^"
                )
            ]
        ]


login : Model -> Html Msg
login model =
    div [ class "login-form" ]
        [ input
            [ class "login-input"
            , type_ "text"
            , value model.username
            , onInput UpdateUsername
            ]
            []
        , input
            [ class "login-input"
            , type_ "password"
            , value model.username
            , onInput UpdatePassword
            ]
            []
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
