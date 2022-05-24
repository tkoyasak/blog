module Site exposing (config, description, iconUrl, title)

import DataSource
import Head
import LanguageTag
import LanguageTag.Language
import MimeType
import Pages.Manifest as Manifest
import Pages.Url
import Path
import Route
import SiteConfig exposing (SiteConfig)


type alias Data =
    ()


config : SiteConfig Data
config =
    { data = data
    , canonicalUrl = "https://tkoyasak.dev"
    , manifest = manifest
    , head = head
    }


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


head : Data -> List Head.Tag
head _ =
    [ LanguageTag.Language.ja
        |> LanguageTag.build LanguageTag.emptySubtags
        |> Head.rootLanguage
    , Head.rssLink "/feed.xml"
    , Head.icon [ ( 100, 100 ) ] MimeType.Jpeg iconUrl
    ]


manifest : Data -> Manifest.Config
manifest _ =
    Manifest.init
        { name = title
        , description = description
        , startUrl = Route.Index |> Route.toPath
        , icons =
            [ { src = iconUrl
              , sizes = [ ( 100, 100 ) ]
              , mimeType = Just MimeType.Jpeg
              , purposes = [ Manifest.IconPurposeAny ]
              }
            ]
        }


title : String
title =
    "tkoyasak.dev"


description : String
description =
    "tkoyasak's website"


iconUrl : Pages.Url.Url
iconUrl =
    [ "images", "icon.jpg" ]
        |> Path.join
        |> Pages.Url.fromPath
