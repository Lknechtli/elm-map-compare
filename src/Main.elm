module Main exposing (..)

import Html exposing (Html, text, div, h1, img, input, button)
import Html.Attributes exposing (src, class, classList, placeholder)


---- MODEL ----


type alias Model =
    { leftUrl : String
    , rightUrl : String
    }


init : ( Model, Cmd Msg )
init =
    ( { leftUrl = "", rightUrl = "" }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | UpdateLeftUrl
    | UpdateRightUrl
    | StartLogin
    | UpdateUsername
    | UpdatePassword
    | SubmitLogin
    | CancelLogin


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



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
            , placeholder "Layer URL for left pane"
            ]
            []
        , input
            [ class "url-control"
            , placeholder "Layer URL for right pane"
            ]
            []
        , button [ class "login-button" ] [ text "Use Raster Foundry credentials" ]
        , button
            [ classList
                [ ( "collapse-button", True )
                , ( "expand-button", False )
                ]
            ]
            []
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
