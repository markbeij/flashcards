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
