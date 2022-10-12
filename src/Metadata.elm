module Metadata exposing (About, Post, Tag, TagWithCount, getAbout, getAllPosts, getAllTags, getPostById, getPostsByTag, getTagsWithCount)

import DataSource
import DataSource.Http
import Date exposing (Date)
import Dict
import Dict.Extra as Dict
import OptimizedDecoder as Decoder
import Pages.Secrets as Secrets


requestContent :
    String
    -> Decoder.Decoder a
    -> DataSource.DataSource a
requestContent query =
    DataSource.Http.request
        (Secrets.succeed
            (\apiKey ->
                { url = "https://tkoyasak.microcms.io/api/v1/" ++ query
                , method = "GET"
                , headers = [ ( "X-MICROCMS-API-KEY", apiKey ) ]
                , body = DataSource.Http.emptyBody
                }
            )
            |> Secrets.with "API_KEY"
        )


type alias Post =
    { id : String
    , title : String
    , tags : List Tag
    , summary : String
    , description : String
    , publishedAt : Date
    , revisedAt : Date
    }


type alias Tag =
    { id : String
    , name : String
    }


type alias TagWithCount =
    { name : String
    , count : Int
    }


type alias About =
    { about : String
    , revisedAt : Date
    }


decodePost : Decoder.Decoder Post
decodePost =
    Decoder.map7 Post
        (Decoder.field "id" Decoder.string)
        (Decoder.field "title" Decoder.string)
        (Decoder.field "tags" (Decoder.list decodeTag))
        (Decoder.field "summary" Decoder.string)
        (Decoder.field "description" Decoder.string)
        (Decoder.field "publishedAt" decodeDate)
        (Decoder.field "revisedAt" decodeDate)


decodeTag : Decoder.Decoder Tag
decodeTag =
    Decoder.map2 Tag
        (Decoder.field "id" Decoder.string)
        (Decoder.field "name" Decoder.string)


decodeAbout : Decoder.Decoder About
decodeAbout =
    Decoder.map2 About
        (Decoder.field "about" Decoder.string)
        (Decoder.field "revisedAt" decodeDate)


decodeDate : Decoder.Decoder Date
decodeDate =
    Decoder.string
        |> Decoder.andThen
            (\isoString ->
                String.slice 0 10 isoString
                    |> Date.fromIsoString
                    |> Decoder.fromResult
            )


getAllPosts : DataSource.DataSource (List Post)
getAllPosts =
    requestContent
        "posts"
        (Decoder.field "contents" (Decoder.list decodePost))


getPostById : String -> DataSource.DataSource Post
getPostById id =
    requestContent
        ("posts/" ++ id)
        decodePost


getPostsByTag : String -> DataSource.DataSource (List Post)
getPostsByTag tagname =
    requestContent
        "posts"
        (Decoder.field "contents" (Decoder.list decodePost))
        |> DataSource.map
            (\allPosts ->
                List.filter
                    (\post ->
                        List.member tagname
                            (List.map
                                (\metadata -> metadata.name)
                                post.tags
                            )
                    )
                    allPosts
            )


getAllTags : DataSource.DataSource (List Tag)
getAllTags =
    requestContent
        "tags"
        (Decoder.field "contents" (Decoder.list decodeTag))


getTagsWithCount : DataSource.DataSource (List TagWithCount)
getTagsWithCount =
    requestContent
        "posts"
        (Decoder.field "contents"
            (Decoder.list
                (Decoder.field "tags"
                    (Decoder.list (Decoder.field "name" Decoder.string))
                )
            )
        )
        |> DataSource.map List.concat
        |> DataSource.map Dict.frequencies
        |> DataSource.map (Dict.foldr (\key value list -> TagWithCount key value :: list) [])
        |> DataSource.map
            (List.sortWith
                (\a b ->
                    case compare a.count b.count of
                        LT ->
                            GT

                        EQ ->
                            EQ

                        GT ->
                            LT
                )
            )


getAbout : DataSource.DataSource About
getAbout =
    requestContent
        "about"
        decodeAbout
