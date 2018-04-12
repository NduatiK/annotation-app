-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module Data.Annotation exposing (Type(..), typeDecoder, typeFromString)

import Json.Decode as Decode exposing (Decoder)


-- TYPES #############################################################


type Type
    = Point
    | BBox
    | Stroke
    | Outline
    | Polygon



-- FUNCTIONS #########################################################


typeFromString : String -> Type
typeFromString str =
    case str of
        "point" ->
            Point

        "bbox" ->
            BBox

        "stroke" ->
            Stroke

        "outline" ->
            Outline

        "polygon" ->
            Polygon

        _ ->
            Point



-- Decoders


typeDecoder : Decoder Type
typeDecoder =
    Decode.map typeFromString Decode.string
