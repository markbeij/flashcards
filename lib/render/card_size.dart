/// Page and card geometry. All values are millimetres.
///
/// Every card has the same size, 95×69 mm, so cards fit in an A7 card box.
/// They sit in a uniform grid on an A4 portrait sheet, at least 10 mm from
/// the page edges.
const pageWidthMm = 210.0;
const pageHeightMm = 297.0;

const cardWidthMm = 95.0;
const cardHeightMm = 69.0;

const sheetColumns = 2;
const sheetRows = 4;
const cardsPerSheet = sheetColumns * sheetRows;

/// Inner padding of a card. The sides leave room for a cut that is up to
/// about 1 mm off.
const cardPaddingHorizontalMm = 5.0;
const cardPaddingTopMm = 5.0;
const cardPaddingBottomMm = 3.0;

/// The footer line (deck title and `#n`) at the bottom of both sides.
const footerHeightMm = 3.5;
const footerGapMm = 1.5;

/// The area for the card's content, above the footer.
const contentWidthMm = cardWidthMm - 2 * cardPaddingHorizontalMm;
const contentHeightMm =
    cardHeightMm -
    cardPaddingTopMm -
    cardPaddingBottomMm -
    footerHeightMm -
    footerGapMm;
