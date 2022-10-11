module Data.Blog exposing (AboutMetadata, PostMetadata, TagMetadata, TagWithCount, getAbout, getAllPosts, getAllTags, getPostById, getPostsByTag, getTagsWithCount)

import DataSource
import DataSource.Http
import Date exposing (Date)
import Dict
import Dict.Extra as Dict
import OptimizedDecoder as Decoder
import Pages.Secrets as Secrets


type alias PostMetadata =
    { id : String
    , title : String
    , tags : List TagMetadata
    , summary : String
    , description : String
    , publishedAt : Date
    , revisedAt : Date
    }


type alias TagMetadata =
    { id : String
    , name : String
    }


type alias TagWithCount =
    { name : String
    , count : Int
    }


type alias AboutMetadata =
    { about : String
    , revisedAt : Date
    }


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


decodePostMetadata : Decoder.Decoder PostMetadata
decodePostMetadata =
    Decoder.map7 PostMetadata
        (Decoder.field "id" Decoder.string)
        (Decoder.field "title" Decoder.string)
        (Decoder.field "tags" (Decoder.list decodeTagMetadata))
        (Decoder.field "summary" Decoder.string)
        (Decoder.field "description" Decoder.string)
        (Decoder.field "publishedAt" decodeDate)
        (Decoder.field "revisedAt" decodeDate)


decodeTagMetadata : Decoder.Decoder TagMetadata
decodeTagMetadata =
    Decoder.map2 TagMetadata
        (Decoder.field "id" Decoder.string)
        (Decoder.field "name" Decoder.string)


decodeAboutMetadata : Decoder.Decoder AboutMetadata
decodeAboutMetadata =
    Decoder.map2 AboutMetadata
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


getAllPosts : DataSource.DataSource (List PostMetadata)
getAllPosts =
    requestContent
        "posts"
        (Decoder.field "contents" (Decoder.list decodePostMetadata))


getPostById : String -> DataSource.DataSource PostMetadata
getPostById id =
    requestContent
        ("posts/" ++ id)
        decodePostMetadata


getPostsByTag : String -> DataSource.DataSource (List PostMetadata)
getPostsByTag tagname =
    requestContent
        "posts"
        (Decoder.field "contents" (Decoder.list decodePostMetadata))
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


getAllTags : DataSource.DataSource (List TagMetadata)
getAllTags =
    requestContent
        "tags"
        (Decoder.field "contents" (Decoder.list decodeTagMetadata))


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
        |> DataSource.map (List.sortWith descendingOrder)


descendingOrder : TagWithCount -> TagWithCount -> Order
descendingOrder a b =
    case compare a.count b.count of
        LT ->
            GT

        EQ ->
            EQ

        GT ->
            LT


getAbout : DataSource.DataSource AboutMetadata
getAbout =
    requestContent
        "about"
        decodeAboutMetadata
