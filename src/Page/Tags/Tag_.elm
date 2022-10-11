module Page.Tags.Tag_ exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Metadata
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Shared
import Site
import View exposing (View)
import View.Layout


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { tag : String }


type alias Data =
    { entries : List Metadata.Post, tag : String }


page : Page RouteParams Data
page =
    Page.prerender
        { data = data
        , routes = routes
        , head = head
        }
        |> Page.buildNoState { view = view }


data : RouteParams -> DataSource.DataSource Data
data route =
    DataSource.map2
        Data
        (Metadata.getPostsByTag route.tag)
        (DataSource.succeed route.tag)


routes : DataSource (List RouteParams)
routes =
    Metadata.getAllTags
        |> DataSource.map
            (List.map (\metadata -> { tag = metadata.name }))


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = Site.title
        , image =
            { url = Site.iconUrl
            , alt = Site.title ++ " icon"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = Site.description
        , locale = Nothing
        , title = "Posts | " ++ Site.title
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ static =
    { title = "Tag : #" ++ static.data.tag
    , body =
        [ View.Layout.pageTitle ("Tag : #" ++ static.data.tag)
        , View.Layout.postsList static.data.entries
        ]
    }
