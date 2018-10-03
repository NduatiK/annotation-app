-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module Data.RemoteImage exposing (LoadingStatus(..), RemoteImage)

import Data.Image as Image exposing (Image)


type alias RemoteImage =
    { name : String
    , status : LoadingStatus
    }


type LoadingStatus
    = Loading
    | Loaded Image
    | LoadingError String
