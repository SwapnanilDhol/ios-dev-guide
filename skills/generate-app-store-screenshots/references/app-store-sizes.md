# App Store Connect screenshot sizes

Verified against Apple's Screenshot specifications on 2026-07-18:

https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/

## Default

Use `1320 x 2868` pixels for portrait iPhone screenshots. It is the largest currently accepted 6.9-inch display size and App Store Connect can scale high-resolution screenshots down when the interface is identical.

## Accepted 6.9-inch portrait sizes

- `1260 x 2736`
- `1290 x 2796`
- `1320 x 2868`

The corresponding landscape sizes reverse width and height.

## File constraints

- Upload 1 to 10 screenshots.
- Use `.png`, `.jpg`, or `.jpeg`.
- Do not include alpha channels or transparency.
- Keep every screenshot within one device-size set at the same accepted dimensions.

Re-check the Apple page before changing the preset because supported devices and accepted sizes can change.
