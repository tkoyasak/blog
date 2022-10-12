/** @typedef {{load: (Promise<unknown>); flags: (unknown)}} ElmPagesInit */

// Reference from https://github.com/nathanbraun/elm-pages-starter/blob/main/public/index.js

const ANALYTICS_ID = "G-H8CVK3PT67";

const trackPage = function (gtag, url) {
  gtag("event", "page_view", { page_path: url });
};

/** @type ElmPagesInit */
export default {
  load: async function (elmLoaded) {
    const app = await elmLoaded;

    window.dataLayer = window.dataLayer || [];
    function gtag() {
      dataLayer.push(arguments);
    }
    gtag("config", ANALYTICS_ID, {
      send_page_view: false,
    });
    gtag("js", new Date());

    gtag("get", ANALYTICS_ID, "client_id", (client_id) => {
      console.log(client_id);
    });

    app.ports.trackAnalytics.subscribe((payload) => {
      switch (payload.action) {
        case "navigateToPage":
          trackPage(gtag, payload.data);
      }
    });
  },
};

var gt = document.createElement("script");
gt.setAttribute(
  "src",
  `https://www.googletagmanager.com/gtag/js?id=${ANALYTICS_ID}`
);
document.head.appendChild(gt);

window.addEventListener("beforeinstallprompt", (e) => {
  e.preventDefault();
});
