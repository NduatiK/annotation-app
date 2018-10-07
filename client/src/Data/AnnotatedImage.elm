-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module Data.AnnotatedImage exposing
    ( AnnotatedImage
    , Status(..)
    , encode
    , fromRemote
    , hasAnnotations
    , removeAnnotation
    , reset
    , updateWithPointer
    )

import Data.Annotation as Annotation exposing (Annotation)
import Data.Image as Image exposing (Image)
import Data.Pointer as Pointer
import Data.RemoteImage as RemoteImage exposing (RemoteImage)
import Data.Tool as Tool exposing (Tool)
import Json.Encode as Encode exposing (Value)
import Packages.Zipper as Zipper exposing (Zipper(..))



-- TYPES #############################################################


type alias AnnotatedImage =
    { name : String
    , status : Status
    }


type Status
    = Loading
    | Loaded Image
    | LoadedWithAnnotations Image Int (Zipper AnnotationWithId)
    | LoadingError String


type alias AnnotationWithId =
    { id : Int
    , classId : Int
    , annotation : Annotation
    }



-- FUNCTIONS #########################################################


reset : AnnotatedImage -> AnnotatedImage
reset annotatedImage =
    case annotatedImage.status of
        LoadedWithAnnotations img _ _ ->
            { annotatedImage | status = Loaded img }

        _ ->
            annotatedImage


hasAnnotations : AnnotatedImage -> Bool
hasAnnotations annotatedImage =
    case annotatedImage.status of
        LoadedWithAnnotations _ _ _ ->
            True

        _ ->
            False


removeAnnotation : AnnotatedImage -> AnnotatedImage
removeAnnotation annotatedImage =
    case annotatedImage.status of
        LoadedWithAnnotations img count zipper ->
            case zipper of
                Zipper left _ (r :: rs) ->
                    { annotatedImage | status = LoadedWithAnnotations img count (Zipper left r rs) }

                Zipper (l :: ls) _ [] ->
                    { annotatedImage | status = LoadedWithAnnotations img count (Zipper ls l []) }

                Zipper [] _ [] ->
                    { annotatedImage | status = Loaded img }

        _ ->
            annotatedImage


updateWithPointer : Pointer.Msg -> Pointer.DragState -> Tool -> Int -> AnnotatedImage -> AnnotatedImage
updateWithPointer pointerMsg dragState tool classId ({ name } as annotatedImage) =
    case ( pointerMsg, annotatedImage.status ) of
        ( Pointer.DownAt pos, _ ) ->
            updateWithPointerDownAt pos tool classId annotatedImage

        ( Pointer.MoveAt pos, LoadedWithAnnotations img count zipper ) ->
            updateCurrentWith (Annotation.moveUpdate pos dragState) name img count zipper

        ( Pointer.UpAt _, LoadedWithAnnotations _ _ _ ) ->
            checkCurrent annotatedImage

        _ ->
            annotatedImage


updateWithPointerDownAt : ( Float, Float ) -> Tool -> Int -> AnnotatedImage -> AnnotatedImage
updateWithPointerDownAt coordinates tool classId annotatedImage =
    case ( tool, annotatedImage.status ) of
        ( Tool.Polygon, LoadedWithAnnotations img count zipper ) ->
            Debug.todo "check if current is unfinished polygon"

        ( _, Loaded img ) ->
            Annotation.init tool coordinates
                |> (\annotation -> { id = 0, classId = classId, annotation = annotation })
                |> Zipper.singleton
                |> LoadedWithAnnotations img 0
                |> (\status -> { annotatedImage | status = status })

        ( _, LoadedWithAnnotations img count zipper ) ->
            appendAnnotation (count + 1) classId (Annotation.init tool coordinates) zipper
                |> LoadedWithAnnotations img (count + 1)
                |> (\status -> { annotatedImage | status = status })

        _ ->
            annotatedImage


appendAnnotation : Int -> Int -> Annotation -> Zipper AnnotationWithId -> Zipper AnnotationWithId
appendAnnotation id classId annotation zipper =
    Zipper.goEnd zipper
        |> Zipper.insertGoR (AnnotationWithId id classId annotation)


checkCurrent : AnnotatedImage -> AnnotatedImage
checkCurrent ({ name, status } as annotatedImage) =
    Debug.todo "check current for potential removal"


updateCurrentWith : (Annotation -> Annotation) -> String -> Image -> Int -> Zipper AnnotationWithId -> AnnotatedImage
updateCurrentWith f imageName img count zipper =
    { name = imageName
    , status = LoadedWithAnnotations img count (Zipper.updateC (updateAnnotation f) zipper)
    }


updateAnnotation : (Annotation -> Annotation) -> { record | annotation : Annotation } -> { record | annotation : Annotation }
updateAnnotation f record =
    { record | annotation = f record.annotation }



-- Conversion from remote image


fromRemote : RemoteImage -> AnnotatedImage
fromRemote { name, status } =
    let
        annotatedStatus =
            case status of
                RemoteImage.Loading ->
                    Loading

                RemoteImage.LoadingError error ->
                    LoadingError error

                RemoteImage.Loaded image ->
                    Loaded image
    in
    { name = name, status = annotatedStatus }



-- Encoders


encode : AnnotatedImage -> Value
encode { name, status } =
    case status of
        LoadedWithAnnotations img _ zipper ->
            Encode.object
                [ ( "image", Encode.string name )
                , ( "size", Encode.list Encode.int [ img.width, img.height ] )
                , ( "annotations", Encode.list encodeAnnotationWithId (Zipper.getAll zipper) )
                ]

        _ ->
            Encode.object
                [ ( "image", Encode.string name )
                , ( "annotations", Encode.null )
                ]


encodeAnnotationWithId : AnnotationWithId -> Value
encodeAnnotationWithId { id, classId, annotation } =
    Encode.object
        [ ( "classId", Encode.int classId )
        , ( "annotation", Annotation.encode annotation )
        ]
