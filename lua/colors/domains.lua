return {
  keywords = {
    groups = { "@keyword", "@keyword.conditional", "@keyword.function", "@operator" },
    styles = {
      ["@keyword"] = { bold = true },
      ["@keyword.conditional"] = { bold = true },
      ["@keyword.function"] = { bold = true },
    },
    stops = { "#ff8858", "#ffaa7a" },
  },

  types = {
    groups = { "@type", "@constructor", "@type.builtin" },
    styles = {
      ["@type"] = { italic = true },
      ["@constructor"] = { bold = true },
      ["@type.builtin"] = { bold = true },
    },
    stops = { "#a57df8", "#bfa7ff" },
  },

  values = {
    groups = { "@attribute", "@constant", "@constant.builtin", "@number", "@boolean" },
    styles = { ["@boolean"] = { nocombine = true } },
    stops = { "#8a93ff", "#a0b0ff" },
  },

  functions = {
    groups = { "@function", "@parameter", "@label" },
    styles = {
      ["@function"] = { italic = true, nocombine = true },
      ["@function.call"] = { nocombine = true },
      ["@parameter"] = {},
      ["@label"] = { italic = true },
    },
    stops = { "#ff8ed0", "#ffb6d9", "#ffc6e2" },
    direct = true,
  },

  strings = {
    groups = { "@string", "@spell" },
    styles = { ["@spell"] = { italic = true } },
    stops = { "#53ffa4", "#4b7057" },
  },

  punctuation = {
    groups = { "@punctuation.delimiter", "@punctuation.bracket", "@punctuation.special" },
    styles = {},
    stops = { "#f5e4ee", "#f0dfe0" },
  },

  vars = {
    groups = {
      "@variable", "@function.call", "@variable.member",
      "@variable.parameter", "@variable.builtin", "@module",
    },
    styles = {
      ["@variable"] = { bold = true },
      ["@variable.parameter"] = { italic = true },
      ["@module"] = { italic = true },
    },
    stops = { "#ffffff", "#ffb6d9", "#dbdbdb", "#c4c4c4", "#aeaeae", "#9c9c9c" },
    direct = true,
  },
}
