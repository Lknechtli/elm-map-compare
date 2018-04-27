module Main exposing (..)

import Html exposing (Html, text, div, h1, img, input, button)
import Html.Attributes exposing (src, class, classList, placeholder, type_, value)
import Html.Events exposing (onInput, onClick)


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
    , Cmd.none
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateLeftUrl url ->
            ( { model | leftUrl = url }, Cmd.none )

        UpdateRightUrl url ->
            ( { model | rightUrl = url }, Cmd.none )

        StartLogin ->
            ( { model | loginVisibility = Visible }, Cmd.none )

        UpdateUsername username ->
            ( { model | username = username }, Cmd.none )

        UpdatePassword password ->
            ( { model | password = password }, Cmd.none )

        SubmitLogin loginPayload ->
            ( { model | username = "", password = "" }, Cmd.none )



---- VIEW ----


navbar : Model -> Html Msg
navbar model =
    div
        [ classList
            [ ( "layer-controls", True )
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
            ]
            [ text "Use Raster Foundry credentials" ]
        , button
            [ classList
                [ ( "collapse-button", True )
                , ( "expand-button", False )
                ]
            ]
            [ text
                (if model.controlVisibility == Hidden then
                    "Expand"
                 else
                    "Hide"
                )
            ]
        ]


mapcontainer : Model -> Html Msg
mapcontainer model =
    div [ class "map-container" ] [ text "Map goes here" ]


root : Model -> Html Msg
root model =
    div
        [ class "app-content"
        ]
        [ navbar model
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
