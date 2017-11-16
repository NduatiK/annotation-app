-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


port module Main exposing (..)

import Button exposing (Button)
import Device exposing (Device)
import Element exposing (Element, below, el, empty, span)
import Element.Attributes as Attributes exposing (Length, alignRight, center, fill, px, verticalCenter)
import Html exposing (Html)
import Icons
import Pointer
import StyleSheet as Style exposing (Style)
import Svg exposing (Svg)
import Tool exposing (Tool)


main : Program Device.Size Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL #############################################################


port resizes : (Device.Size -> msg) -> Sub msg


type alias Model =
    { device : Device
    , tool : Tool
    , toolDropdownOpen : Bool
    , currentDropdownTool : Tool
    }


init : Device.Size -> ( Model, Cmd Msg )
init sizeFlag =
    ( Model (Device.classify sizeFlag) Tool.Move False Tool.Contour, Cmd.none )



-- UPDATE ############################################################


type Msg
    = NoOp
    | WindowResizesMsg Device.Size
    | SelectTool Tool
    | ToggleToolDropdown


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        WindowResizesMsg size ->
            ( { model | device = Device.classify size }
            , Cmd.none
            )

        SelectTool tool ->
            ( { model
                | tool = tool
                , toolDropdownOpen = False
                , currentDropdownTool =
                    if tool /= Tool.Move then
                        tool
                    else
                        model.currentDropdownTool
              }
            , Cmd.none
            )

        ToggleToolDropdown ->
            ( { model | toolDropdownOpen = not model.toolDropdownOpen }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    resizes WindowResizesMsg



-- VIEW ##############################################################


view : Model -> Html Msg
view model =
    responsiveLayout model
        |> Element.layout Style.sheet


responsiveLayout : Model -> Element Style variation Msg
responsiveLayout model =
    case ( model.device.kind, model.device.orientation ) of
        ( Device.Phone, _ ) ->
            let
                ( actionBarWidth, actionBarHeight ) =
                    ( model.device.size.width |> toFloat
                    , deviceActionBarHeight model.device |> toFloat
                    )

                ( viewerWidth, viewerHeight ) =
                    ( model.device.size.width |> toFloat
                    , max 0 (toFloat model.device.size.height - actionBarHeight)
                    )

                actionBar =
                    phoneActionBar model.device.orientation model.tool model.currentDropdownTool model.toolDropdownOpen ( actionBarWidth, actionBarHeight )
            in
            Element.column Style.None
                [ Attributes.height fill ]
                [ actionBar
                , imageViewer ( viewerWidth, viewerHeight )
                ]

        _ ->
            Element.text "TODO"


deviceActionBarHeight : Device -> Int
deviceActionBarHeight device =
    case ( device.kind, device.orientation ) of
        ( Device.Phone, Device.Portrait ) ->
            device.size.width // 7

        ( Device.Phone, Device.Landscape ) ->
            device.size.width // 13

        _ ->
            device.size.width // 7


phoneActionBar : Device.Orientation -> Tool -> Tool -> Bool -> ( Float, Float ) -> Element Style variation Msg
phoneActionBar orientation currentTool currentDropdownTool toolDropdownOpen ( width, height ) =
    let
        filler =
            el Style.None [ Attributes.width fill, Attributes.height (px height) ] empty

        mainActions =
            [ toolButton height currentTool Tool.Move
            , toolDropdown height currentTool currentDropdownTool toolDropdownOpen
            , actionButton height True ToggleToolDropdown Icons.moreVertical
            , filler
            , actionButton height False NoOp Icons.rotateCcw
            , actionButton height True NoOp Icons.trash2
            , actionButton height True NoOp Icons.image
            ]

        zoomActions =
            [ filler
            , actionButton height True NoOp Icons.zoomIn
            , actionButton height True NoOp Icons.zoomOut
            , actionButton height True NoOp Icons.maximize2
            ]
    in
    case orientation of
        Device.Portrait ->
            Element.row Style.None [] mainActions
                |> below [ Element.row Style.None [] zoomActions ]

        Device.Landscape ->
            Element.row Style.None [] (mainActions ++ zoomActions)


actionButton : Float -> Bool -> Msg -> List (Svg Msg) -> Element Style v Msg
actionButton size clickable sendMsg innerSvg =
    Button.view
        { actionability =
            if clickable then
                Button.Abled Button.Inactive
            else
                Button.Disabled
        , action = Pointer.onDown (always sendMsg) |> Attributes.toAttr
        , innerElement = Element.html (Icons.sized (0.6 * size) innerSvg)
        , innerStyle = Style.None
        , size = ( size, size )
        , outerStyle = Style.Button (not clickable)
        , otherAttributes = [ Attributes.attribute "elm-pep" "true" ]
        }


toolDropdown : Float -> Tool -> Tool -> Bool -> Element Style variation Msg
toolDropdown size currentTool currentDropdownTool toolDropdownOpen =
    let
        downTools =
            Tool.allAnnotationTools
                |> List.filter ((/=) currentDropdownTool)
                |> List.map (toolButton size currentTool)
                |> Element.column Style.None []
                |> List.singleton
    in
    el Style.None [] (toolButton size currentTool currentDropdownTool)
        |> below
            (if toolDropdownOpen then
                downTools
             else
                []
            )


toolButton : Float -> Tool -> Tool -> Element Style variation Msg
toolButton size currentTool tool =
    Button.view
        { actionability =
            Button.Abled
                (if tool == currentTool then
                    Button.Active
                 else
                    Button.Inactive
                )
        , action = Pointer.onDown (always <| SelectTool tool) |> Attributes.toAttr
        , innerElement = Tool.svgElement (0.6 * size) tool
        , innerStyle = Style.None
        , size = ( size, size )
        , outerStyle =
            if tool == currentTool then
                Style.CurrentTool
            else
                Style.Button False
        , otherAttributes = [ Attributes.attribute "elm-pep" "true" ]
        }


imageViewer : ( Float, Float ) -> Element Style variation msg
imageViewer ( width, height ) =
    el Style.None [ Attributes.height fill ] empty
