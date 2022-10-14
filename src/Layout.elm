module Layout exposing (layout, pageTitle, postTags, postsList, tagsList)

import Date
import FeatherIcons as Icons
import Html exposing (Html, a, br, div, footer, h1, h2, header, li, main_, nav, p, section, span, text, ul)
import Html.Attributes exposing (class, href, rel, target)
import Metadata
import Site


layout : List (Html msg) -> Html msg
layout body =
    div
        [ class "terminal container" ]
        [ navbar_
        , main_ [] body
        , footer_
        ]


navbar_ : Html msg
navbar_ =
    div
        [ class "terminal-nav" ]
        [ header
            [ class "navbar-logo" ]
            [ div
                [ class "logo terminal-prompt" ]
                [ a
                    [ href "/", class "no-style" ]
                    [ text (Site.title ++ " ...") ]
                ]
            ]
        , nav
            [ class "terminal-menu" ]
            [ ul []
                [ li []
                    [ a
                        [ href "/posts", class "menu-item" ]
                        [ text "Posts" ]
                    ]
                , li []
                    [ a
                        [ href "/tags", class "menu-item" ]
                        [ text "Tags" ]
                    ]
                , li []
                    [ a
                        [ href "/about", class "menu-item" ]
                        [ text "About" ]
                    ]
                ]
            ]
        ]


footer_ : Html msg
footer_ =
    div
        [ class "terminal-footer" ]
        [ footer []
            [ ul
                [ class "terminal-account-links" ]
                (List.map
                    (\link ->
                        li [] [ link ]
                    )
                    accountLinks
                )
            , span []
                [ text "Powered by "
                , a
                    [ href "https://elm-pages.com"
                    , target "_blank"
                    , rel "noopener noreferrer"
                    ]
                    [ text "elm-pages" ]
                , text " & "
                , a
                    [ href "https://terminalcss.xyz"
                    , target "_blank"
                    , rel "noopener noreferrer"
                    ]
                    [ text "terminal.css" ]
                ]
            , br [] []
            , span []
                [ text "© 2022 tkoyasak" ]
            ]
        ]


accountLinks : List (Html msg)
accountLinks =
    List.map
        (\account ->
            a
                [ href account.url ]
                [ account.icon
                    |> Icons.toHtml []
                ]
        )
        accounts


accounts : List { icon : Icons.Icon, url : String }
accounts =
    [ { icon = Icons.rss, url = Site.config.canonicalUrl ++ "/feed.xml" }
    , { icon = Icons.github, url = "https://github.com/tkoyasak" }
    , { icon = Icons.twitter, url = "https://twitter.com/tkoyasak" }
    , { icon = Icons.book, url = "https://bookmeter.com/users/1204476/books/read" }
    ]


pageTitle : String -> Html msg
pageTitle title =
    div []
        [ header
            [ class "terminal-page-title" ]
            [ h1 [] [ text title ] ]
        , div
            [ class "terminal-page-title-divider" ]
            []
        ]


postsList : List Metadata.Post -> Html msg
postsList posts =
    section []
        (List.map
            (\post ->
                div
                    [ class "terminal-post-item" ]
                    [ a
                        [ href ("/posts/" ++ post.id) ]
                        [ h2 [] [ text post.title ] ]
                    , postTags post
                    , p [] [ text post.summary ]
                    , a
                        [ href ("/posts/" ++ post.id) ]
                        [ text "Read more >" ]
                    ]
            )
            posts
        )


postTags : Metadata.Post -> Html msg
postTags post =
    ul
        [ class "terminal-post-tags" ]
        (li
            [ class "terminal-tag-item" ]
            [ text (Date.format "y-MM-dd |" post.publishedAt) ]
            :: List.map
                (\tag ->
                    li
                        [ class "terminal-tag-item" ]
                        [ a
                            [ href ("/tags/" ++ tag.name) ]
                            [ text ("#" ++ tag.name) ]
                        ]
                )
                post.tags
        )


tagsList : List Metadata.Tag -> Html msg
tagsList tags =
    section
        [ class "terminal-tags-list" ]
        [ ul []
            (List.map
                (\tag ->
                    li
                        [ class "terminal-tag-item" ]
                        [ a
                            [ href ("/tags/" ++ tag.name) ]
                            [ text ("#" ++ tag.name) ]
                        , text (" (" ++ String.fromInt tag.count ++ ")")
                        ]
                )
                tags
            )
        ]
