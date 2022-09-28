module Api exposing (routes)

import ApiRoute
import Data.Posts
import DataSource
import Html exposing (Html)
import Pages
import Route exposing (Route)
import Rss
import Site
import Time


routes :
    DataSource.DataSource (List Route)
    -> (Html Never -> String)
    -> List (ApiRoute.ApiRoute ApiRoute.Response)
routes _ _ =
    [ rss
        { siteTagline = Site.description
        , siteUrl = "https://blog.tkoyasak.dev"
        , title = Site.title
        , builtAt = Pages.builtAt
        , indexPage = [ "" ]
        }
        postsDataSource
    ]


postsDataSource : DataSource.DataSource (List Rss.Item)
postsDataSource =
    Data.Posts.getAllPosts
        |> DataSource.map
            (List.map
                (\post ->
                    { title = post.title
                    , description = post.description
                    , url = "/posts/" ++ post.id
                    , categories = []
                    , author = "tkoyasak"
                    , pubDate = Rss.Date post.publishedAt
                    , content = Nothing
                    , contentEncoded = Nothing
                    , enclosure = Nothing
                    }
                )
            )


rss :
    { siteTagline : String
    , siteUrl : String
    , title : String
    , builtAt : Time.Posix
    , indexPage : List String
    }
    -> DataSource.DataSource (List Rss.Item)
    -> ApiRoute.ApiRoute ApiRoute.Response
rss options itemsRequest =
    ApiRoute.succeed
        (itemsRequest
            |> DataSource.map
                (\items ->
                    { body =
                        Rss.generate
                            { title = options.title
                            , description = options.siteTagline
                            , url = options.siteUrl ++ "/" ++ String.join "/" options.indexPage
                            , lastBuildTime = options.builtAt
                            , generator = Just Site.title
                            , items = items
                            , siteUrl = options.siteUrl
                            }
                    }
                )
        )
        |> ApiRoute.literal "/feed.xml"
        |> ApiRoute.single
