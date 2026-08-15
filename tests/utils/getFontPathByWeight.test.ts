import { describe, it, expect } from "vitest";
import { getFontPathByWeight } from "@/utils/getFontPathByWeight";

const mockFonts = [
  {
    weight: "400",
    style: "normal" as const,
    src: [
      { url: "/fonts/regular.woff2", format: "woff2" },
      { url: "/fonts/regular.ttf", format: "truetype" },
    ],
  },
  {
    weight: "700",
    style: "normal" as const,
    src: [{ url: "/fonts/bold.ttf", format: "truetype" }],
  },
  {
    weight: "400",
    style: "italic" as const,
    src: [{ url: "/fonts/italic.ttf", format: "truetype" }],
  },
];

describe("getFontPathByWeight", () => {
  it("finds font by weight with default options", () => {
    expect(getFontPathByWeight(mockFonts, 400)).toBe("/fonts/regular.ttf");
  });

  it("finds bold weight", () => {
    expect(getFontPathByWeight(mockFonts, 700)).toBe("/fonts/bold.ttf");
  });

  it("returns undefined for missing weight", () => {
    expect(getFontPathByWeight(mockFonts, 300)).toBeUndefined();
  });

  it("selects by format when specified", () => {
    expect(
      getFontPathByWeight(mockFonts, 400, { format: "woff2" })
    ).toBe("/fonts/regular.woff2");
  });

  it("finds italic style", () => {
    expect(
      getFontPathByWeight(mockFonts, 400, { style: "italic" })
    ).toBe("/fonts/italic.ttf");
  });

  it("returns undefined when style does not match", () => {
    expect(
      getFontPathByWeight(mockFonts, 700, { style: "italic" })
    ).toBeUndefined();
  });

  it("falls back to first src when format not found", () => {
    expect(
      getFontPathByWeight(mockFonts, 700, { format: "woff2" })
    ).toBe("/fonts/bold.ttf");
  });

  it("returns undefined for empty fonts array", () => {
    expect(getFontPathByWeight([], 400)).toBeUndefined();
  });
});
