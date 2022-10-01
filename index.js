/** @typedef {{load: (Promise<unknown>); flags: (unknown)}} ElmPagesInit */

/** @type ElmPagesInit */
export default {
  load: async function (elmLoaded) {
    const app = await elmLoaded;
    syntaxHighlight();
    console.log("App loaded", app);
  },
  flags: function () {
    return "You can decode this in Shared.elm using Json.Decode.string!";
  },
};

const syntaxHighlight = () => {
  const script = document.createElement("script");
  script.id = "highlight.js-script";
  script.src =
    "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.3.1/highlight.min.js";
  script.async = true;
  document.head.appendChild(script);

  const runHljs = setInterval(() => {
    if (window.hljs) {
      window.hljs.highlightAll();
      clearInterval(runHljs);
    }
  }, 1000);
};
