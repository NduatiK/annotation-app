-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


port module Main exposing (..)

import Annotation.Geometry.BoundingBox as BBox
import Annotation.Geometry.Point as Point
import Annotation.Viewer as Viewer
import Device exposing (Device)
import Html exposing (Html)
import Tool exposing (Tool)
import Types exposing (DragState(..), Model, Msg(..), PointerMsg(..), Position)
import View


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


init : Device.Size -> ( Model, Cmd Msg )
init sizeFlag =
    ( Types.init sizeFlag, Cmd.none )



-- UPDATE ############################################################


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        WindowResizesMsg size ->
            let
                device =
                    Device.classify size

                layout =
                    Types.pageLayout device

                viewer =
                    Viewer.setSize layout.viewerSize model.viewer
            in
            ( { model | device = device, layout = layout, viewer = viewer }
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

        PointerMsg pointerMsg ->
            ( updateWithPointer pointerMsg model, Cmd.none )


updateWithPointer : PointerMsg -> Model -> Model
updateWithPointer pointerMsg model =
    case ( pointerMsg, model.tool, model.dragState ) of
        ( PointerDownAt pos, Tool.BBox, _ ) ->
            { model | dragState = DraggingFrom pos, bbox = Nothing }

        ( PointerMoveAt pos, Tool.BBox, DraggingFrom startPos ) ->
            let
                ( startPoint, point ) =
                    ( Point.fromCoordinates startPos
                    , Point.fromCoordinates pos
                    )
            in
            { model | bbox = Just (BBox.fromPair ( startPoint, point )) }

        ( PointerUpAt _, Tool.BBox, _ ) ->
            { model | dragState = NoDrag }

        _ ->
            model


subscriptions : Model -> Sub Msg
subscriptions model =
    resizes WindowResizesMsg



-- VIEW ##############################################################


view : Model -> Html Msg
view =
    View.view
