module StyleSheet exposing (..)

import Annotation.Color as Color
import Color
import Style exposing (StyleSheet)
import Style.Color as Color
import Style.Font as Font


type Style
    = None
    | Button ButtonState
    | ClassesSidebar
    | ClassItem ClassState
    | Viewer
    | ToolIcon


type ButtonState
    = Disabled
    | Abled
    | Selected


type ClassState
    = SelectedClass
    | NonSelectedClass


type ColorVariations
    = FromPalette Int


sheet : StyleSheet Style ColorVariations
sheet =
    Style.styleSheet
        [ Style.style None []

        -- Action bar buttons
        , Style.style (Button Disabled) <|
            Color.background (Color.rgba 255 255 255 0.8)
                :: Style.opacity 0.2
                :: preventCommon
        , Style.style (Button Abled) <|
            Color.background (Color.rgba 255 255 255 0.8)
                :: Style.hover [ Color.background Color.lightGrey, Style.cursor "pointer" ]
                :: preventCommon
        , Style.style (Button Selected) <|
            Color.background Color.grey
                :: preventCommon
        , Style.style ToolIcon colorVariations

        -- Viewer
        , Style.style Viewer preventCommon

        -- Classes sidebar
        , Style.style ClassesSidebar <|
            Color.background (Color.rgba 255 255 255 0.8)
                :: preventCommon
        , Style.style (ClassItem NonSelectedClass) <|
            Style.hover [ Color.background Color.lightGrey, Style.cursor "pointer" ]
                :: classesCommonStyles
        , Style.style (ClassItem SelectedClass) <|
            Color.background Color.grey
                :: classesCommonStyles
        ]


classesCommonStyles : List (Style.Property class var)
classesCommonStyles =
    Font.size 30
        :: preventCommon


colorVariations : List (Style.Property class ColorVariations)
colorVariations =
    case Color.palette of
        ( color4, color3, color2, color1, color0 ) ->
            Style.variation (FromPalette 0) [ Color.text Color.black ]
                :: Style.variation (FromPalette 1) [ Color.text color0 ]
                :: Style.variation (FromPalette 2) [ Color.text color1 ]
                :: Style.variation (FromPalette 3) [ Color.text color2 ]
                :: Style.variation (FromPalette 4) [ Color.text color3 ]
                :: Style.variation (FromPalette 5) [ Color.text color4 ]
                :: []


preventCommon : List (Style.Property class variation)
preventCommon =
    Style.prop "touch-action" "none"
        :: noUserSelect


noUserSelect : List (Style.Property class variation)
noUserSelect =
    [ Style.prop "user-select" "none"
    , Style.prop "-webkit-user-select" "none"
    , Style.prop "-moz-user-select" "none"
    , Style.prop "-ms-user-select" "none"
    ]
