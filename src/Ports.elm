-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


port module Ports
    exposing
        ( configLoaded
        , imageLoaded
        , loadConfigFile
        , loadImageFile
        , resizes
        )

import Json.Encode exposing (Value)
import Packages.Device as Device exposing (Device)


port resizes : (Device.Size -> msg) -> Sub msg


port loadImageFile : ( Int, Value ) -> Cmd msg


port imageLoaded : ({ id : Int, url : String, width : Int, height : Int } -> msg) -> Sub msg


port loadConfigFile : Value -> Cmd msg


port configLoaded : (String -> msg) -> Sub msg
