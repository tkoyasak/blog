module Page.Posts.Slug_ exposing (Data, Model, Msg, page)

import Data.Blog
import DataSource exposing (DataSource)
import Date
import Head
import Head.Seo as Seo
import Html.Attributes exposing (class)
import Markdown
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
    { slug : String }


type alias Data =
    Data.Blog.PostMetadata


page : Page RouteParams Data
page =
    Page.prerender
        { data = data
        , routes = routes
        , head = head
        }
        |> Page.buildNoState { view = view }


data : RouteParams -> DataSource Data
data route =
    Data.Blog.getPostById route.slug
        |> DataSource.map
            (\metadata -> metadata)


routes : DataSource (List RouteParams)
routes =
    Data.Blog.getAllPosts
        |> DataSource.map
            (List.map (\post -> { slug = post.id }))


head : StaticPayload Data RouteParams -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = Site.title
        , image =
            { url = Site.iconUrl
            , alt = Site.title ++ " icon"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , locale = Nothing
        , description = static.data.description
        , title = static.data.title ++ " - " ++ Site.title
        }
        |> Seo.article
            { expirationTime = Nothing
            , modifiedTime = Just (Date.format "y-MM-dd" static.data.revisedAt)
            , publishedTime = Just (Date.format "y-MM-dd" static.data.publishedAt)
            , section = Nothing
            , tags = List.map (\metadata -> metadata.name) static.data.tags
            }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Never
view _ _ static =
    { title = static.data.title ++ " - " ++ Site.title
    , body =
        [ View.Layout.pageTitle static.data.title
        , View.Layout.postTags static.data
        , Markdown.toHtml [ class "post-content" ] static.data.description
        ]
    }
