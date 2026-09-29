ObjC.import("AppKit");
ObjC.import("Foundation");

function renderSVG(sourcePath, size, outputPath) {
  const sourceURL = $.NSURL.fileURLWithPath($(sourcePath));
  const sourceImage = $.NSImage.alloc.initWithContentsOfURL(sourceURL);
  if (!sourceImage) {
    throw new Error(`Could not load SVG: ${sourcePath}`);
  }

  const bitmap = $.NSBitmapImageRep.alloc
    .initWithBitmapDataPlanesPixelsWidePixelsHighBitsPerSampleSamplesPerPixelHasAlphaIsPlanarColorSpaceNameBytesPerRowBitsPerPixel(
      null,
      size,
      size,
      8,
      4,
      true,
      false,
      $.NSCalibratedRGBColorSpace,
      0,
      0
    );
  if (!bitmap) {
    throw new Error(`Could not create ${size}x${size} bitmap`);
  }

  const context = $.NSGraphicsContext.graphicsContextWithBitmapImageRep(bitmap);
  $.NSGraphicsContext.saveGraphicsState;
  $.NSGraphicsContext.setCurrentContext(context);
  context.imageInterpolation = $.NSImageInterpolationHigh;
  context.shouldAntialias = true;
  $.NSColor.clearColor.set;
  $.NSRectFill($.NSMakeRect(0, 0, size, size));
  sourceImage.drawInRectFromRectOperationFraction(
    $.NSMakeRect(0, 0, size, size),
    $.NSZeroRect,
    $.NSCompositingOperationSourceOver,
    1.0
  );
  context.flushGraphics;
  $.NSGraphicsContext.restoreGraphicsState;

  const pngData = bitmap.representationUsingTypeProperties(
    $.NSBitmapImageFileTypePNG,
    $({})
  );
  if (!pngData || !pngData.writeToFileAtomically($(outputPath), true)) {
    throw new Error(`Could not write PNG: ${outputPath}`);
  }
}

function run(argv) {
  if (argv.length !== 3) {
    throw new Error("usage: render-svg.js SOURCE.svg SIZE OUTPUT.png");
  }
  const size = Number(argv[1]);
  if (!Number.isInteger(size) || size <= 0) {
    throw new Error(`Invalid output size: ${argv[1]}`);
  }
  renderSVG(argv[0], size, argv[2]);
}
