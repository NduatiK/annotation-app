-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module Tool exposing (..)

import Annotation exposing (Annotations, DragState, PointerMsg, Position)
import Element exposing (Element)
import Element.Attributes exposing (vary)
import Html.Lazy exposing (lazy2)
import Packages.Zipper as Zipper exposing (Zipper)
import StyleSheet as Style exposing (Style)
import View.Icons as Icons


type alias Data =
    { id : Int
    , tool : Tool
    , colorId : Int
    }


type Tool
    = Move
    | Annotation Annotations


fromAnnotationType : Annotation.Type -> Tool
fromAnnotationType annotationType =
    case annotationType of
        Annotation.PointType ->
            Annotation (Annotation.Point [])

        Annotation.BBoxType ->
            Annotation (Annotation.BBox [])

        Annotation.StrokeType ->
            Annotation (Annotation.Stroke [])

        Annotation.OutlineType ->
            Annotation (Annotation.Outline [])

        Annotation.PolygonType ->
            Annotation (Annotation.Polygon [])


fromConfig : Annotation.Config -> Zipper Data
fromConfig config =
    let
        moveData : Data
        moveData =
            { id = 0
            , tool = Move
            , colorId = 0
            }

        zipperWithOnlyMove : Zipper Data
        zipperWithOnlyMove =
            Zipper.init [] moveData []

        addKind : Annotation.Kind -> Zipper Data -> Zipper Data
        addKind kind zipper =
            case kind.variants of
                [] ->
                    addVariants 0 kind.annotationType [] zipper

                _ :: vs ->
                    addVariants 1 kind.annotationType vs zipper

        addVariants : Int -> Annotation.Type -> List a -> Zipper Data -> Zipper Data
        addVariants id annotationType otherVariants zipper =
            let
                currentId =
                    .id (Zipper.getC zipper)

                variantData =
                    { id = 1 + .id (Zipper.getC zipper)
                    , tool = fromAnnotationType annotationType
                    , colorId = id
                    }

                newZipper =
                    zipper
                        |> Zipper.insertR variantData
                        |> Zipper.goR
            in
            case otherVariants of
                [] ->
                    newZipper

                v :: vs ->
                    addVariants (id + 1) annotationType vs newZipper
    in
    List.foldl addKind zipperWithOnlyMove config.kinds
        |> Zipper.goStart


svgElement : Float -> Data -> Element Style Style.ColorVariations msg
svgElement size toolData =
    let
        svgIcon =
            case toolData.tool of
                Move ->
                    Icons.move

                Annotation (Annotation.Point _) ->
                    Icons.point

                Annotation (Annotation.BBox _) ->
                    Icons.boundingBox

                Annotation (Annotation.Stroke _) ->
                    Icons.stroke

                Annotation (Annotation.Outline _) ->
                    Icons.outline

                Annotation (Annotation.Polygon _) ->
                    Icons.polygon
    in
    lazy2 Icons.sized size svgIcon
        |> Element.html
        |> Element.el Style.ToolIcon [ vary (Style.FromPalette toolData.colorId) True ]



-- Update


removeLatestAnnotation : Tool -> Tool
removeLatestAnnotation tool =
    case tool of
        Move ->
            Move

        Annotation annotations ->
            Annotation (Annotation.removeLast annotations)


updateData : Int -> (Position -> Position) -> PointerMsg -> DragState -> Data -> ( Data, DragState )
updateData classId scaling pointerMsg dragState data =
    case data.tool of
        Annotation (Annotation.Point drawings) ->
            let
                ( newDrawings, newDragState ) =
                    Annotation.updatePoints scaling pointerMsg dragState drawings
            in
            ( { data | tool = Annotation (Annotation.Point newDrawings) }
            , newDragState
            )

        Annotation (Annotation.BBox drawings) ->
            let
                ( newDrawings, newDragState ) =
                    Annotation.updateBBox classId scaling pointerMsg dragState drawings
            in
            ( { data | tool = Annotation (Annotation.BBox newDrawings) }
            , newDragState
            )

        _ ->
            -- Debug.crash "TODO"
            ( data, dragState )
